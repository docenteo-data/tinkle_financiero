---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["lakehouse/**", "*.Dataflow/queryMetadata.json", "*.Dataflow/mashup.pq"]
tags: [rf-fabric, data-model]
---

# rf-fabric - Data model

> Cuándo cargar: necesitas saber qué tablas tiene el lakehouse `lh_tinkle_financiero`, cuántas columnas tiene cada una y qué dataflow la escribe.

## Alcance y método

- 32 tablas en tres esquemas: `100` (7 tablas, 318 columnas), `200` (12 tablas, 363 columnas) y `300` (13 tablas, 139 columnas). Total: 820 columnas.
- Columnas: conteo por tabla del fichero de esquema del lakehouse.
- Productor: una consulta escribe en una tabla si lleva la anotación `DataDestinations` en `mashup.pq` hacia una consulta `*_DataDestination`. Todas las consultas tienen `loadEnabled` a false, así que ese campo no sirve para saber qué escribe.
- Esquema y tabla de destino: se toman del esquema y la tabla de cada `*_DataDestination` en `mashup.pq`.
- Modo de escritura: los destinos con ajustes manuales declaran Replace (Carga_New_Oracle, Mapping Portugal, Carga Oracle historico desde Checklist y, en TRANS_Silver, 200_Oracle y 200_New_Agings_*). Los automáticos no declaran método y la auditoría los da como Replace.

## Tablas del esquema 100

| Tabla | Columnas | Productor (dataflow) | Consulta origen | Notas |
|---|---|---|---|---|
| New_Agings_Clientes | 13 | INGESTA_Carga_Datos | Carga_New_Agings_Clientes | |
| New_Agings_Proveedores | 15 | INGESTA_Carga_Datos | Carga_New_Agings_Proveedores | |
| New_HAPA | 42 | INGESTA_Carga_Datos | Carga_New_HAPA_asientos | Destino por `Carga_HAPA_asientos_DataDestination`. |
| New_MMS | 183 | INGESTA_Carga_Datos | Carga_New_MMS | |
| New_Oracle | 38 | INGESTA_Carga_Datos | Carga_New_Oracle | |
| New_PT_extrato_contas | 24 | INGESTA_Carga_Datos | Carga_New_PT_extrato_contas | Oculta con nombre distinto: `Carga_PT_extrato_contas_DataDestination`. |
| RLS | 3 | Seguridad_CDC | RLS | Tabla literal en el M, sin origen. Destino por `RLS_DataDestination`. Ver discrepancias. |

## Tablas del esquema 200

| Tabla | Columnas | Productor (dataflow) | Consulta origen | Notas |
|---|---|---|---|---|
| Aging_Clientes | 13 | INICIAL_Carga_Agings; TRANS_Silver | Carga Aging Clientes historico; 200_New_Agings_Clientes | Dos productores |
| Aging_Proveedores | 15 | INICIAL_Carga_Agings; TRANS_Silver | Carga Aging Proveedores historico; 200_New_Agings_Proveedores | Dos productores |
| Budget_historico | 7 | Sin productor | - | Ningún dataflow tiene una consulta con destino para esta tabla |
| COA_Oracle | 5 | INGESTA_Maestros | COA_Oracle | |
| HAPA | 24 | TRANS_Silver | 200_HAPA | |
| MMS | 192 | TRANS_Silver | 200_MMS | |
| Mapping Portugal | 5 | INGESTA_Maestros | Mapping Portugal | Destino por `Mapping HAPA (2)_DataDestination`, nombre engañoso; ajustes manuales con Replace y esquema fijo. |
| Mapping_HAPA | 8 | INGESTA_Maestros | Mapping HAPA | Destino por `Mapping HAPA_DataDestination`. |
| Oracle_historico | 45 | INICIAL_Carga_Oracle; TRANS_Silver | Carga Oracle historico desde Checklist; 200_Oracle | Dos productores |
| Portugal | 26 | TRANS_Silver | 200_Portugal_trans | |
| Presupuestos | 10 | INICIAL_Carga_budget_fct | FORECASTS y BUDGET | |
| Revenues | 13 | INICIAL_Carga_Revenues | Carga historica revenues | |

## Tablas del esquema 300

