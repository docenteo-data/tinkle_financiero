"""Tests de las funciones puras de generación del notebook Generar_txt_Balance_Saldos.

Las funciones se cargan desde la celda "FUNCIONES DE GENERACIÓN" del ipynb,
sin Spark: solo se compilan las definiciones que hacen falta.

Modos de fallo cubiertos:
- Un saldo casi cero (resto de coma flotante, por ejemplo 2.27e-12) cae en la
  columna del debe o del haber según el signo del resto, así que el mismo dato
  da TXT distintos.
- Se genera un fichero que no se ha pedido, o se acepta un nombre desconocido.
- Se generan ficheros de un periodo distinto del esperado.
- El periodo de Ageing (AAAA.M) no se reconoce como el AAAA.MM de los demás ficheros.
- Un importe de Ageing sale con notación científica, con ceros finales o con el signo de un cero.
- Una línea de Ageing pierde el ; final o se parte por un ; dentro del nombre del cliente.
- Ageing se genera sin pedirlo (el botón "Generar txt" no debe publicarlo con códigos provisionales).
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
NOMBRES_FUNCIONES = {
    "formato_numero_es",
    "linea_saldos",
    "ficheros_pedidos",
    "comprobar_periodo",
    "periodo_ageing_a_codigo",
    "formato_importe_ageing",
    "limpiar_nombre",
    "convertir_periodo_a_nombre",
    "obtener_nombre_sociedad",
    "generar_nombre_ageing",
    "cabecera_ageing",
    "linea_ageing",
}
NOMBRES_ASIGNACIONES = {"FICHEROS_DISPONIBLES", "FICHEROS_POR_DEFECTO", "MESES", "COLUMNAS_AGEING"}


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
    # Globales que en el notebook vienen de la celda de parámetros y de la ejecución.
    namespace = {
        "re": re,
        "NOMBRES_SOCIEDAD": {
            "ESP066": "TINKLE_COMM",
            "ESP067": "TINKLE_EU",
            "ESP068": "TINKLE_JAZZ",
            "ESP069": "TINKLE_ONION",
            "ESP070": "TINKLE_CONS",
        },
        "INCLUIR_TIMESTAMP": True,
        "TIMESTAMP_EJECUCION": "20260401_104852",
    }
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

    # Por defecto, solo los ficheros entregables: Ageing se pide expresamente.
    assert ficheros_pedidos("") == ambos
    assert ficheros_pedidos("   ") == ambos
    assert ficheros_pedidos("Balance") == {"Balance"}
    assert ficheros_pedidos(" Balance , Saldos_4_7 ") == ambos
    assert ficheros_pedidos("Ageing") == {"Ageing"}
    assert ficheros_pedidos("Balance,Ageing") == {"Balance", "Ageing"}

    with pytest.raises(ValueError):
        ficheros_pedidos("Revenue")
    with pytest.raises(ValueError):
        ficheros_pedidos("balance")


def test_periodo_ageing_a_codigo():
    periodo_ageing_a_codigo = _funcion("periodo_ageing_a_codigo")

    assert periodo_ageing_a_codigo("2026.3") == "2026.03"
    assert periodo_ageing_a_codigo("2026.12") == "2026.12"
    assert periodo_ageing_a_codigo("2026.03") == "2026.03"

    for invalido in ("2026-3", "2026.13", "2026.0", "26.3", ""):
        with pytest.raises(ValueError):
            periodo_ageing_a_codigo(invalido)


@pytest.mark.parametrize(
    "valor, esperado",
    [
        (36.7401, "36.7401"),
        (0.847, "0.847"),
        (-11.5353, "-11.5353"),
        (0, "0"),
        (1, "1"),
        (2.27e-12, "0"),
        (-2.27e-12, "0"),
        (1234.5, "1234.5"),
    ],
)
def test_formato_importe_ageing(valor, esperado):
    formato_importe_ageing = _funcion("formato_importe_ageing")

    assert formato_importe_ageing(valor) == esperado


def test_formato_importe_ageing_acepta_decimal():
    from decimal import Decimal

    formato_importe_ageing = _funcion("formato_importe_ageing")

    assert formato_importe_ageing(Decimal("36.7401")) == "36.7401"
    assert formato_importe_ageing(Decimal("0.8470")) == "0.847"


def test_generar_nombre_ageing():
    generar_nombre_ageing = _funcion("generar_nombre_ageing")

    esperados = {
        "ESP066": "TINKLE_COMM",
        "ESP067": "TINKLE_EU",
        "ESP068": "TINKLE_JAZZ",
        "ESP069": "TINKLE_ONION",
        "ESP070": "TINKLE_CONS",
    }
    for codigo, sociedad in esperados.items():
        assert generar_nombre_ageing(codigo, "2026.03") == f"{sociedad}_Ageing_MAR-26_20260401_104852.txt"


def test_cabecera_y_lineas_de_ageing():
    cabecera_ageing = _funcion("cabecera_ageing")
    linea_ageing = _funcion("linea_ageing")
    columnas = _cargar_funciones()["COLUMNAS_AGEING"]

    # 26 columnas en minúsculas y un ; final (columna 27 vacía), como el TXT de marzo.
    assert len(columnas) == 26
    assert cabecera_ageing() == (
        "d_ca;d_dp;d_ru;d_devtr;d_sajob;d_dim2;d_dim3;d_acty;d_client;d_pe;d_oru;d_ac;d_fl;"
        "d_au;d_t1;d_t2;d_cu;d_to;d_go;d_le;d_nu;d_dim4;d_dest;d_area;p_comment;p_amount;"
    )

    fila = {columna: "" for columna in columnas}
    fila.update(
        d_ca="C", d_dp="2026.3", d_ru="ESP066", d_client="IKEA", d_pe="2026.3",
        d_ac="MB4000", d_fl="GR0", d_au="0LIA01", d_cu="EUR", p_amount="36.7401",
    )
    assert linea_ageing(fila) == "C;2026.3;ESP066;;;;;;IKEA;2026.3;;MB4000;GR0;0LIA01;;;EUR;;;;;;;;;36.7401;"

    # Un ; o un salto de línea en el nombre del cliente no puede partir la línea.
    fila["d_client"] = "A;B\nC"
    linea = linea_ageing(fila)
    assert linea.count(";") == 26
    assert "\n" not in linea


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
