"""Tests de la opción --solo de scripts/exportar_fabric.py (exportar o comprobar solo los items indicados).

Sin conexión: se sustituyen las llamadas a Fabric. Modos de fallo cubiertos:
- Con --solo se descarga un item que no se pidió (y un fallo de capacidad en un modelo semántico
  ajeno impide exportar lo que sí se cambió).
- Con --solo se borran las carpetas de los demás items al exportar.
- Con --solo la comprobación de sincronía compara también los items no pedidos.
- Un nombre mal escrito en --solo se ignora en silencio y no se exporta nada.
- Sin --solo cambia el comportamiento de siempre: regenerar todo y comparar todo.
"""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import exportar_fabric as ex  # noqa: E402
import fabric_comun as fc  # noqa: E402

ITEMS = [
    {"id": "1", "displayName": "INGESTA_Maestros", "type": "Dataflow"},
    {"id": "2", "displayName": "Financial Model", "type": "SemanticModel"},
    {"id": "3", "displayName": "Generar_salidas", "type": "DataPipeline"},
]


@pytest.fixture
def fabric_falso(monkeypatch):
    """Fabric con tres items; el modelo semántico falla como con la capacidad saturada."""
    pedidas = []

    def descargar_definicion(item, tok):
        pedidas.append(item["displayName"])
        if item["type"] == "SemanticModel":
            raise RuntimeError("PFE_FABRIC_THROTTLED")
        return {"definition/" + item["displayName"]: b"contenido"}

    monkeypatch.setattr(fc, "items", lambda tok: ITEMS)
    monkeypatch.setattr(fc, "descargar_definicion", descargar_definicion)
    monkeypatch.setattr(fc, "descargar_sql", lambda: {"sql/300.vw_X.sql": b"vista", "lakehouse/esquema.tsv": b"t"})
    return pedidas


def test_carpetas_solo():
    assert ex.carpetas_solo(None) is None
    assert ex.carpetas_solo(["INGESTA_Maestros.Dataflow"]) == {"INGESTA_Maestros.Dataflow"}
    assert ex.carpetas_solo(["INGESTA_Maestros.Dataflow", "lakehouse"]) == {
        "INGESTA_Maestros.Dataflow", "sql", "lakehouse",
    }


def test_descargar_solo_los_pedidos(fabric_falso):
    ficheros, errores = ex.descargar_todo("tok", {"INGESTA_Maestros.Dataflow", "Generar_salidas.DataPipeline"})

    assert errores == []
    assert sorted(fabric_falso) == ["Generar_salidas", "INGESTA_Maestros"]
    assert sorted(ficheros) == [
        "Generar_salidas.DataPipeline/definition/Generar_salidas",
        "INGESTA_Maestros.Dataflow/definition/INGESTA_Maestros",
    ]


def test_descargar_solo_incluye_vistas_con_lakehouse(fabric_falso):
    ficheros, errores = ex.descargar_todo("tok", {"INGESTA_Maestros.Dataflow", "sql", "lakehouse"})

    assert errores == []
    assert "sql/300.vw_X.sql" in ficheros and "lakehouse/esquema.tsv" in ficheros


def test_descargar_sin_solo_sigue_descargando_todo(fabric_falso):
    ficheros, errores = ex.descargar_todo("tok")

    assert errores == ["Financial Model.SemanticModel"]
    assert sorted(fabric_falso) == ["Financial Model", "Generar_salidas", "INGESTA_Maestros"]
    assert "sql/300.vw_X.sql" in ficheros


def test_solo_con_item_inexistente_para_con_codigo_2(fabric_falso):
    with pytest.raises(SystemExit) as salida:
        ex.descargar_todo("tok", {"INGESTA_Maestro.Dataflow"})

    assert salida.value.code == 2
    assert fabric_falso == []


@pytest.fixture
def repo_falso(tmp_path, monkeypatch):
    destino = tmp_path / "fabric"
    for ruta in ("A.Dataflow/x", "B.Dataflow/y", "sql/v.sql", "lakehouse/esquema.tsv"):
        (destino / ruta).parent.mkdir(parents=True, exist_ok=True)
        (destino / ruta).write_bytes(b"viejo")
    monkeypatch.setattr(fc, "RAIZ_REPO", tmp_path)
    monkeypatch.setattr(fc, "CARPETA_FABRIC", "fabric")
    return destino


def test_exportar_solo_no_borra_el_resto(repo_falso):
    ex.exportar({"A.Dataflow/x": b"nuevo"}, {"A.Dataflow"})

    assert (repo_falso / "A.Dataflow/x").read_bytes() == b"nuevo"
    assert (repo_falso / "B.Dataflow/y").read_bytes() == b"viejo"
    assert (repo_falso / "sql/v.sql").read_bytes() == b"viejo"
    assert (repo_falso / "lakehouse/esquema.tsv").read_bytes() == b"viejo"


def test_exportar_solo_con_lakehouse_regenera_vistas_y_esquema(repo_falso):
    ex.exportar({"sql/w.sql": b"nueva"}, {"sql", "lakehouse"})

    assert not (repo_falso / "sql/v.sql").exists()
    assert not (repo_falso / "lakehouse/esquema.tsv").exists()
    assert (repo_falso / "sql/w.sql").read_bytes() == b"nueva"
    assert (repo_falso / "B.Dataflow/y").read_bytes() == b"viejo"


def test_exportar_sin_solo_regenera_todo(repo_falso):
    ex.exportar({"A.Dataflow/x": b"nuevo"})

    assert (repo_falso / "A.Dataflow/x").read_bytes() == b"nuevo"
    assert not (repo_falso / "B.Dataflow").exists()
    assert not (repo_falso / "sql").exists()


def test_comprobar_solo_ignora_los_items_no_pedidos(monkeypatch):
    repo = {"A.Dataflow/x": b"1", "B.Dataflow/y": b"1", "Financial Model.SemanticModel/m": b"1"}
    monkeypatch.setattr(fc, "ficheros_en_git", lambda ref: repo)

    assert ex.comprobar({"A.Dataflow/x": b"1"}, "main", {"A.Dataflow"}) == 0
    assert ex.comprobar({"A.Dataflow/x": b"2"}, "main", {"A.Dataflow"}) == 1
    # Sin --solo, lo que falta en Fabric cuenta como diferencia.
    assert ex.comprobar({"A.Dataflow/x": b"1"}, "main") == 1
