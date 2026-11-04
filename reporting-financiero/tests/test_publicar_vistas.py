"""Tests de la publicación de vistas SQL del lakehouse, sin conexión a Fabric.

Modos de fallo cubiertos:
- Se ejecuta otra sentencia que no es la creación de esa vista (DROP, GO seguido de otra sentencia).
- El nombre del fichero y el de la vista no coinciden.
- Se pisa una vista que alguien cambió en Fabric sin pasar al repo.
- La simulación escribe en Fabric.

El test E2E contra Fabric está en test_fabric_e2e.py.
"""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import fabric_comun as fc  # noqa: E402
import publicar_fabric  # noqa: E402


VISTA_NUEVA = b"CREATE   VIEW [300].[vw_A]\r\nAS\r\nSELECT 1 AS x"
VISTA = b"CREATE VIEW [300].[vw_A]\r\nAS\r\nSELECT 1 AS x"
VISTA_CAMBIADA = b"CREATE VIEW [300].[vw_A]\r\nAS\r\nSELECT 2 AS x"
VISTA_EN_FABRIC_CAMBIADA = b"CREATE VIEW [300].[vw_A]\r\nAS\r\nSELECT 99 AS x"


def test_vista_de_ruta():
    assert fc.vista_de_ruta("sql/300.vw_Export_Grupo.sql") == ("300", "vw_Export_Grupo")
    for ruta in ["sql/400.vw_A.sql", "TRANS_Gold.Dataflow", "sql/300.vw_A.txt", "sql/300.vw-A.sql"]:
        with pytest.raises(ValueError):
            fc.vista_de_ruta(ruta)


def test_vista_nueva_se_ejecuta_tal_cual():
    assert fc.sentencia_de_vista("sql/300.vw_A.sql", VISTA_NUEVA, existe=False) == VISTA_NUEVA.decode("utf-8")


def test_vista_existente_usa_create_or_alter():
    assert fc.sentencia_de_vista("sql/300.vw_A.sql", VISTA_NUEVA, existe=True) == (
        "CREATE OR ALTER VIEW [300].[vw_A]\r\nAS\r\nSELECT 1 AS x"
    )


def test_vista_rechaza_nombre_distinto():
    with pytest.raises(ValueError):
        fc.sentencia_de_vista("sql/300.vw_A.sql", b"CREATE VIEW [200].[vw_A] AS SELECT 1", existe=False)
    with pytest.raises(ValueError):
        fc.sentencia_de_vista("sql/300.vw_A.sql", b"CREATE VIEW [300].[vw_B] AS SELECT 1", existe=False)


def test_vista_rechaza_otras_sentencias():
    with pytest.raises(ValueError):
        fc.sentencia_de_vista("sql/300.vw_A.sql", b"DROP TABLE [300].[vw_A]", existe=False)
    with pytest.raises(ValueError):
        fc.sentencia_de_vista(
            "sql/300.vw_A.sql", b"CREATE VIEW [300].[vw_A] AS SELECT 1\nGO\nDROP TABLE [300].[t]", existe=False
        )


def _preparar(monkeypatch, argv, en_rama, en_main, en_fabric):
    """Sustituye la red y git por datos en memoria. Devuelve la lista de sentencias publicadas."""
    publicadas = []

    def ficheros_en_git(ref, *args, **kwargs):
        if ref == "rama":
            return dict(en_rama)
        if ref == "main":
            return dict(en_main)
        raise AssertionError("ref inesperada: " + ref)

    def no_debe_llamarse(*args, **kwargs):
        raise AssertionError("publicar solo vistas no debe usar la API de items")

    monkeypatch.setattr(fc, "comprobar_cuenta", lambda: "persona@x")
    monkeypatch.setattr(fc, "ficheros_en_git", ficheros_en_git)
    monkeypatch.setattr(fc, "descargar_sql", lambda *args, **kwargs: dict(en_fabric))
    monkeypatch.setattr(fc, "publicar_vista", lambda sentencia: publicadas.append(sentencia), raising=False)
    monkeypatch.setattr(fc, "token", no_debe_llamarse)
    monkeypatch.setattr(fc, "items", no_debe_llamarse)
    monkeypatch.setattr(sys, "argv", ["publicar_fabric.py"] + argv)
    return publicadas


def test_simulacion_de_vista_nueva_no_escribe(monkeypatch):
    publicadas = _preparar(
        monkeypatch,
        ["sql/300.vw_A.sql", "--ref", "rama"],
        en_rama={"sql/300.vw_A.sql": VISTA},
        en_main={},
        en_fabric={},
    )
    assert publicar_fabric.main() == 0
    assert publicadas == []


def test_confirmar_crea_la_vista(monkeypatch):
    publicadas = _preparar(
        monkeypatch,
        ["sql/300.vw_A.sql", "--ref", "rama", "--confirmar"],
        en_rama={"sql/300.vw_A.sql": VISTA_NUEVA},
        en_main={},
        en_fabric={},
    )
    assert publicar_fabric.main() == 0
    assert publicadas == [VISTA_NUEVA.decode("utf-8")]


def test_confirmar_vista_existente_usa_create_or_alter(monkeypatch):
    publicadas = _preparar(
        monkeypatch,
        ["sql/300.vw_A.sql", "--ref", "rama", "--confirmar"],
        en_rama={"sql/300.vw_A.sql": VISTA_CAMBIADA},
        en_main={"sql/300.vw_A.sql": VISTA},
        en_fabric={"sql/300.vw_A.sql": VISTA},
    )
    assert publicar_fabric.main() == 0
    assert len(publicadas) == 1
    assert publicadas[0].startswith("CREATE OR ALTER VIEW [300].[vw_A]")


def test_fabric_distinto_de_base_para(monkeypatch):
    publicadas = _preparar(
        monkeypatch,
        ["sql/300.vw_A.sql", "--ref", "rama", "--confirmar"],
        en_rama={"sql/300.vw_A.sql": VISTA_CAMBIADA},
        en_main={"sql/300.vw_A.sql": VISTA},
        en_fabric={"sql/300.vw_A.sql": VISTA_EN_FABRIC_CAMBIADA},
    )
    assert publicar_fabric.main() == 1
    assert publicadas == []


def test_vista_que_no_esta_en_la_rama_es_error(monkeypatch, capsys):
    publicadas = _preparar(
        monkeypatch,
        ["sql/300.vw_Z.sql", "--ref", "rama"],
        en_rama={"sql/300.vw_A.sql": VISTA},
        en_main={},
        en_fabric={},
    )
    assert publicar_fabric.main() == 2
    assert publicadas == []
    # Tiene que fallar por no estar en la rama, no por "tipo no publicable".
    assert "no esta en" in capsys.readouterr().out
