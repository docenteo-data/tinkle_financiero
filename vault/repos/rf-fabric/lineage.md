---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-11-04T12:00:00Z
stack: generic
source_globs: ["*.Dataflow/mashup.pq", "*.Dataflow/queryMetadata.json", "*.DataPipeline/pipeline-content.json", "*.Notebook/**", "sql/**", "lakehouse/**", "*.SemanticModel/definition/model.tmdl", "*.SemanticModel/definition/expressions.tmdl", "*.SemanticModel/definition/tables/**", "*.Report/definition.pbir"]
tags: [rf-fabric, lineage, orquestacion]
---

# rf-fabric - Lineage

> Cuándo cargar: necesitas saber qué lee y qué escribe cada consulta de dataflow, quién lee cada tabla del lakehouse o qué cadena une un fichero de entrada con un informe. Es la fuente de los diagramas de flujo de datos y orquestación.

Complementa a [[repos/rf-fabric/data-model]] (productor y columnas de cada tabla), [[repos/rf-fabric/integrations]] (ficheros de entrada) y [[repos/rf-fabric/architecture]] (orden de los pipelines). Este documento añade lo que esos no tienen: las consultas intermedias y los lectores.

## Reglas de este documento (mantener al resincronizar)

- Todas las consultas de todos los dataflows aparecen en la tabla de su dataflow, salvo las `*_DataDestination` y `DefaultDestination`, que son destinos ocultos generados por Fabric. Todas las tablas de `lakehouse/esquema.tsv` aparecen en "Lectores por tabla". El test `reporting-financiero/tests/test_linaje_vault.py` falla si falta alguna, o si en `fabric/` aparece un tipo de item que este documento no contempla.
- "Lee" es lo que la consulta navega en el lakehouse (`esquema.tabla`), los ficheros de `Files` (carpeta) o las otras consultas que referencia. "Escribe" sale de la anotación `DataDestinations` hacia su `*_DataDestination`; `loadEnabled` no sirve para esto.
- Una consulta sin "Escribe" solo existe como paso intermedio de otra del mismo dataflow.

## Tipos de item contemplados

Dataflow, DataPipeline, Notebook, SemanticModel y Report, más las carpetas `sql/`, `lakehouse/` y `temas/`. Las User Data Functions existen en el workspace pero no se versionan (ver [[repos/rf-fabric/configuration]]).

## Consultas por dataflow

### INGESTA_Carga_Datos (pipeline Generar Reporting, paso 1)

| Consulta | Lee | Escribe |
|---|---|---|
| Carga_New_Oracle | CSV de `Dinamicos` | 100.New_Oracle |
| Carga_New_MMS | Excel de `Dinamicos` | 100.New_MMS |
| Carga_New_HAPA_asientos | Excel de `Dinamicos` | 100.New_HAPA |
| Carga_New_PT_extrato_contas | Excel de `Dinamicos` | 100.New_PT_extrato_contas |
| Carga_New_Agings_Clientes | Excel de `Dinamicos/AGINGS` | 100.New_Agings_Clientes |
| Carga_New_Agings_Proveedores | Excel de `Dinamicos/AGINGS` | 100.New_Agings_Proveedores |

### TRANS_Silver (pipeline Generar Reporting, paso 3)

| Consulta | Lee | Escribe |
|---|---|---|
| 200_New_Oracle_trans | 100.New_Oracle | - |
| pFechaContable_New_Oracle | 200_New_Oracle_trans (fecha de corte) | - |
| 200_Oracle | 200.Oracle_historico anterior a la fecha de corte, más 200_New_Oracle_trans | 200.Oracle_historico |
| 200_New_HAPA_trans | 100.New_HAPA | - |
| pFecha_New_HAPA | 200_New_HAPA_trans (fecha de corte) | - |
| 200_HAPA | 200.HAPA anterior a la fecha de corte, más 200_New_HAPA_trans | 200.HAPA |
| 200_New_MMS_trans | 100.New_MMS | - |
| 200_MMS | 200.MMS completo más 200_New_MMS_trans, sin duplicados | 200.MMS |
| 200_Portugal_trans | 100.New_PT_extrato_contas | 200.Portugal |
| 200_New_Agings_Clientes | 100.New_Agings_Clientes | 200.Aging_Clientes |
| 200_New_Agings_Proveedores | 100.New_Agings_Proveedores | 200.Aging_Proveedores |

200_Oracle, 200_HAPA y 200_MMS leen la misma tabla que escriben: conservan el histórico y le añaden lo nuevo. Oracle y HAPA sustituyen los periodos desde la fecha de corte; MMS no filtra por fecha y quita duplicados.

### TRANS_Gold (pipeline Generar Reporting, paso 5)

