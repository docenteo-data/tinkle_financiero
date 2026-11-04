"""Cobertura de la orquestación de Fabric descrita en vault/adrs/0001-orquestacion-y-vistas-de-salida.md.

Este fichero irá creciendo con una prueba por pipeline: cada pipeline que cambie de
vistas de salida o de orquestación añade aquí sus comprobaciones.

Modos de fallo cubiertos:
- El notebook de ficheros sigue leyendo las vistas del esquema 200 en lugar de las del 300.
- Las vistas de salida no están en el esquema 300, o siguen existiendo las del 200.
- Un pipeline modular pierde una dependencia, de modo que un paso arranca antes de que termine el anterior.
- Un pipeline modular encadena un paso con "Completed" en lugar de "Succeeded", así que avanza aunque el anterior haya fallado.
- Un pipeline modular cambia su número de actividades o algún identificador de dataflow, endpoint SQL o modelo semántico.
- Un pipeline modular se aparta de la política actual de la actividad: reintentos distintos de 0 o timeout distinto de "0.12:00:00".
- Generar_salidas no declara los parámetros "ficheros" y "periodo_esperado" como string con defaultValue vacío.
- Generar_salidas no tiene exactamente dos actividades, el notebook no es NOTEBOOK_SALIDAS, o la Copy no depende de él con "Succeeded".
- El notebook de Generar_salidas no pasa "ficheros" y "periodo_esperado" desde los parámetros del pipeline, o los pasa con otro tipo.
- La Copy de Generar_salidas se aparta de la de "Grabar salidas" (origen, filtro *.txt o destino en SharePoint).
- Las actividades de Generar_salidas se apartan de la política: reintentos distintos de 0 o timeout distinto de "0.12:00:00".
- Flujo_actualizar_datos no ejecuta Ingesta_datos y después Transformacion_datos, en ese orden, o usa otros ids de pipeline.
- Flujo_total_reporting no termina en Refresco_modelos, o no arranca con Flujo_actualizar_datos (o, si no se anida, con Ingesta y Transformación).
- Flujo_total_txt no termina en Generar_salidas, o no arranca como Flujo_total_reporting.
- Un flujo encadena con "Completed" en lugar de "Succeeded", tiene una actividad que no es ExecutePipeline, no espera a que termine el hijo (waitOnCompletion distinto de true), o usa reintentos distintos de 0.
- Un flujo bifurca: tiene más de una actividad sin dependencias, o una actividad que depende de varias o de una que no es la anterior en la cadena.
"""

import json
import re
from pathlib import Path

PROYECTO = Path(__file__).resolve().parents[1]
FABRIC = PROYECTO / "fabric"
NOTEBOOK = FABRIC / "Generar_txt_Balance_Saldos.Notebook" / "notebook-content.ipynb"

INGESTA_CARGA = "c8d12168-9a15-4df6-8632-eb647c58a861"
INGESTA_MAESTROS = "60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6"
TRANS_SILVER = "e34a567e-3986-467e-ac59-9c89b8014b87"
TRANS_GOLD = "2ddb6bc7-1a91-490f-9a6b-60ade6940b4e"
FINANCIAL_MODEL = "847ce270-06ab-408b-85c9-cb8f390fad1c"
AGINGS = "e19def87-fdf3-4b44-bd60-d22e5d79ce88"
SQL_ENDPOINT = "485f1bd4-2372-44a3-b279-e00a63a80137"
NOTEBOOK_SALIDAS = "c649ae24-2b54-4fce-bd5c-d23a9516ec37"

PIPE_INGESTA = "8eb0c2ee-0848-4caa-a30e-632663d69a9d"
PIPE_TRANSFORMACION = "443f4608-28f6-4f51-b42d-15c3e8e08378"
PIPE_REFRESCO = "6800d0a7-23cc-46c6-a596-00401465aaa2"
PIPE_SALIDAS = "919cfea3-9513-4c10-a90b-26c2b21e493a"
FLUJO_ACTUALIZAR = "7f86c295-fa58-49c5-a199-fd1fca7b0795"

PIPELINES_MODULARES = ["Ingesta_datos", "Transformacion_datos", "Refresco_modelos"]


def actividades(nombre):
    ruta = FABRIC / f"{nombre}.DataPipeline" / "pipeline-content.json"
    contenido = json.loads(ruta.read_text(encoding="utf-8"))
    return contenido["properties"]["activities"]


def por_id(acts, tipo, clave, valor):
    coincidencias = [
        a for a in acts if a["type"] == tipo and a["typeProperties"].get(clave) == valor
    ]
    assert len(coincidencias) == 1, f"{tipo} con {clave}={valor}: {len(coincidencias)}"
    return coincidencias[0]


def depende_de(act):
    return {d["activity"]: d["dependencyConditions"] for d in act["dependsOn"]}


