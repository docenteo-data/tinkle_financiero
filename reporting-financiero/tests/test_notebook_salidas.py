"""Tests de las funciones puras de generación del notebook Generar_txt_Balance_Saldos.

Las funciones se cargan desde la celda "FUNCIONES DE GENERACIÓN" del ipynb,
sin Spark: solo se compilan las definiciones que hacen falta.

Modos de fallo cubiertos:
- Un saldo casi cero (resto de coma flotante, por ejemplo 2.27e-12) cae en la
  columna del debe o del haber según el signo del resto, así que el mismo dato
  da TXT distintos.
- Se genera un fichero que no se ha pedido, o se acepta un nombre desconocido.
- Se generan ficheros de un periodo distinto del esperado.
"""

import ast
import functools
import json
import re
from pathlib import Path

import pytest

NOTEBOOK = (
    Path(__file__).resolve().parents[1]
    / "fabric"
    / "Generar_txt_Balance_Saldos.Notebook"
    / "notebook-content.ipynb"
)
MARCA_CELDA = "FUNCIONES DE GENERACIÓN"
NOMBRES_FUNCIONES = {"formato_numero_es", "linea_saldos", "ficheros_pedidos", "comprobar_periodo"}
NOMBRES_ASIGNACIONES = {"FICHEROS_DISPONIBLES"}


@functools.lru_cache(maxsize=None)
def _cargar_funciones() -> dict:
    """Compila las definiciones de la celda y devuelve su namespace."""
    with NOTEBOOK.open(encoding="utf-8") as fichero:
        notebook = json.load(fichero)

    fuente = None
    for celda in notebook["cells"]:
        if celda.get("cell_type") != "code":
            continue
        texto = "".join(celda["source"])
        if MARCA_CELDA in texto:
            fuente = texto
            break
    if fuente is None:
        pytest.fail(f'No se encuentra la celda "{MARCA_CELDA}" en {NOTEBOOK.name}')

    arbol = ast.parse(fuente)
    nodos = []
    for nodo in arbol.body:
        if isinstance(nodo, ast.FunctionDef) and nodo.name in NOMBRES_FUNCIONES:
            nodos.append(nodo)
        elif isinstance(nodo, ast.Assign) and any(
            isinstance(destino, ast.Name) and destino.id in NOMBRES_ASIGNACIONES
            for destino in nodo.targets
        ):
            nodos.append(nodo)

    modulo = ast.Module(body=nodos, type_ignores=[])
    namespace = {"re": re}
    exec(compile(modulo, str(NOTEBOOK), "exec"), namespace)
    return namespace


def _funcion(nombre: str):
    """Devuelve la función del notebook o falla con un mensaje claro si falta."""
    namespace = _cargar_funciones()
    if nombre not in namespace:
        pytest.fail(f'Falta la función {nombre} en la celda "{MARCA_CELDA}" del notebook')
    return namespace[nombre]


def test_saldo_casi_cero_es_cero():
    linea_saldos = _funcion("linea_saldos")

    positivo = linea_saldos("MAR.-26", "5550000", "Partidas", 2.27e-12)
    negativo = linea_saldos("MAR.-26", "5550000", "Partidas", -2.27e-12)
    cero = linea_saldos("MAR.-26", "5550000", "Partidas", 0.0)

    assert positivo == cero
    assert negativo == cero


def test_saldos_normales_no_cambian():
    linea_saldos = _funcion("linea_saldos")

    positivo = linea_saldos("MAR.-26", "5550000", "Partidas", 1234.5)
    assert "1.234,50" in positivo
    assert "(" not in positivo

    negativo = linea_saldos("MAR.-26", "5550000", "Partidas", -1234.5)
    assert negativo.endswith("(1.234,50)")

    # Redondeo a 2 decimales: 0.004 es un cero a efectos del TXT.
    assert linea_saldos("MAR.-26", "5550000", "Partidas", 0.004) == linea_saldos(
        "MAR.-26", "5550000", "Partidas", 0.0
    )

    # 0.0051 en vez de 0.005 para evitar el empate de coma flotante.
    assert "0,01" in linea_saldos("MAR.-26", "5550000", "Partidas", 0.0051)


def test_ficheros_pedidos():
    ficheros_pedidos = _funcion("ficheros_pedidos")
    ambos = {"Balance", "Saldos_4_7"}

    assert ficheros_pedidos("") == ambos
    assert ficheros_pedidos("   ") == ambos
    assert ficheros_pedidos("Balance") == {"Balance"}
    assert ficheros_pedidos(" Balance , Saldos_4_7 ") == ambos

    with pytest.raises(ValueError):
        ficheros_pedidos("Ageing")
    with pytest.raises(ValueError):
        ficheros_pedidos("balance")


def test_comprobar_periodo():
    comprobar_periodo = _funcion("comprobar_periodo")

    comprobar_periodo("", {"2026.03"})
    comprobar_periodo("2026.03", {"2026.03"})

    with pytest.raises(ValueError) as excinfo:
        comprobar_periodo("2026.04", {"2026.03"})
    assert "2026.03" in str(excinfo.value)

    with pytest.raises(ValueError):
        comprobar_periodo("2026-03", {"2026.03"})

    with pytest.raises(ValueError):
        comprobar_periodo("2026.03", {"2026.03", "2026.02"})
