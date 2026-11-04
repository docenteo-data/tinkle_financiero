"""Tests de la creación de items con publicar_fabric.py --crear, sin conexión a Fabric.

Modos de fallo cubiertos:
- Se crea un item sin pedirlo con --crear.
- La simulación crea el item.
- Se crea un item que main ya tenía (alguien lo borró en Fabric).
- La creación sube el .platform o no espera a que termine.
- --crear cambia el comportamiento con items que ya existen.
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import fabric_comun as fc  # noqa: E402
import publicar_fabric  # noqa: E402


PLATFORM = b'{"metadata": {"type": "DataPipeline"}}'
PIPELINE = b'{"activities": []}'
EXISTE_MAIN = b'{"v": 1}'
EXISTE_RAMA = b'{"v": 2}'

ITEM_EXISTE = {"displayName": "Existe", "type": "DataPipeline", "id": "e1"}
FICHEROS_EXISTE = {"Existe.DataPipeline/pipeline-content.json": EXISTE_MAIN}
FICHEROS_NUEVO = {
    "Nuevo.DataPipeline/.platform": PLATFORM,
    "Nuevo.DataPipeline/pipeline-content.json": PIPELINE,
}


def test_crear_item_construye_la_peticion(monkeypatch):
    llamadas = []

    def peticion(metodo, url, *args, **kwargs):
        llamadas.append((metodo, url, kwargs.get("cuerpo", args[1] if len(args) > 1 else None)))
        return 201, {}, None

    def no_debe_esperar(*args, **kwargs):
        raise AssertionError("una creación con 201 no espera a ninguna operación")

    monkeypatch.setattr(fc, "peticion", peticion)
    monkeypatch.setattr(fc, "esperar_operacion", no_debe_esperar)

    fc.crear_item("Nuevo", "DataPipeline", {".platform": b"x", "pipeline-content.json": b"{}"}, "tok")

    assert len(llamadas) == 1
    metodo, url, cuerpo = llamadas[0]
    assert metodo == "POST"
    assert url == f"{fc.API}/workspaces/{fc.WORKSPACE_ID}/items"
    assert cuerpo["displayName"] == "Nuevo"
    assert cuerpo["type"] == "DataPipeline"
    # El .platform no se sube; solo el resto de ficheros de la definición.
    assert [parte["path"] for parte in cuerpo["definition"]["parts"]] == ["pipeline-content.json"]
    # DataPipeline no tiene formato, así que la petición no lo lleva.
    assert "format" not in cuerpo["definition"]


def test_crear_item_espera_si_la_creacion_es_asincrona(monkeypatch):
    esperas = []

    def peticion(metodo, url, *args, **kwargs):
        return 202, {"x-ms-operation-id": "op"}, None

    def esperar_operacion(cabeceras, tok, con_resultado):
        esperas.append((cabeceras, con_resultado))

    monkeypatch.setattr(fc, "peticion", peticion)
    monkeypatch.setattr(fc, "esperar_operacion", esperar_operacion)

    fc.crear_item("Nuevo", "DataPipeline", {"pipeline-content.json": b"{}"}, "tok")

    assert len(esperas) == 1
    cabeceras, con_resultado = esperas[0]
    assert cabeceras == {"x-ms-operation-id": "op"}
    assert con_resultado is False


def _preparar(monkeypatch, argv, en_rama, en_main):
    """Sustituye la red y git por datos en memoria. Devuelve el registro de creaciones y publicaciones."""
    registro = {"creados": [], "publicados": []}

    def ficheros_en_git(ref, *args, **kwargs):
        if ref == "rama":
            return dict(en_rama)
        if ref == "main":
            return dict(en_main)
        raise AssertionError("ref inesperada: " + ref)

    def descargar_definicion(item, tok):
        # Fabric tiene para Existe lo mismo que main.
        prefijo = fc.nombre_carpeta(item) + "/"
        return {ruta[len(prefijo):]: c for ruta, c in en_main.items() if ruta.startswith(prefijo)}

    def crear_item(nombre, tipo, ficheros, tok):
        registro["creados"].append((nombre, tipo, ficheros, tok))

    def publicar_definicion(item, ficheros, tok):
        registro["publicados"].append((item, ficheros, tok))

    monkeypatch.setattr(fc, "comprobar_cuenta", lambda: "persona@x")
    monkeypatch.setattr(fc, "token", lambda *args, **kwargs: "tok")
    monkeypatch.setattr(fc, "items", lambda tok: [dict(ITEM_EXISTE)])
    monkeypatch.setattr(fc, "ficheros_en_git", ficheros_en_git)
    monkeypatch.setattr(fc, "descargar_definicion", descargar_definicion)
    monkeypatch.setattr(fc, "publicar_definicion", publicar_definicion)
    monkeypatch.setattr(fc, "crear_item", crear_item, raising=False)
    monkeypatch.setattr(sys, "argv", ["publicar_fabric.py"] + argv)
    return registro


def test_sin_crear_un_item_nuevo_es_error(monkeypatch):
    registro = _preparar(
        monkeypatch,
        ["Nuevo.DataPipeline", "--ref", "rama", "--confirmar"],
        en_rama={**FICHEROS_EXISTE, **FICHEROS_NUEVO},
        en_main=dict(FICHEROS_EXISTE),
    )
    assert publicar_fabric.main() == 2
    assert registro["creados"] == []
    assert registro["publicados"] == []


def test_simulacion_de_crear_no_escribe(monkeypatch):
    registro = _preparar(
        monkeypatch,
        ["Nuevo.DataPipeline", "--ref", "rama", "--crear"],
        en_rama={**FICHEROS_EXISTE, **FICHEROS_NUEVO},
        en_main=dict(FICHEROS_EXISTE),
    )
    assert publicar_fabric.main() == 0
    assert registro["creados"] == []
    assert registro["publicados"] == []


def test_crear_item_nuevo(monkeypatch):
    registro = _preparar(
        monkeypatch,
        ["Nuevo.DataPipeline", "--ref", "rama", "--crear", "--confirmar"],
        en_rama={**FICHEROS_EXISTE, **FICHEROS_NUEVO},
        en_main=dict(FICHEROS_EXISTE),
    )
    assert publicar_fabric.main() == 0
    assert registro["creados"] == [
        ("Nuevo", "DataPipeline", {".platform": PLATFORM, "pipeline-content.json": PIPELINE}, "tok"),
    ]
    assert registro["publicados"] == []


def test_crear_rechaza_un_item_que_main_tenia(monkeypatch):
    # Nuevo está en main, pero alguien lo ha borrado en Fabric: no se recrea sin --forzar.
    registro = _preparar(
        monkeypatch,
        ["Nuevo.DataPipeline", "--ref", "rama", "--crear", "--confirmar"],
        en_rama={**FICHEROS_EXISTE, **FICHEROS_NUEVO},
        en_main={**FICHEROS_EXISTE, **FICHEROS_NUEVO},
    )
    assert publicar_fabric.main() == 1
    assert registro["creados"] == []
    assert registro["publicados"] == []


def test_crear_no_cambia_items_existentes(monkeypatch):
    registro = _preparar(
        monkeypatch,
        ["Existe.DataPipeline", "--ref", "rama", "--crear", "--confirmar"],
        en_rama={"Existe.DataPipeline/pipeline-content.json": EXISTE_RAMA},
        en_main=dict(FICHEROS_EXISTE),
    )
    assert publicar_fabric.main() == 0
    assert len(registro["publicados"]) == 1
    item, ficheros, _ = registro["publicados"][0]
    assert item["id"] == "e1"
    assert ficheros == {"pipeline-content.json": EXISTE_RAMA}
    assert registro["creados"] == []
