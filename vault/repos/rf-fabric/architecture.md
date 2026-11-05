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

> Cuándo cargar: necesitas saber qué dataflow escribe en qué capa del lakehouse, qué pipeline ejecuta cada paso (modulares, flujos y pipelines anteriores), en qué orden se encadenan o qué modelos semánticos se refrescan.

## Capas medallion

El lakehouse `lh_tinkle_financiero` organiza los datos en tres esquemas:

- 100 bruto: datos tal como llegan de los orígenes (Oracle, MMS, HAPA, Agings, Portugal, extracto de cuentas PT). Lo escriben las consultas `Carga_New_*` de INGESTA_Carga_Datos (New_Agings_Clientes, New_Agings_Proveedores, New_HAPA, New_MMS, New_Oracle y New_PT_extrato_contas) y la consulta RLS de Seguridad_CDC.
- 200 silver: datos transformados. Lo escriben TRANS_Silver (consultas `200_*`), INGESTA_Maestros (mapeos y COA_Oracle) y las cargas INICIAL_* históricas.
- 300 gold: modelo analítico (hechos y dimensiones). Lo escribe TRANS_Gold (Fact_Actuals, Dim_Cuentas, Dim_mapeo_cuentas), que lee consultas `200_*`. INGESTA_Maestros escribe las dimensiones y auxiliares, e INICIAL_Carga_Rentabilidades escribe Fact_Asignacion_RRHH y Dim_equipos.

## Dataflows

Los dataflows de ingesta y de apoyo siguen el patrón de nombre de la carpeta. El nombre interno de algunos no coincide con la carpeta: INGESTA_Carga_Datos figura como INGESTA_Carga_Oracle, INGESTA_Maestros como INGESTAS INICIALES y TRANS_Silver como TRANS_Carga_datos.

- INGESTA_Carga_Datos: consultas `Carga_New_*` (Oracle, MMS, HAPA asientos, Agings proveedores y clientes). Es el dataflow de ingesta principal. `Carga_New_HAPA_asientos` escribe en 100.New_HAPA mediante `Carga_HAPA_asientos_DataDestination`. La auditoría de septiembre (apartados 5.2, 5.5 y N2 del documento de arquitectura) decía que New_HAPA no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta. Lo refrescan los pipelines Ingesta_datos y Generar Reporting.
- INGESTA_Maestros: escribe en 200 (`Mapping_HAPA`, `Mapping Portugal`, `COA_Oracle`) y en 300 (`Dim_CDC`, `Dim_Calendar`, `Dim_Clientes`, `Dim_Sociedades`, `Dim_RRHH`, `Dim_Report_Line`, `Map_Report_Line_Account`, `Aux_CDC`). `Assets_Reporte`, `Liabilities_Reporte`, `PL_Reporte` y sus variantes `*_Cuentas` no tienen destino. `Mapeo_Magnitude` tampoco: es un paso intermedio que lee `Revenue 2026 FT3.xlsx` de Arranque, y `Dim_Clientes` lo une para añadir `Codigo_Magnitude`. Lo refresca el pipeline Ingesta_datos.
- INICIAL_Carga_Oracle: carga histórica de Oracle desde Checklist.
- INICIAL_Carga_Agings: histórico de agings de clientes y proveedores.
- INICIAL_Carga_Rentabilidades: escribe Fact_Asignacion_RRHH y Dim_equipos. Su consulta Dim_CDC solo lee 300.Dim_CDC.
- INICIAL_Carga_Revenues: histórico de revenues y revenue por cliente FT3 2026.
- INICIAL_Carga_budget_fct: budget B01 (JAZZ, ONION, PORT, CONS), total checklist y forecasts y budget.
- TRANS_Silver: transformaciones a capa 200. Lo refrescan los pipelines Transformacion_datos y Generar Reporting.
- TRANS_Gold: transformaciones a capa 300 (Fact_Actuals, Dim_Cuentas, Dim_mapeo_cuentas). Lo refrescan los pipelines Transformacion_datos y Generar Reporting.
- Seguridad_CDC: consulta RLS como tabla literal (sin origen) que escribe en 100.RLS mediante `RLS_DataDestination`. Declara otra conexión de tipo Lakehouse, pero navega al mismo lakehouse `lh_tinkle_financiero`, esquema 100. La auditoría de septiembre (apartados 5.2, 5.5 y N3 del documento de arquitectura) decía que no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta.

Los INICIAL_* y Seguridad_CDC no aparecen en ningún pipeline. Cómo y cuándo se ejecutan: TBD.

