---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*.DataPipeline/**", "*.Dataflow/queryMetadata.json", "*.Dataflow/mashup.pq"]
tags: [rf-fabric, architecture]
---

# rf-fabric - Architecture

> Cuándo cargar: necesitas saber qué dataflow escribe en qué capa del lakehouse, el orden de los pipelines Generar Reporting y Grabar salidas, o qué modelos semánticos se refrescan.

## Capas medallion

El lakehouse `lh_tinkle_financiero` organiza los datos en tres esquemas:

- 100 bruto: datos tal como llegan de los orígenes (Oracle, MMS, HAPA, Agings, Portugal, extracto de cuentas PT). Lo escriben las consultas `Carga_New_*` de INGESTA_Carga_Datos (New_Agings_Clientes, New_Agings_Proveedores, New_HAPA, New_MMS, New_Oracle y New_PT_extrato_contas) y la consulta RLS de Seguridad_CDC.
- 200 silver: datos transformados. Lo escriben TRANS_Silver (consultas `200_*`), INGESTA_Maestros (mapeos y COA_Oracle) y las cargas INICIAL_* históricas.
- 300 gold: modelo analítico (hechos y dimensiones). Lo escribe TRANS_Gold (Fact_Actuals, Dim_Cuentas, Dim_mapeo_cuentas), que lee consultas `200_*`. INGESTA_Maestros escribe las dimensiones y auxiliares, e INICIAL_Carga_Rentabilidades escribe Fact_Asignacion_RRHH y Dim_equipos.

## Dataflows

Los dataflows de ingesta y de apoyo siguen el patrón de nombre de la carpeta. El nombre interno de algunos no coincide con la carpeta: INGESTA_Carga_Datos figura como INGESTA_Carga_Oracle, INGESTA_Maestros como INGESTAS INICIALES y TRANS_Silver como TRANS_Carga_datos.

- INGESTA_Carga_Datos: consultas `Carga_New_*` (Oracle, MMS, HAPA asientos, Agings proveedores y clientes). Es el dataflow de ingesta principal. `Carga_New_HAPA_asientos` escribe en 100.New_HAPA mediante `Carga_HAPA_asientos_DataDestination`. La auditoría de septiembre (apartados 5.2, 5.5 y N2 del documento de arquitectura) decía que New_HAPA no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta.
- INGESTA_Maestros: escribe en 200 (`Mapping_HAPA`, `Mapping Portugal`, `COA_Oracle`) y en 300 (`Dim_CDC`, `Dim_Calendar`, `Dim_Clientes`, `Dim_Sociedades`, `Dim_RRHH`, `Dim_Report_Line`, `Map_Report_Line_Account`, `Aux_CDC`). `Assets_Reporte`, `Liabilities_Reporte`, `PL_Reporte` y sus variantes `*_Cuentas` no tienen destino.
- INICIAL_Carga_Oracle: carga histórica de Oracle desde Checklist.
- INICIAL_Carga_Agings: histórico de agings de clientes y proveedores.
- INICIAL_Carga_Rentabilidades: escribe Fact_Asignacion_RRHH y Dim_equipos. Su consulta Dim_CDC solo lee 300.Dim_CDC.
- INICIAL_Carga_Revenues: histórico de revenues y revenue por cliente FT3 2026.
- INICIAL_Carga_budget_fct: budget B01 (JAZZ, ONION, PORT, CONS), total checklist y forecasts y budget.
- TRANS_Silver: transformaciones a capa 200.
- TRANS_Gold: transformaciones a capa 300 (Fact_Actuals, Dim_Cuentas, Dim_mapeo_cuentas).
- Seguridad_CDC: consulta RLS como tabla literal (sin origen) que escribe en 100.RLS mediante `RLS_DataDestination`. Declara otra conexión de tipo Lakehouse, pero navega al mismo lakehouse `lh_tinkle_financiero`, esquema 100. La auditoría de septiembre (apartados 5.2, 5.5 y N3 del documento de arquitectura) decía que no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta.

Los INICIAL_*, INGESTA_Maestros y Seguridad_CDC no aparecen en ninguno de los dos pipelines. Cómo y cuándo se ejecutan: TBD.

Las consultas `*_DataDestination` son destinos ocultos generados por el propio dataflow. Una consulta escribe en una tabla si en `mashup.pq` lleva la anotación `DataDestinations` hacia una consulta `*_DataDestination`. `loadEnabled` es false en todas, así que no sirve para distinguirlas.

## Pipeline Generar Reporting

Reintentos a 0 y timeout de 12 horas en todas las actividades. Orden de ejecución:

1. Carga: refresco del dataflow INGESTA_Carga_Datos, sin dependencias. Solo ejecuta consultas de mashup.
2. RefreshSqlEndpoint1_copy1: refresca el endpoint SQL del lakehouse. Se ejecuta si Carga termina con Succeeded.
3. Transformaciones SILVER: refresco de TRANS_Silver. Se ejecuta si el paso 2 termina con Succeeded.
4. RefreshSqlEndpoint1: refresca de nuevo el endpoint SQL. Se ejecuta si SILVER termina con Succeeded.
5. Transformaciones GOLD: refresco de TRANS_Gold. Se ejecuta si el paso 4 termina con Succeeded.
6. Semantic model refresh1: refresco del modelo Financial Model. Se ejecuta cuando GOLD termina en cualquier estado (Completed), también si falla.
7. Semantic model refresh1_copy1: refresco del modelo Agings. Se ejecuta cuando el paso 6 termina en cualquier estado (Completed).

El flujo es lineal: orígenes, ingesta a 100, transformación a 200, transformación a 300, endpoint SQL y modelos semánticos.

Programación del pipeline (horario o disparo manual): TBD, no está en la definición.

## Pipeline Grabar salidas

1. Notebook1: ejecuta el notebook Generar_txt_Balance_Saldos. Sin dependencias.
2. Grabar balance: copia recursiva de los ficheros .txt de `Files/Exportaciones/Balance` del lakehouse a SharePoint, carpeta Reporting Financiero, Salida de ficheros, Balance, preservando la jerarquía. Se ejecuta si Notebook1 termina con Succeeded.

Este pipeline no toca el lakehouse de capas ni los modelos: solo exporta ficheros.

## Modelos semánticos

- Los dos refrescos de modelo del pipeline Generar Reporting son Financial Model (paso 6) y Agings (paso 7). Las carpetas del repositorio son Agings.SemanticModel y Financial Model.SemanticModel.

## Evidence

- `Generar Reporting.DataPipeline/pipeline-content.json` - actividades, dependencias y tipos del pipeline de reporting.
- `Generar Reporting.DataPipeline/.platform` - nombre del item y logicalId a cero.
- `Grabar salidas.DataPipeline/pipeline-content.json` - notebook, copia a SharePoint y dependencia.
- `INGESTA_Carga_Datos.Dataflow/queryMetadata.json` - consultas Carga_New_*.
- `INGESTA_Maestros.Dataflow/queryMetadata.json` - mapeos, dimensiones y consultas de informes.
- `INICIAL_Carga_Agings.Dataflow/queryMetadata.json`, `INICIAL_Carga_Oracle.Dataflow/queryMetadata.json`, `INICIAL_Carga_Rentabilidades.Dataflow/queryMetadata.json`, `INICIAL_Carga_Revenues.Dataflow/queryMetadata.json`, `INICIAL_Carga_budget_fct.Dataflow/queryMetadata.json` - cargas históricas.
- `Seguridad_CDC.Dataflow/queryMetadata.json` - consulta RLS y conexión propia.
- `Seguridad_CDC.Dataflow/mashup.pq` - consulta RLS como tabla literal y destino `RLS_DataDestination`.
- `INGESTA_Carga_Datos.Dataflow/mashup.pq` - destino de `Carga_New_HAPA_asientos`.
- `*.Dataflow/mashup.pq` - anotaciones `DataDestinations` y tabla de destino de cada consulta.
- `TRANS_Silver.Dataflow/queryMetadata.json` - consultas 200_* de capa silver.
- `TRANS_Gold.Dataflow/queryMetadata.json` - consultas de capa gold.
