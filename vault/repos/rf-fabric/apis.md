---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*.SemanticModel/definition/tables/_Medidas.tmdl", "*.Report/definition/pages/**", "*.Report/definition.pbir", "sql/**"]
tags: [rf-fabric, apis]
---

# rf-fabric - APIs

> Cuándo cargar: necesitas saber qué medidas, informes o vistas SQL consume el reporting financiero y qué expone cada uno.

Superficie de consumo del workspace "Tinkle - Financiero". No hay API HTTP propia: el consumo se hace por medidas DAX, informes de Power BI y vistas SQL.

## Medidas DAX de Financial Model

Medidas de la tabla `_Medidas`, agrupadas por familia. Solo se listan nombres.

### Escala

- `Escala Seleccionado`, `Importe Base`: unidad elegida en la tabla `Unidades` y saldo real de `Fact_Actuals` dividido entre esa unidad. Base de casi todas las demás familias.

### Reporting contable y presupuesto

Reporting por línea (estado de situación y P&L) a partir del mapeo de cuentas a líneas de reporte. Tablas: `Fact_Actuals`, `Presupuestos`, `Map_Report_Line_Account`, `Dim_Report_Line`, `Dim_Mapeo_Cuentas`, `Dim_Cuentas`.

- Real: `Importe Reporting Cuentas`, `Net Income Reporting`, `ASOC01 - Statutory data`.
- Presupuesto: `Budget Base`, `Budget Reporting Cuentas`, `Budget Net Income`, `FCT`.
- Comparación: `DIF_ASOC01_FCT`.

### Real frente a MMS y Gross Income

Compara el gross income real (honorarios, producción y coste de producción) con el de la tabla `MMS` y clasifica la diferencia. Tablas: `Fact_Actuals`, `Dim_Cuentas`, `MMS`.

- `Importe MMS`, `Honorarios MMS`, `Producción MMS`, `Gross income MMS`.
- `Honorarios Real`, `Producción Real`, `Coste Producción`, `Gross Income Real`, `REAL (Fees & other)`.
- `Desviación Gross Income`, `% Desviación Gross Income`, `Estado GI` (cuadra, solo real, solo MMS, real mayor o menor).

### Coste salarial

Coste de personal por año (2025 y 2026) con cotizaciones, bonus y variación anual. Tabla: `Dim_RRHH`.

- `2025_salario`, `2025_salario_total`, `2026_salario`, `2026_salario_total`, `2026_Coste_total_salarial`.
- `Coste SSGG 2026`, `Coste SSGG Bonus 2025`, `COSTE TOTAL CON BONUS Y GRATIFICACION`, `DIF salarial año anterior`.

### Dedicación y rentabilidad

Asignación de personas a clientes y coste imputado. Tablas: `Fact_Asignacion_RRHH`, `Dim_RRHH`, `Dim_Clientes`, `Dim_equipos`.

- `% Dedicación`, `% Dedicación Total Persona`, `Estado Dedicación Persona`, `Nº Personas Asignadas`.
- `Coste Personal Imputado Total 2026`, `Coste Personal Imputado Cliente 2026`, `Contribution MMS 2026`, `% Contribution MMS 2026`.

### Formato

- `Color Fondo Reporting`: color de fondo de cada fila de reporting según su etiqueta (activo, pasivo, P&L, totales). Tabla: `Dim_Report_Line`.

## Medidas del modelo Agings

Tablas `Aging_Clientes_Snapshot`, `Aging_Proveedores_Snapshot` y `Fechas`.

- `Saldo pendiente`, `Facturas clientes`: importe pendiente y número de facturas de clientes.
- `Importe pendiente`, `Facturas proveedores`: lo mismo para proveedores.
- `fechaseleccionada`: fecha elegida en la tabla `Fechas`.

## Informes

Modelo de cada informe según `definition.pbir` (conexión al workspace "Tinkle - Financiero"). Páginas en el orden de `pages.json`.

- `Agings.Report`, modelo `Agings`: Home, AGING CLIENTES, AGING PROVEEDORES.
- `Checklist (Oracle).Report`, modelo `Financial Model`: Home, C - Assets, C - Liabilities, C - P&L, 1-FFPP & Part, 2-28 FA, Amortización (68 - mensual), 40007 - Composiciones, 4000-Prov, 430-Cli.
- `HAPA.Report`, modelo `Financial Model`: Home, C - Assets, C - Liabilities, C - P&L, 1-FFPP & Part, 2-28 FA, Amortización (68 - mensual), 40007 - Composiciones, 4000-Prov.
- `MMS.Report`, modelo `Financial Model`: Home, Análisis Coste Fee, DATOS MMS.
- `Presupuesto.Report`, modelo `Financial Model`: Home, Revenue (Real + MMS), MMS VS REAL, Página 1.
- `Rentabilidad.Report`, modelo `Financial Model`: RESUMEN, RENTABILIDAD CLIENTE, RENTABILIDAD CLIENTE (CDC), RENTABILIDAD AVANZADA, SALARIOS.

## Vistas SQL

Carpeta `sql/`, sobre el lakehouse `lh_tinkle_financiero`.

- `200.vw_Export_Grupo` (esquema 200): exporta los saldos por cuenta magnitud del último periodo en formato de grupo, en miles.
- `200.vw_Export_Saldos_4_7` (esquema 200): exporta los saldos por sociedad del último periodo para el fichero de cuentas 4 a 7.
- `300.vw_Reporting_Actuals` (esquema 300): une las líneas de cuentas y las de medidas en un único conjunto de reporting real.

## Open questions

- TBD: consumidores externos de las vistas `200.*` (no son derivables del repositorio).
- TBD: propósito de la página "Página 1" del informe `Presupuesto.Report`.

## Evidence

- `Financial Model.SemanticModel/definition/tables/_Medidas.tmdl` - nombres y familias de las medidas del modelo.
- `Agings.SemanticModel/definition/tables/Aging_Clientes_Snapshot.tmdl`, `Agings.SemanticModel/definition/tables/Aging_Proveedores_Snapshot.tmdl`, `Agings.SemanticModel/definition/tables/Fechas.tmdl` - medidas del modelo Agings.
- `Agings.Report/definition.pbir`, `Checklist (Oracle).Report/definition.pbir`, `HAPA.Report/definition.pbir`, `MMS.Report/definition.pbir`, `Presupuesto.Report/definition.pbir`, `Rentabilidad.Report/definition.pbir` - modelo de cada informe.
- `Agings.Report/definition/pages/pages.json`, `Checklist (Oracle).Report/definition/pages/pages.json`, `HAPA.Report/definition/pages/pages.json`, `MMS.Report/definition/pages/pages.json`, `Presupuesto.Report/definition/pages/pages.json`, `Rentabilidad.Report/definition/pages/pages.json` - orden de páginas.
- `*.Report/definition/pages/*/page.json` - `displayName` de cada página.
- `sql/200.vw_Export_Grupo.sql`, `sql/200.vw_Export_Saldos_4_7.sql`, `sql/300.vw_Reporting_Actuals.sql` - cabeceras y propósito de cada vista.