| Consulta | Lee | Escribe |
|---|---|---|
| Oracle_historico | 200.Oracle_historico | - |
| HAPA | 200.HAPA | - |
| Portugal | 200.Portugal | - |
| 200_COA_Oracle | 200.COA_Oracle | - |
| 200_Mapping_HAPA | 200.Mapping_HAPA | - |
| 200_Mapping Portugal | 200.Mapping Portugal | - |
| Fact_Actuals | Oracle_historico, HAPA, Portugal | 300.Fact_Actuals |
| Dim_Cuentas | 200_COA_Oracle, 200_Mapping_HAPA, 200_Mapping Portugal | 300.Dim_Cuentas |
| Dim_mapeo_cuentas | 200_COA_Oracle, 200_Mapping_HAPA, 200_Mapping Portugal | 300.Dim_Mapeo_Cuentas |

### INGESTA_Maestros (fuera de los pipelines)

| Consulta | Lee | Escribe |
|---|---|---|
| Mapping HAPA | `Maestros/Maestros.xlsx` | 200.Mapping_HAPA |
| Mapping Portugal | `Maestros/Maestros.xlsx` | 200.Mapping Portugal |
| COA_Oracle | `Maestros/Maestros.xlsx` | 200.COA_Oracle |
| Dim_CDC | `Maestros/Maestros.xlsx` | 300.Dim_CDC |
| Aux_CDC | `Maestros/Maestros.xlsx` | 300.Aux_CDC |
| Dim_Clientes | `Maestros/Maestros.xlsx` | 300.Dim_Clientes |
| Dim_RRHH | `Maestros/MASTER RRHH 2026 .xlsx` | 300.Dim_RRHH |
| Dim_Calendar | Generada en el M (2020 a 2030) | 300.Dim_Calendar |
| Dim_Sociedades | Tabla literal en el M | 300.Dim_Sociedades |
| Assets_Reporte, Liabilities_Reporte, PL_Reporte | Tablas literales en el M | - |
| Assets_Reporte_Cuentas, Liabilities_Reporte_Cuentas, PL_Reporte_Cuentas | Su consulta `*_Reporte`; PL_Reporte_Cuentas, además, Dim_Report_Line | - |
| Dim_Report_Line | Assets_Reporte, Liabilities_Reporte, PL_Reporte | 300.Dim_Report_Line |
| Map_Report_Line_Account | Las tres `*_Reporte_Cuentas` | 300.Map_Report_Line_Account |

### Cargas iniciales (fuera de los pipelines)

| Dataflow | Consulta | Lee | Escribe |
|---|---|---|---|
| INICIAL_Carga_Oracle | Carga Oracle historico desde Checklist | Checklist `.xlsm` de `Arranque` | 200.Oracle_historico |
| INICIAL_Carga_Agings | Carga Aging Clientes historico | Excel de aging de clientes de `Arranque` | 200.Aging_Clientes |
| INICIAL_Carga_Agings | Carga Aging Proveedores historico | Excel de cartera de proveedores de `Arranque` | 200.Aging_Proveedores |
| INICIAL_Carga_Revenues | Revenue by client FT3 2026 | `Arranque/Revenue 2026 FT3.xlsx` | - |
| INICIAL_Carga_Revenues | Carga historica revenues | `Arranque/Revenue 2026 FT3.xlsx` y Revenue by client FT3 2026 | 200.Revenues |
| INICIAL_Carga_budget_fct | B01 JAZZ, B01 ONION, B01 PORT, B01 CONS | Checklist `.xlsm` de `Arranque` | - |
| INICIAL_Carga_budget_fct | B01 TOTAL (Checklist) | Las cuatro B01 | - |
| INICIAL_Carga_budget_fct | FORECASTS y BUDGET | `Arranque/TINKLE FORECAST 2026 FT3.xlsm` | 200.Presupuestos |
| INICIAL_Carga_Rentabilidades | Fact_Asignacion_RRHH | Excel de `Arranque/RENTABILIDAD` | 300.Fact_Asignacion_RRHH |
| INICIAL_Carga_Rentabilidades | Dim_CDC | 300.Dim_CDC | - |
| INICIAL_Carga_Rentabilidades | Dim_equipos | Fact_Asignacion_RRHH, Dim_CDC | 300.Dim_equipos |
| Seguridad_CDC | RLS | Tabla literal en el M | 100.RLS |

Las B01 y B01 TOTAL no escriben en ninguna tabla: la carga de presupuesto que llega al lakehouse es FORECASTS y BUDGET.

## Lectores por tabla

