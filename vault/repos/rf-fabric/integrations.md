---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*.Dataflow/mashup.pq", "*.SemanticModel/definition/expressions.tmdl", "*.Notebook/**", "Grabar salidas.DataPipeline/**", "Agings.SemanticModel/definition/tables/**"]
tags: [rf-fabric, integrations]
---

# rf-fabric - Integrations

> Cuándo cargar: necesitas saber de dónde llegan los ficheros Excel y CSV, qué lakehouse o SharePoint usa el workspace y dónde sale el balance.

## Origen de ficheros

- Entrada: carpeta `Reporting Financiero` en Files del lakehouse `lh_tinkle_financiero`, que es un shortcut hacia OneDrive/SharePoint. Subcarpetas usadas en `1. Entrada de Datos`: `Arranque` (cargas iniciales), `Dinamicos` (cargas recurrentes, con subcarpeta `AGINGS`) y `Maestros` (maestros y mapeos).
- Salida: biblioteca `Shared Documents` de SharePoint, carpeta `Reporting Financiero/2. Salida de ficheros/Balance`.
- TBD: sitio, biblioteca y cuenta exactos del shortcut de entrada (no figuran en las fuentes revisadas).

## Ficheros leídos por dataflow

Solo nombres de fichero y hoja. Las consultas localizan los ficheros por texto del nombre, salvo donde se indica.

- `INGESTA_Carga_Datos` (carpeta `Dinamicos`):
  - Excel con "MMS" en el nombre, hoja `Datos`.
  - CSV con "Oracle" en el nombre, leídos uno a uno.
  - Excel con "PTG-Tinkle_Extratos de contas" en el nombre (.xlsx o .xls), hoja `Sheet`.
  - Excel con "HAPA-Asientos" en el nombre, hoja `Hoja1`.
  - Excel con "Aging proveedores" (hoja `Datos`) y "Aging clientes" (hoja `HMES___Aging_en_Detalle_todas__`), en `AGINGS`.
- `INGESTA_Maestros` (carpeta `Maestros`): `Maestros.xlsx` con hojas `CDC`, `Clientes`, `COA Oracle`, `MAPPING HAPA` y `MAPPING PORTUGAL`; `MASTER RRHH 2026 .xlsx` con hoja `MASTER`.
- `INICIAL_Carga_Agings` (carpeta `Arranque`): `2026 03 31- AGING Clientes Grupo Tinkle TOTAL HMES.xlsx` (hoja `DATOS`) y `2026 03 31(01) Cartera Prov - TOTAL.xlsx` (hoja `Datos`).
- `INICIAL_Carga_Oracle` (`Arranque`): `1-Checklist 2026 03(v11) - copia.xlsm`, hoja `Oracle`.
- `INICIAL_Carga_budget_fct` (`Arranque`): el mismo checklist, hojas `B01 CONS`, `B01 JAZZ`, `B01 ONION` y `B01 PORT`; y `TINKLE FORECAST 2026 FT3.xlsm`, hojas de sociedad (ESP066 COMMUNICATIONS, ESP067 EUROPEAN, ESP068 JAZZ, ...).
- `INICIAL_Carga_Revenues` (`Arranque`): `Revenue 2026 FT3.xlsx`, hojas cuyo nombre contiene "Revenue by".
- `INICIAL_Carga_Rentabilidades` (`Arranque/RENTABILIDAD`): libros .xlsx o .xlsm cuyo nombre contiene "RENTABILIDAD". Lista dinámica, sin nombres fijos.
- `TRANS_Silver` y `TRANS_Gold` leen tablas del lakehouse; `Seguridad_CDC` no lee ningún origen (tabla literal).

Destino de todos los dataflows: tablas del lakehouse `lh_tinkle_financiero`, en los esquemas `100` (tablas New_* y RLS), `200` (históricos y mapeos) y `300` (Gold, dimensiones y hechos).

## Modelos semánticos y lakehouse

- `Financial Model`: expresión `DirectLake - lh_tinkle_financiero`, que abre el lakehouse por OneLake con `AzureStorage.DataLake` (modo Direct Lake).
- `Agings.SemanticModel`: no tiene `expressions.tmdl`. Cada tabla de facturas se conecta por su propia partición import al SQL analytics endpoint de `lh_tinkle_financiero`, esquema `200`.
- El notebook lee dos vistas del esquema `200` por el SQL analytics endpoint del lakehouse (`vw_Export_Grupo`, `vw_Export_Saldos_4_7`).

## Notebook y pipeline de salida

- Notebook `Generar_txt_Balance_Saldos` (PySpark): lee las dos vistas y escribe en Files del lakehouse, en `Exportaciones/Balance/<periodo>/`, ficheros .txt por sociedad: balance (separador ";") y saldos 4_7 (líneas de texto).
- Pipeline `Grabar salidas`: actividad 1, el notebook. Actividad 2, Copy "Grabar balance": copia `Exportaciones/Balance/**/*.txt` del lakehouse a SharePoint, preservando la jerarquía.
- Observación: la carpeta de destino se llama `Balance`, pero el filtro `*.txt` recoge también los saldos 4_7.

## Planning y CPM

- No aparece Planning ni CPM en las definiciones revisadas del repositorio.

## Señales para el grafo

- Infraestructura: lakehouse `lh_tinkle_financiero`, SQL analytics endpoint, OneLake, SharePoint Online (`Shared Documents`), OneDrive/SharePoint (origen por shortcut), workspace "Tinkle - Financiero".
- Tecnologías: Power Query (Dataflows), Direct Lake, Spark (notebook PySpark), Power BI (modelos semánticos), Data Pipeline, Excel, CSV.

## Evidence

- `INGESTA_Carga_Datos.Dataflow/mashup.pq` - fuentes Excel y CSV de `Dinamicos` y destinos en el esquema `100`.
- `INGESTA_Maestros.Dataflow/mashup.pq` - `Maestros.xlsx` y `MASTER RRHH 2026 .xlsx`.
- `INICIAL_Carga_Agings.Dataflow/mashup.pq`, `INICIAL_Carga_Oracle.Dataflow/mashup.pq`, `INICIAL_Carga_budget_fct.Dataflow/mashup.pq`, `INICIAL_Carga_Revenues.Dataflow/mashup.pq`, `INICIAL_Carga_Rentabilidades.Dataflow/mashup.pq` - cargas iniciales desde `Arranque`.
- `TRANS_Silver.Dataflow/mashup.pq`, `TRANS_Gold.Dataflow/mashup.pq` - lectura de tablas del lakehouse.
- `Seguridad_CDC.Dataflow/mashup.pq` - consulta RLS como tabla literal, sin origen, con destino en el esquema `100`.
- `Financial Model.SemanticModel/definition/expressions.tmdl` - expresión Direct Lake.
- `Agings.SemanticModel/definition/tables/200 Aging_Clientes.tmdl` y `Agings.SemanticModel/definition/tables/200 Aging_Proveedores.tmdl` - particiones import sobre el esquema `200`.
- `Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` - lectura de vistas y escritura en Files.
- `Grabar salidas.DataPipeline/pipeline-content.json` - notebook y copia a SharePoint.

## Open questions

- TBD: sitio, biblioteca y cuenta del shortcut `Reporting Financiero` (OneDrive personal de la cuenta de reporting o SharePoint).
- TBD: nombres de los libros de `INICIAL_Carga_Rentabilidades`, que se listan en tiempo de ejecución.