def cadena(nombre):
    """Comprueba un flujo de ExecutePipeline encadenado linealmente y devuelve sus pipelines hijos en orden."""
    acts = actividades(nombre)
    for act in acts:
        etiqueta = f"{nombre} / {act['name']}"
        assert act["type"] == "ExecutePipeline", etiqueta
        assert act["typeProperties"]["waitOnCompletion"] is True, etiqueta
        assert act["typeProperties"]["pipeline"]["type"] == "PipelineReference", etiqueta
        assert act["policy"]["retry"] == 0, etiqueta

    raices = [a for a in acts if not a["dependsOn"]]
    assert len(raices) == 1, f"{nombre}: {len(raices)} actividades sin dependencias"
    orden = [raices[0]]
    while len(orden) < len(acts):
        anterior = orden[-1]
        siguientes = [a for a in acts if depende_de(a) == {anterior["name"]: ["Succeeded"]}]
        assert len(siguientes) == 1, f"{nombre}: {len(siguientes)} actividades tras {anterior['name']}"
        orden.append(siguientes[0])
    return [a["typeProperties"]["pipeline"]["referenceName"] for a in orden]


def codigo_notebook():
    """Solo el código de las celdas: las salidas guardadas de ejecuciones anteriores no cuentan."""
    celdas = json.loads(NOTEBOOK.read_text(encoding="utf-8"))["cells"]
    return "\n".join("".join(c["source"]) for c in celdas if c["cell_type"] == "code")


def test_ficheros_leen_vistas_de_300():
    # El notebook monta el nombre como f"{LAKEHOUSE}.{ESQUEMA}.{VISTA}": lo que manda es ESQUEMA.
    codigo = codigo_notebook()
    assert re.search(r'^ESQUEMA\s*=\s*"300"', codigo, re.M), "ESQUEMA no es 300"
    assert re.search(r'^VISTA_BALANCE\s*=\s*"vw_Export_Grupo"', codigo, re.M)
    assert re.search(r'^VISTA_SALDOS\s*=\s*"vw_Export_Saldos_4_7"', codigo, re.M)
    assert "200.vw_Export" not in codigo


def test_vistas_de_salida_en_300():
    assert (FABRIC / "sql" / "300.vw_Export_Grupo.sql").exists()
    assert (FABRIC / "sql" / "300.vw_Export_Saldos_4_7.sql").exists()
    assert not (FABRIC / "sql" / "200.vw_Export_Grupo.sql").exists()
    assert not (FABRIC / "sql" / "200.vw_Export_Saldos_4_7.sql").exists()


def test_ingesta_datos():
    acts = actividades("Ingesta_datos")
    assert len(acts) == 3
    maestros = por_id(acts, "RefreshDataflow", "dataflowId", INGESTA_MAESTROS)
    carga = por_id(acts, "RefreshDataflow", "dataflowId", INGESTA_CARGA)
    assert depende_de(maestros) == {}
    assert depende_de(carga) == {}
    endpoint = por_id(acts, "RefreshSqlEndpoint", "sqlEndpointId", SQL_ENDPOINT)
    assert depende_de(endpoint) == {
        maestros["name"]: ["Succeeded"],
        carga["name"]: ["Succeeded"],
    }


def test_transformacion_datos():
    acts = actividades("Transformacion_datos")
    assert len(acts) == 4
    silver = por_id(acts, "RefreshDataflow", "dataflowId", TRANS_SILVER)
    assert depende_de(silver) == {}
    endpoints = [a for a in acts if a["type"] == "RefreshSqlEndpoint"]
    assert len(endpoints) == 2
    assert all(e["typeProperties"]["sqlEndpointId"] == SQL_ENDPOINT for e in endpoints)
    # Los dos endpoints tienen el mismo id: se distinguen por su dependencia.
    tras_silver = [e for e in endpoints if depende_de(e) == {silver["name"]: ["Succeeded"]}]
    assert len(tras_silver) == 1
    gold = por_id(acts, "RefreshDataflow", "dataflowId", TRANS_GOLD)
    assert depende_de(gold) == {tras_silver[0]["name"]: ["Succeeded"]}
    tras_gold = [e for e in endpoints if depende_de(e) == {gold["name"]: ["Succeeded"]}]
    assert len(tras_gold) == 1


def test_refresco_modelos():
    acts = actividades("Refresco_modelos")
    assert len(acts) == 2
    financiero = por_id(acts, "PBISemanticModelRefresh", "datasetId", FINANCIAL_MODEL)
    agings = por_id(acts, "PBISemanticModelRefresh", "datasetId", AGINGS)
    assert depende_de(financiero) == {}
    assert depende_de(agings) == {}