| Tabla | Lectores |
|---|---|
| 100.New_Oracle | TRANS_Silver (200_New_Oracle_trans) |
| 100.New_HAPA | TRANS_Silver (200_New_HAPA_trans) |
| 100.New_MMS | TRANS_Silver (200_New_MMS_trans) |
| 100.New_PT_extrato_contas | TRANS_Silver (200_Portugal_trans) |
| 100.New_Agings_Clientes | TRANS_Silver (200_New_Agings_Clientes) |
| 100.New_Agings_Proveedores | TRANS_Silver (200_New_Agings_Proveedores) |
| 100.RLS | Ninguno en el repositorio |
| 200.Oracle_historico | TRANS_Silver (200_Oracle), TRANS_Gold (Oracle_historico) |
| 200.HAPA | TRANS_Silver (200_HAPA), TRANS_Gold (HAPA) |
| 200.MMS | TRANS_Silver (200_MMS), modelo Financial Model |
| 200.Portugal | TRANS_Gold (Portugal) |
| 200.COA_Oracle, 200.Mapping_HAPA, 200.Mapping Portugal | TRANS_Gold |
| 200.Aging_Clientes, 200.Aging_Proveedores | Modelo Agings (import) |
| 200.Presupuestos | Modelo Financial Model |
| 200.Revenues | Ninguno en el repositorio |
| 200.Budget_historico | Ninguno en el repositorio (tampoco tiene productor) |
| 300.Fact_Actuals | Modelo Financial Model; vistas 200.vw_Export_Grupo, 200.vw_Export_Saldos_4_7 y 300.vw_Reporting_Actuals |
| 300.Dim_Mapeo_Cuentas | Modelo Financial Model; vistas 200.vw_Export_Grupo y 300.vw_Reporting_Actuals |
| 300.Dim_Sociedades | Modelo Financial Model; vistas 200.vw_Export_Grupo y 200.vw_Export_Saldos_4_7 |
| 300.Map_Report_Line_Account | Modelo Financial Model; vista 300.vw_Reporting_Actuals |
| 300.Dim_CDC | Modelo Financial Model; INICIAL_Carga_Rentabilidades (Dim_CDC) |
| 300.Aux_CDC, 300.Dim_Calendar, 300.Dim_Clientes, 300.Dim_Cuentas, 300.Dim_RRHH, 300.Dim_Report_Line, 300.Dim_equipos, 300.Fact_Asignacion_RRHH | Modelo Financial Model |

## Consumo aguas abajo

- Financial Model (Direct Lake sobre `lh_tinkle_financiero`): las 13 tablas de 300 más 200.MMS y 200.Presupuestos. Lo leen los informes Checklist (Oracle), HAPA, MMS, Presupuesto y Rentabilidad.
- Agings (import): 200.Aging_Clientes y 200.Aging_Proveedores. Lo lee el informe Agings.
- Vistas 200.vw_Export_Grupo y 200.vw_Export_Saldos_4_7: las lee el notebook Generar_txt_Balance_Saldos, que escribe los .txt en `Files/Exportaciones/Balance`; el pipeline Grabar salidas los copia a SharePoint.
- Vista 300.vw_Reporting_Actuals: sin lector en el repositorio.

## Open questions

- TBD: lectores fuera del repositorio de 100.RLS, 200.Revenues y 300.vw_Reporting_Actuals (por ejemplo, la seguridad por filas o consultas manuales al SQL endpoint).
- TBD: programación de los pipelines y quién lanza los dataflows que no están en ellos (ver [[repos/rf-fabric/architecture]]).

## Evidence

- `*.Dataflow/mashup.pq` - navegación de cada consulta (tablas `Id`, carpetas `Name`), referencias entre consultas y anotaciones `DataDestinations` con el esquema y la tabla de cada `*_DataDestination`.
- `TRANS_Silver.Dataflow/mashup.pq#200_Oracle`, `#200_HAPA`, `#200_MMS` - lectura de la propia tabla de destino, filtro por fecha de corte y anexado.
- `INGESTA_Maestros.Dataflow/mashup.pq#Dim_Calendar`, `#Dim_Sociedades` - consultas sin origen externo.
- `Financial Model.SemanticModel/definition/tables/` - `entityName` y `schemaName` de cada partición Direct Lake.
- `Agings.SemanticModel/definition/tables/200 Aging_Clientes.tmdl`, `200 Aging_Proveedores.tmdl` - particiones import sobre 200.
- `*.Report/definition.pbir` - modelo de cada informe.
- `sql/*.sql` - tablas que lee cada vista.
- `Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` - vistas leídas y carpeta de salida.
- `Grabar salidas.DataPipeline/pipeline-content.json` - copia de `Files/Exportaciones/Balance` a SharePoint.
- `lakehouse/esquema.tsv` - inventario de tablas.