| Tabla | Columnas | Productor (dataflow) | Consulta origen | Notas |
|---|---|---|---|---|
| Aux_CDC | 2 | INGESTA_Maestros | Aux_CDC | |
| Dim_CDC | 5 | INGESTA_Maestros | Dim_CDC | |
| Dim_Calendar | 16 | INGESTA_Maestros | Dim_Calendar | |
| Dim_Clientes | 14 | INGESTA_Maestros | Dim_Clientes | |
| Dim_Cuentas | 14 | TRANS_Gold | Dim_Cuentas | |
| Dim_Mapeo_Cuentas | 5 | TRANS_Gold | Dim_mapeo_cuentas | |
| Dim_RRHH | 22 | INGESTA_Maestros | Dim_RRHH | Datos de personas: no se detallan columnas |
| Dim_Report_Line | 10 | INGESTA_Maestros | Dim_Report_Line | |
| Dim_Sociedades | 5 | INGESTA_Maestros | Dim_Sociedades | |
| Dim_equipos | 6 | INICIAL_Carga_Rentabilidades | Dim_equipos | |
| Fact_Actuals | 20 | TRANS_Gold | Fact_Actuals | |
| Fact_Asignacion_RRHH | 12 | INICIAL_Carga_Rentabilidades | Fact_Asignacion_RRHH | Datos de personas: no se detallan columnas |
| Map_Report_Line_Account | 8 | INGESTA_Maestros | Map_Report_Line_Account | |

## Tablas con dos productores

- `200.Oracle_historico`, `200.Aging_Clientes` y `200.Aging_Proveedores`.
- La auditoría (5.5, N4, D10) decía cuatro, incluido `300.Dim_CDC`. En la definición exportada, `INICIAL_Carga_Rentabilidades` solo lee `300.Dim_CDC`, así que esa tabla tiene un único productor.
- Las escrituras de estas tablas son Replace, así que gana la última ejecución. Relanzar un `INICIAL_*` sustituye los datos de las cargas recurrentes.

## Tablas sin productor activo

- `200.Budget_historico`: ningún dataflow tiene una consulta con destino para esta tabla.

## Discrepancias

- `RLS`: la auditoría de septiembre (apartados 5.2, 5.5 y N3 del documento de arquitectura) decía que no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta.
- `New_HAPA`: la auditoría de septiembre (apartados 5.2, 5.5 y N2 del documento de arquitectura) decía que no tenía destino; la definición exportada dice lo contrario. Falta comprobar en el workspace que se ejecuta.
- El nombre interno del JSON no coincide con la carpeta en tres dataflows: `INGESTA_Carga_Datos` (interno `INGESTA_Carga_Oracle`), `INICIAL_Carga_Oracle` (interno `INICIAL_Carga_Oracle_Checklist`) y `TRANS_Silver` (interno `TRANS_Carga_datos`). Este documento usa el nombre de carpeta.

## Open questions

- TBD: comprobar en el workspace de Fabric que se ejecutan `RLS_DataDestination` y `Carga_HAPA_asientos_DataDestination`.

## Evidence

- `lakehouse/esquema.tsv` - columnas por esquema y tabla (conteo; el contenido no se copia).
- `INGESTA_Carga_Datos.Dataflow/queryMetadata.json` - consultas de ingesta del esquema 100.
- `INGESTA_Carga_Datos.Dataflow/mashup.pq` - destino de `Carga_New_HAPA_asientos` (100.New_HAPA).
- `*.Dataflow/mashup.pq` - anotaciones `DataDestinations` y tabla de destino de cada consulta.
- `INGESTA_Maestros.Dataflow/queryMetadata.json` - dimensiones, mappings y COA_Oracle en 200 y 300.
- `INICIAL_Carga_Agings.Dataflow/queryMetadata.json` - Aging_Clientes y Aging_Proveedores (carga histórica).
- `INICIAL_Carga_Oracle.Dataflow/queryMetadata.json` - Oracle_historico (carga desde Checklist).
- `INICIAL_Carga_Rentabilidades.Dataflow/queryMetadata.json` - Fact_Asignacion_RRHH y Dim_equipos (la consulta Dim_CDC solo lee 300.Dim_CDC).
- `INICIAL_Carga_Revenues.Dataflow/queryMetadata.json` - Revenues.
- `INICIAL_Carga_budget_fct.Dataflow/queryMetadata.json` - Presupuestos.
- `Seguridad_CDC.Dataflow/queryMetadata.json` - RLS y conexión propia de tipo Lakehouse, que navega al mismo lakehouse y esquema 100.
- `Seguridad_CDC.Dataflow/mashup.pq` - consulta RLS como tabla literal y destino `RLS_DataDestination`.
- `TRANS_Silver.Dataflow/queryMetadata.json` - HAPA, MMS, Portugal y tablas 200 de agings y Oracle.
- `TRANS_Gold.Dataflow/queryMetadata.json` - Dim_Cuentas, Dim_mapeo_cuentas y Fact_Actuals.
- `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md` - sección 5.5 (contraste de destinos y productores).