def test_pipelines_modulares_sin_reintentos_ni_completed():
    for nombre in PIPELINES_MODULARES:
        for act in actividades(nombre):
            etiqueta = f"{nombre} / {act['name']}"
            for dep in act["dependsOn"]:
                for condicion in dep["dependencyConditions"]:
                    assert condicion == "Succeeded", f"{etiqueta}: {condicion}"
            assert act["policy"]["retry"] == 0, etiqueta
            assert act["policy"]["timeout"] == "0.12:00:00", etiqueta


def test_generar_salidas():
    ruta = FABRIC / "Generar_salidas.DataPipeline" / "pipeline-content.json"
    contenido = json.loads(ruta.read_text(encoding="utf-8"))
    parametros = contenido["properties"]["parameters"]
    for nombre in ["ficheros", "periodo_esperado"]:
        assert parametros[nombre]["type"].lower() == "string", nombre
        assert parametros[nombre]["defaultValue"] == "", nombre

    acts = actividades("Generar_salidas")
    assert len(acts) == 3
    notebook = por_id(acts, "TridentNotebook", "notebookId", NOTEBOOK_SALIDAS)
    assert depende_de(notebook) == {}
    copia = [a for a in acts if a["type"] == "Copy" and a["name"] != "Copiar Ageing a SharePoint"]
    assert len(copia) == 1
    assert depende_de(copia[0]) == {notebook["name"]: ["Succeeded"]}

    pasados = notebook["typeProperties"]["parameters"]
    for nombre in ["ficheros", "periodo_esperado"]:
        assert pasados[nombre]["value"]["value"] == f"@pipeline().parameters.{nombre}", nombre
        assert pasados[nombre]["value"]["type"] == "Expression", nombre
        assert pasados[nombre]["type"] == "string", nombre

    grabar_balance = next(
        a for a in actividades("Grabar salidas") if a["name"] == "Grabar balance"
    )
    assert copia[0]["typeProperties"] == grabar_balance["typeProperties"]

    for act in acts:
        etiqueta = f"Generar_salidas / {act['name']}"
        assert act["policy"]["retry"] == 0, etiqueta
        assert act["policy"]["timeout"] == "0.12:00:00", etiqueta


def test_generar_salidas_copia_ageing():
    """Ageing tiene su propia Copy: igual que la de Balance, con su carpeta de origen y de destino."""
    acts = actividades("Generar_salidas")
    notebook = por_id(acts, "TridentNotebook", "notebookId", NOTEBOOK_SALIDAS)
    balance = next(a for a in acts if a["name"] == "Copiar a SharePoint")
    ageing = next(a for a in acts if a["name"] == "Copiar Ageing a SharePoint")

    assert ageing["type"] == "Copy"
    assert depende_de(ageing) == {notebook["name"]: ["Succeeded"]}
    assert ageing["policy"] == balance["policy"]

    origen = ageing["typeProperties"]["source"]["storeSettings"]
    assert origen["wildcardFolderPath"] == "Exportaciones/Ageing"
    assert origen["wildcardFileName"] == "*.txt"
    assert origen["recursive"] is True
    destino = ageing["typeProperties"]["sink"]["datasetSettings"]["typeProperties"]["location"]
    assert destino["folderPath"] == "Shared Documents/Reporting Financiero/2. Salida de ficheros/Ageing"

    # Solo cambian esas dos rutas: conexiones y el resto de ajustes son los de la copia de Balance.
    esperado = json.loads(json.dumps(balance["typeProperties"]))
    esperado["source"]["storeSettings"]["wildcardFolderPath"] = "Exportaciones/Ageing"
    esperado["sink"]["datasetSettings"]["typeProperties"]["location"]["folderPath"] = destino["folderPath"]
    assert ageing["typeProperties"] == esperado


def test_ageing_vista_y_notebook():
    codigo = codigo_notebook()
    assert re.search(r'^VISTA_AGEING\s*=\s*"vw_Export_Ageing"', codigo, re.M)
    assert (FABRIC / "sql" / "300.vw_Export_Ageing.sql").exists()
    assert not (FABRIC / "sql" / "200.vw_Export_Ageing.sql").exists()


def test_flujo_actualizar_datos():
    assert cadena("Flujo_actualizar_datos") == [PIPE_INGESTA, PIPE_TRANSFORMACION]


def test_flujo_total_reporting():
    # Si Fabric no permite anidar flujos, el primer paso son Ingesta y Transformación directamente.
    c = cadena("Flujo_total_reporting")
    assert c[-1] == PIPE_REFRESCO
    assert c[:-1] in ([FLUJO_ACTUALIZAR], [PIPE_INGESTA, PIPE_TRANSFORMACION])


def test_flujo_total_txt():
    c = cadena("Flujo_total_txt")
    assert c[-1] == PIPE_SALIDAS
    assert c[:-1] in ([FLUJO_ACTUALIZAR], [PIPE_INGESTA, PIPE_TRANSFORMACION])