Las consultas `*_DataDestination` son destinos ocultos generados por el propio dataflow. Una consulta escribe en una tabla si en `mashup.pq` lleva la anotación `DataDestinations` hacia una consulta `*_DataDestination`. `loadEnabled` es false en todas, así que no sirve para distinguirlas.

## Pipelines modulares

Cuatro pipelines que se prueban y se relanzan por separado, según el ADR [[adrs/0001-orquestacion-y-vistas-de-salida]]. Todas las actividades tienen timeout de 12 horas y reintentos a 0. Ninguna tiene programación en la definición.

### Ingesta_datos

1. Maestros: refresco del dataflow INGESTA_Maestros, sin dependencias.
2. Carga: refresco del dataflow INGESTA_Carga_Datos, sin dependencias. Se ejecuta en paralelo con Maestros.
3. Endpoint SQL: refresco del endpoint SQL del lakehouse. Se ejecuta si Maestros y Carga terminan con Succeeded.

### Transformacion_datos

1. Silver: refresco de TRANS_Silver, sin dependencias.
2. Endpoint SQL tras silver: se ejecuta si Silver termina con Succeeded.
3. Gold: refresco de TRANS_Gold. Se ejecuta si el endpoint tras silver termina con Succeeded.
4. Endpoint SQL tras gold: se ejecuta si Gold termina con Succeeded.

### Refresco_modelos

- Financial Model y Agings: refresco de los dos modelos semánticos. No tienen dependencia entre sí, así que se ejecutan en paralelo. Ambos esperan a que termine el refresco (waitOnCompletion).

### Generar_salidas

Parámetros del pipeline:

- `ficheros` (texto, por defecto vacío): ficheros a generar: `Balance`, `Saldos_4_7`, `Ageing` o varios separados por coma. Vacío significa Balance y Saldos_4_7; Ageing solo se genera si se pide expresamente.
- `periodo_esperado` (texto, por defecto vacío): periodo AAAA.MM que se espera generar. Vacío significa no comprobar.

Actividades:

1. Notebook: ejecuta el notebook Generar_txt_Balance_Saldos pasándole `ficheros` y `periodo_esperado`. Sin dependencias.
2. Copiar a SharePoint: copia recursiva de los `.txt` de `Files/Exportaciones/Balance` del lakehouse a `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, preservando la jerarquía. Se ejecuta si Notebook termina con Succeeded.
3. Copiar Ageing a SharePoint: copia recursiva de los `.txt` de `Files/Exportaciones/Ageing` a `Shared Documents/Reporting Financiero/2. Salida de ficheros/Ageing`, preservando la jerarquía. Se ejecuta también si Notebook termina con Succeeded. No depende de que se haya pedido Ageing: copia lo que haya en la carpeta.

## Flujos

Tres pipelines que encadenan los modulares. Cada actividad es un ExecutePipeline con waitOnCompletion a true, y cada paso se ejecuta solo si el anterior termina con Succeeded. Ninguno tiene parámetros propios: los ExecutePipeline no pasan valores.

- Flujo_actualizar_datos: Ingesta_datos y luego Transformacion_datos.
- Flujo_total_reporting: Flujo_actualizar_datos y luego Refresco_modelos.
- Flujo_total_txt: Flujo_actualizar_datos y luego Generar_salidas. Como no pasa parámetros, Generar_salidas se ejecuta con `ficheros` y `periodo_esperado` vacíos: genera Balance y Saldos_4_7 (no Ageing) y no comprueba el periodo (ver [[repos/rf-fabric/quality]]).

Ningún flujo tiene programación en la definición.

## Pipeline Generar Reporting (anterior)

Sigue en Fabric sin cambios en este commit. Reintentos a 0 y timeout de 12 horas en todas las actividades. Orden de ejecución:

1. Carga: refresco del dataflow INGESTA_Carga_Datos, sin dependencias. Solo ejecuta consultas de mashup.
2. RefreshSqlEndpoint1_copy1: refresca el endpoint SQL del lakehouse. Se ejecuta si Carga termina con Succeeded.
3. Transformaciones SILVER: refresco de TRANS_Silver. Se ejecuta si el paso 2 termina con Succeeded.
4. RefreshSqlEndpoint1: refresca de nuevo el endpoint SQL. Se ejecuta si SILVER termina con Succeeded.
5. Transformaciones GOLD: refresco de TRANS_Gold. Se ejecuta si el paso 4 termina con Succeeded.
6. Semantic model refresh1: refresco del modelo Financial Model. Se ejecuta cuando GOLD termina en cualquier estado (Completed), también si falla.
7. Semantic model refresh1_copy1: refresco del modelo Agings. Se ejecuta cuando el paso 6 termina en cualquier estado (Completed).

El flujo es lineal: orígenes, ingesta a 100, transformación a 200, transformación a 300, endpoint SQL y modelos semánticos. Lo mismo hacen Ingesta_datos, Transformacion_datos y Refresco_modelos por separado, con la condición Succeeded.

Programación del pipeline (horario o disparo manual): TBD, no está en la definición.

## Pipeline Grabar salidas (anterior)

Sigue en Fabric sin cambios en este commit. Lo sustituye Generar_salidas, sin parámetros.

1. Notebook1: ejecuta el notebook Generar_txt_Balance_Saldos. Sin dependencias.
2. Grabar balance: copia recursiva de los ficheros .txt de `Files/Exportaciones/Balance` del lakehouse a SharePoint, carpeta Reporting Financiero, Salida de ficheros, Balance, preservando la jerarquía. Se ejecuta si Notebook1 termina con Succeeded.

Este pipeline no toca el lakehouse de capas ni los modelos: solo exporta ficheros.

## Modelos semánticos

- Los dos refrescos de modelo del pipeline Generar Reporting son Financial Model (paso 6) y Agings (paso 7). Las carpetas del repositorio son Agings.SemanticModel y Financial Model.SemanticModel.
- Refresco_modelos hace los mismos dos refrescos, pero solo después de Flujo_actualizar_datos con Succeeded (en Flujo_total_reporting).

## Evidence

- `Ingesta_datos.DataPipeline/pipeline-content.json` y `.platform` - actividades Maestros, Carga y Endpoint SQL, con sus dependencias.
- `Transformacion_datos.DataPipeline/pipeline-content.json` y `.platform` - actividades Silver, Gold y los dos endpoints.
- `Refresco_modelos.DataPipeline/pipeline-content.json` y `.platform` - refrescos de Financial Model y Agings.
- `Generar_salidas.DataPipeline/pipeline-content.json` y `.platform` - parámetros `ficheros` y `periodo_esperado`, notebook y dos copias a SharePoint (Balance y Ageing).
- `Flujo_actualizar_datos.DataPipeline/pipeline-content.json`, `Flujo_total_reporting.DataPipeline/pipeline-content.json`, `Flujo_total_txt.DataPipeline/pipeline-content.json` - ExecutePipeline, waitOnCompletion y dependencias Succeeded.
- `Generar Reporting.DataPipeline/pipeline-content.json` - actividades, dependencias y tipos del pipeline de reporting.
- `Generar Reporting.DataPipeline/.platform` - nombre del item y logicalId a cero.
- `Grabar salidas.DataPipeline/pipeline-content.json` - notebook, copia a SharePoint y dependencia.
- `INGESTA_Carga_Datos.Dataflow/queryMetadata.json` - consultas Carga_New_*.
- `INGESTA_Maestros.Dataflow/queryMetadata.json` - mapeos, dimensiones, consultas de informes y Mapeo_Magnitude.
- `INGESTA_Maestros.Dataflow/mashup.pq#Mapeo_Magnitude` - sin destino y unión en Dim_Clientes.
- `INICIAL_Carga_Agings.Dataflow/queryMetadata.json`, `INICIAL_Carga_Oracle.Dataflow/queryMetadata.json`, `INICIAL_Carga_Rentabilidades.Dataflow/queryMetadata.json`, `INICIAL_Carga_Revenues.Dataflow/queryMetadata.json`, `INICIAL_Carga_budget_fct.Dataflow/queryMetadata.json` - cargas históricas.
- `Seguridad_CDC.Dataflow/queryMetadata.json` - consulta RLS y conexión propia.
- `Seguridad_CDC.Dataflow/mashup.pq` - consulta RLS como tabla literal y destino `RLS_DataDestination`.
- `INGESTA_Carga_Datos.Dataflow/mashup.pq` - destino de `Carga_New_HAPA_asientos`.
- `*.Dataflow/mashup.pq` - anotaciones `DataDestinations` y tabla de destino de cada consulta.
- `TRANS_Silver.Dataflow/queryMetadata.json` - consultas 200_* de capa silver.
- `TRANS_Gold.Dataflow/queryMetadata.json` - consultas de capa gold.
- `vault/adrs/0001-orquestacion-y-vistas-de-salida.md` - motivo de los pipelines modulares y de los flujos (contexto, no fuente de la definición).
