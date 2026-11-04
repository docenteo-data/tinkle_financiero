"""Tests de la ejecución de pipelines de Fabric con confirmación, sin conexión a Fabric.

Modos de fallo cubiertos:
- La simulación lanza el pipeline.
- Se lanza un item que no es un pipeline o no existe.
- Un pipeline fallido se da por bueno.
- La espera no termina nunca.
- Un parámetro mal escrito se pasa a Fabric.
"""

import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import fabric_comun as fc  # noqa: E402


ITEMS = [
    {"displayName": "Grabar salidas", "type": "DataPipeline", "id": "p1"},
    {"displayName": "TRANS_Gold", "type": "Dataflow", "id": "d1"},
]


def test_leer_parametros():
    assert fc.leer_parametros(["a=1", "b=x=y"]) == {"a": "1", "b": "x=y"}
    assert fc.leer_parametros([]) == {}
    for lista in [["ficheros"], ["=1"]]:
        with pytest.raises(ValueError):
            fc.leer_parametros(lista)


def test_esperar_job_devuelve_estado_final(monkeypatch):
    respuestas = iter(
        [
            (200, {}, {"status": "NotStarted"}),
            (200, {}, {"status": "InProgress"}),
            (200, {}, {"status": "Completed"}),
        ]
    )
    llamadas = []
    durmiendo = []

    def peticion(metodo, url, tok, *args, **kwargs):
        llamadas.append((metodo, url, tok))
        return next(respuestas)

    monkeypatch.setattr(fc, "peticion", peticion)

    cuerpo = fc.esperar_job("https://job/1", "tok", dormir=durmiendo.append)

    assert cuerpo == {"status": "Completed"}
    assert len(llamadas) == 3
    assert len(durmiendo) == 2


def test_esperar_job_agota_tiempo(monkeypatch):
    monkeypatch.setattr(
        fc, "peticion", lambda metodo, url, tok, *args, **kwargs: (200, {}, {"status": "InProgress"})
    )
    with pytest.raises(TimeoutError):
        fc.esperar_job(
            "https://job/1", "tok", intervalo=20, max_segundos=60, dormir=lambda segundos: None
        )


def _preparar(monkeypatch, argv, estado=None):
    """Sustituye la red por datos en memoria. Devuelve (lanzados, esperados)."""
    lanzados = []
    esperados = []

    def lanzar(item, tok, parametros):
        lanzados.append((item, tok, parametros))
        return "https://job/1"

    def esperar(url, tok, *args, **kwargs):
        esperados.append(url)
        return {"status": estado}

    monkeypatch.setattr(fc, "comprobar_cuenta", lambda: "persona@x")
    monkeypatch.setattr(fc, "token", lambda *args, **kwargs: "tok")
    monkeypatch.setattr(fc, "items", lambda *args, **kwargs: [dict(i) for i in ITEMS])
    monkeypatch.setattr(fc, "lanzar_pipeline", lanzar, raising=False)
    monkeypatch.setattr(fc, "esperar_job", esperar, raising=False)
    monkeypatch.setattr(sys, "argv", ["ejecutar_fabric.py"] + argv)
    return lanzados, esperados


def test_simulacion_no_lanza(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(monkeypatch, ["Grabar salidas"], estado="Completed")
    assert ejecutar_fabric.main() == 0
    assert lanzados == []
    assert esperados == []


def test_confirmar_lanza_y_espera(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(
        monkeypatch,
        ["Grabar salidas", "--parametro", "ficheros=Balance", "--confirmar"],
        estado="Completed",
    )
    assert ejecutar_fabric.main() == 0
    assert len(lanzados) == 1
    item, tok, parametros = lanzados[0]
    assert item["id"] == "p1"
    assert tok == "tok"
    assert parametros == {"ficheros": "Balance"}
    assert esperados == ["https://job/1"]


def test_fallo_del_pipeline_devuelve_1(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(
        monkeypatch,
        ["Grabar salidas", "--parametro", "ficheros=Balance", "--confirmar"],
        estado="Failed",
    )
    assert ejecutar_fabric.main() == 1
    assert len(lanzados) == 1
    assert esperados == ["https://job/1"]


def test_pipeline_inexistente_es_error(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(monkeypatch, ["No existe", "--confirmar"], estado="Completed")
    assert ejecutar_fabric.main() == 2
    assert lanzados == []
    assert esperados == []


def test_item_que_no_es_pipeline_es_error(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(monkeypatch, ["TRANS_Gold", "--confirmar"], estado="Completed")
    assert ejecutar_fabric.main() == 2
    assert lanzados == []
    assert esperados == []


def test_parametro_mal_formado_es_error(monkeypatch):
    import ejecutar_fabric

    lanzados, esperados = _preparar(
        monkeypatch, ["Grabar salidas", "--parametro", "ficheros", "--confirmar"], estado="Completed"
    )
    assert ejecutar_fabric.main() == 2
    assert lanzados == []
    assert esperados == []
