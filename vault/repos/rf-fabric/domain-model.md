---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*.SemanticModel/definition/model.tmdl", "*.SemanticModel/definition/relationships.tmdl", "*.SemanticModel/definition/tables/**", "*.Dataflow/mashup.pq"]
tags: [rf-fabric, domain-model]
---

# rf-fabric - Domain model

> Cuándo cargar: necesitas saber qué tabla o relación usar en los modelos semánticos Financial Model y Agings, qué significa cada tabla en términos de negocio o en qué modo de almacenamiento está.

Los términos de negocio siguen el [glosario](../../../reporting-financiero/CONTEXT.md).

## Financial Model

### Modo y origen

- Modo Direct Lake sobre el lakehouse `lh_tinkle_financiero` en todas las tablas de hechos, dimensiones y auxiliares.
- Modo import en dos tablas calculadas: `Unidades` y `_Medidas`.
- Las tablas `LocalDateTable_*` y `DateTableTemplate_*` son la fecha automática de Power BI; no se documentan.
- Las medidas de negocio (por ejemplo Gross Income Real o Contribution MMS 2026) se describen en el glosario, no aquí.

### Tablas de hechos

- `Fact_Actuals`: Real contable por periodo, sociedad, cuenta origen y cliente (clave Oracle).
- `Fact_Asignacion_RRHH`: dedicaciones de empleados a clientes dentro de equipos. Base del Coste imputado.
- `MMS`: datos de MMS por cliente, sociedad (Compañia) y periodo (PERIODO): previsión de ingresos y producción.
- `Presupuestos`: Presupuesto por sociedad y cuenta Magnitude.

### Tablas de dimensiones

- `Dim_Calendar`: calendario, con Fecha y Orden_Mes.
- `Dim_Sociedades`: Sociedades, con las claves Sociedad, Sociedad_MMS y CodigoSociedad.
- `Dim_Clientes`: maestro de clientes que une la clave Oracle y la clave MMS. Incluye SECCION.
- `Dim_equipos`: Equipos.
- `Dim_RRHH`: Empleados. Contiene datos salariales, que no se describen aquí.
- `Dim_CDC`: Centros de coste, identificados por INICIALES CAPTIO.
- `Aux_CDC`: tabla auxiliar de centros de coste, unida a `Dim_CDC` por INICIALES CAPTIO. Contenido exacto: TBD.
- `Dim_Cuentas`: cuentas origen, solo las de origen ORACLE (filtra la unión de los tres mapeos).
- `Dim_Mapeo_Cuentas`: Mapeo de cuentas, de cada cuenta origen (ID_Account) a su Cuenta Magnitude (Cuenta_magnitude).
- `Dim_Report_Line`: Líneas de reporte.
- `Map_Report_Line_Account`: Cuentas Magnitude agrupadas en Líneas de reporte (Report_Line_Key), cada una con su signo.
- `Unidades` (import, calculada): selector de escala (unidades o miles) que usa la medida `Escala Seleccionado`.

### Relaciones

| Relación | Cardinalidad | Filtro |
|---|---|---|
| Fact_Actuals.Fecha con Dim_Calendar.Fecha | muchos a uno | única |
| Fact_Actuals.Sociedad con Dim_Sociedades.Sociedad | muchos a uno | única |
| MMS.Compañia con Dim_Sociedades.Sociedad_MMS | muchos a uno | única |
| Presupuestos.CodigoSociedad con Dim_Sociedades.CodigoSociedad | muchos a uno | única |
| Fact_Actuals.ID_Account con Dim_Mapeo_Cuentas.ID_Account | muchos a uno | única |
| Dim_Cuentas.ID_Account con Dim_Mapeo_Cuentas.ID_Account | uno a uno | ambas |
| Dim_Mapeo_Cuentas.Cuenta_magnitude con Presupuestos.Cuenta | muchos a muchos | única |
| Map_Report_Line_Account.Report_Line_Key con Dim_Report_Line.Report_Line_Key | muchos a uno | única |
| Aux_CDC.INICIALES CAPTIO con Dim_CDC.INICIALES CAPTIO | muchos a uno | única |
| Dim_Clientes.SECCION con Dim_CDC.INICIALES CAPTIO | muchos a uno | única |
| MMS.ClienteKey_MMS con Dim_Clientes.ClienteKey_MMS | muchos a uno | única |
| Fact_Actuals.ClienteKey_Oracle con Dim_Clientes.ClienteKey_Oracle | muchos a uno | única |
| Fact_Asignacion_RRHH.ClienteMMS con Dim_Clientes.Cliente MMS | muchos a uno | ambas |
| Fact_Asignacion_RRHH.Empleado con Dim_RRHH.NOMBRE | muchos a uno | única |
| Fact_Asignacion_RRHH.EquipoKey con Dim_equipos.EquipoKey | muchos a uno | única |
| MMS.PERIODO con Dim_Calendar.Orden_Mes | muchos a muchos | única |

- La relación de `Dim_Clientes.SECCION` con `Dim_CDC` supone que la sección es el centro de coste, algo que el glosario deja pendiente.
- `Fact_Asignacion_RRHH` enlaza con `Dim_RRHH` por nombre y no por clave.

## Agings

### Modo y tablas de origen

- Modo import en todas las tablas.
- `200 Aging_Clientes` y `200 Aging_Proveedores`: particiones M en modo import que leen `200.Aging_Clientes` y `200.Aging_Proveedores` del lakehouse `lh_tinkle_financiero` a través de su SQL analytics endpoint.
- `Fechas`: calendario calculado (import), con la columna Fecha. Es distinto de `Dim_Calendar` del Financial Model.

### Tablas snapshot calculadas

- `Aging_Clientes_Snapshot` y `Aging_Proveedores_Snapshot`: tablas calculadas con las columnas ID_aging y Date. Cruzan cada factura con cada fecha de corte de un calendario fijo de 2026 a 2027, desde la fecha de factura, y calculan los días vencidos (`DaysDue`) y el tramo (`AgingBucket`) a esa fecha.

### Relaciones

| Relación | Cardinalidad | Filtro |
|---|---|---|
| Aging_Clientes_Snapshot.ID_aging con 200 Aging_Clientes.ID_aging | muchos a uno | única |
| Aging_Proveedores_Snapshot.ID_aging con 200 Aging_Proveedores.ID_aging | muchos a uno | ambas |
| Aging_Clientes_Snapshot.Date con Fechas.Fecha | muchos a uno | única |
| Aging_Proveedores_Snapshot.Date con Fechas.Fecha | muchos a uno | única |

- Las columnas de fecha de las tablas de facturas y de los snapshots se relacionan con la fecha automática de Power BI, con comparación solo por día.

### Calendario

- `Fechas` es el calendario de los snapshots. Las tablas de facturas no se relacionan con `Fechas`, sino con la fecha automática.

## Evidence

- `Financial Model.SemanticModel/definition/model.tmdl` - tablas del modelo y origen Direct Lake.
- `Financial Model.SemanticModel/definition/relationships.tmdl` - relaciones, columnas y cardinalidades.
- `Financial Model.SemanticModel/definition/tables/` - modo y tipo de partición de cada tabla (solo lectura de partition y mode).
- `Agings.SemanticModel/definition/relationships.tmdl` - relaciones de Agings.
- `Agings.SemanticModel/definition/tables/` - modo y tipo de partición de cada tabla (solo lectura de partition y mode).
- `Agings.SemanticModel/definition/tables/200 Aging_Clientes.tmdl` - partición import sobre `200.Aging_Clientes`.
- `Agings.SemanticModel/definition/tables/200 Aging_Proveedores.tmdl` - partición import sobre `200.Aging_Proveedores`.
- `TRANS_Gold.Dataflow/mashup.pq` - filtro de `Dim_Cuentas` (origen ORACLE).
- `reporting-financiero/CONTEXT.md` - glosario de términos de negocio (fuera de la carpeta fuente).

## Open questions

- TBD: contenido de `Aux_CDC`.
- TBD: confirmar que la sección de un cliente es su centro de coste (glosario, pendiente).
