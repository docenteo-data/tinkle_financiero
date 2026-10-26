# Documentación del proyecto Fabric — Tinkle - Financiero

Workspace: `Tinkle - Financiero` (id `b31820dc-4b4f-4696-9a96-bbee438e9306`)

| Campo | Valor |
|---|---|
| Entorno | Único workspace conocido (no consta separación en desarrollo, pruebas y producción) |
| Capacidad | `c410e399-2954-4304-a90c-95f0444a7f46`, West Europe. Ya no es la de prueba `FTL64` del 2026-09-24 (ver §11.2) |
| Última revisión | 2026-10-26: contraste con las definiciones exportadas en `reporting-financiero/fabric/` y con el SQL endpoint (ver §13.7) |
| Fuentes | Hasta el 2026-09-24, conectores de Fabric (respuestas en `docs/prompts/copilot/2a iteracion/res1.txt` a `res8.txt`). Desde el 2026-10-26, las definiciones exportadas por API en `reporting-financiero/fabric/` (modelos en TMDL, informes, dataflows, pipelines, notebook, vistas SQL y esquema del lakehouse). Cómo se regeneran: `docs/flujo-fabric.md`. |
| Limitaciones | Siguen sin revisar: el código de las UDF (no se lee por el secreto incrustado), la definición de Planning y la app, las programaciones y el historial de ejecuciones. Lo que depende de ellos sigue como "pendiente de verificar". |
| Auditoría | §13 |

---

## 1. Inventario de items del workspace

| Nombre | Tipo | Id | Notas |
|---|---|---|---|
| Tinkle - Financiero | App (OrgApp) | 66f6b4f0-e80e-44f4-b591-f6a1e513bda9 | "Aplicación de reporting financiero de Tinkle para el seguimiento de resultados, balance y evolución del negocio." El id `1e18b9bd-5689-4897-8c13-30be4ff0bdbf` (PowerBIApp) ya no aparece en el workspace (consulta del 2026-09-24). |
| lh_tinkle_financiero | Lakehouse | 4d2305f1-7ef6-42c3-87ed-aed12f143ac2 | Lakehouse principal, ver sección 2 |
| lh_tinkle_financiero (SQL Endpoint) | SQLEndpoint | 485f1bd4-2372-44a3-b279-e00a63a80137 | Endpoint SQL del lakehouse principal |
| StagingLakehouseForDataflows_20260422143941 | Lakehouse | 5ff87d24-2496-418f-88c0-3b9ff9e52913 | Lakehouse técnico auxiliar generado por Dataflows Gen2 |
| StagingLakehouseForDataflows_... (SQL Endpoint) | SQLEndpoint | 76a581f2-3f65-4297-b066-b2308a924156 | |
| StagingWarehouseForDataflows_20260422144007 | Warehouse | cc0e6dd8-1ceb-4474-a5cc-f83aeb49270d | Warehouse técnico auxiliar de staging para Dataflows Gen2 |
| INICIAL_Carga_Oracle | DataflowGen2 | bc6e3c41-2f60-4954-9a75-6cd17dd2ca39 | Carga inicial del histórico contable Oracle desde la hoja `Oracle` del Excel Checklist (no conecta a la base de datos Oracle) |
| INGESTA_Maestros | DataflowGen2 | 60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6 | Ingesta de maestros (dimensiones) |
| INICIAL_Carga_budget_fct | DataflowGen2 | ccf7112d-ffd7-41c0-ac41-ac394ea63e65 | Carga inicial de presupuesto |
| INICIAL_Carga_Revenues | DataflowGen2 | 3efad19a-3c01-449a-a5b2-cb55f4ba2082 | Carga inicial de ingresos |
| Seguridad_CDC | DataflowGen2 | 42e8fdba-1dfa-469c-9a26-118ea3df5bb0 | Mapeo de centros de coste / seguridad |
| INGESTA_Carga_Datos | DataflowGen2 | c8d12168-9a15-4df6-8632-eb647c58a861 | Ingesta recurrente de datos |
| TRANS_Gold | DataflowGen2 | 2ddb6bc7-1a91-490f-9a6b-60ade6940b4e | Transformación a capa Gold (300) |
| TRANS_Silver | DataflowGen2 | e34a567e-3986-467e-ac59-9c89b8014b87 | Transformación a capa Silver (200) |
| INICIAL_Carga_Agings | DataflowGen2 | e9e60e41-5456-4d95-9b1e-32e66c795f94 | Carga inicial de agings (vencimientos) |
| INICIAL_Carga_Rentabilidades | DataflowGen2 | ca02d1da-5790-448a-84ba-e0e6a5e4708e | Carga inicial de rentabilidad |
| Generar Reporting | DataPipeline | 147b24eb-352f-4f88-9d64-b4a7fc1d67f6 | Pipeline de orquestación de generación de reporting |
| Grabar salidas | DataPipeline | 56a37cd5-3664-47b4-b28f-ec7f26d23075 | Pipeline de escritura de salidas |
| Generar_txt_Balance_Saldos | Notebook | c649ae24-2b54-4fce-bd5c-d23a9516ec37 | Notebook (Spark) |
| Ejecución Reporting | UserDataFunction | 27467e82-89d3-44fc-8c93-4ae54fd4d193 | Función de usuario |
| Generar_txt | UserDataFunction | 30f6466d-8780-4886-84b8-70ebc13e6d1e | Función de usuario |
| MMS | Report | 97052b38-d2fd-4a01-afbf-bfb8ebc8b1a7 | Informe Power BI. La copia `a0c690f7-92a3-4acf-b084-d0d0311e4287` ya no existe (EntityNotFound el 2026-09-24). |
| Presupuesto | Report | 9f2f023c-592a-4ce0-bc6f-8adad4a28a41 | |
| Checklist (Oracle) | Report | ac83ce13-5a64-4ef7-bbb2-05b3e1439b5e | La copia `ee58e006-ba1f-424d-9669-5a519127e35c` ya no existe (EntityNotFound el 2026-09-24). |
| Agings | Report | 05c3bd2c-c699-4d04-92c6-1828a375f9cf | |
| HAPA | Report | 97d0a79d-09ff-4d6b-9cf0-b3e2b1e3fa47 | |
| Rentabilidad | Report | b4d83714-386f-4a97-abcb-5db71937d442 | |
| Agings | SemanticModel | e19def87-fdf3-4b44-bd60-d22e5d79ce88 | |
| Financial Model | SemanticModel | 847ce270-06ab-408b-85c9-cb8f390fad1c | Modelo semántico principal, ver sección 6 |
| Planning | Plan (Fabric Planning) | 50ce99b8-0525-435f-bc71-56235a557714 | Ver sección 10 |
| CPM | SQLDatabase / SQLEndpoint | b85d1457-6ce1-441c-b8cb-21cb839d688a / 69d9c9ae-c727-4e65-b485-1ab1ad75f41e | Base de datos SQL asociada a Planning/CPM |
| __fabric_plan_sys | SQLDatabase / SQLEndpoint | cdbe3af7-b08f-4461-b3c1-10fef85a8610 / f5928f26-c645-456f-a0f0-f7615e77fdad | Sistema interno auto-creado por Fabric Planning (no editar) |
| test_app | OrgAppAudience | fd6d65d3-0b01-415a-979f-84da40dca949 | Audiencia de la app publicada |

---

## 2. Modelo de datos — Lakehouse `lh_tinkle_financiero`

El lakehouse organiza las tablas en 3 esquemas (namespaces) que representan capas de arquitectura medallion, más un esquema `dbo` vacío:

- **`100`** — capa raw / bruta: ficheros recurrentes de la carpeta `Dinamicos` tal cual origen, cargados por `INGESTA_Carga_Datos`. Las cargas `INICIAL_*` no pasan por esta capa (escriben en `200` o `300`).
- **`200`** — capa silver / histórico y staging intermedio
- **`300`** — capa gold, modelo en estrella listo para reporting

El esquema de columnas completo de las tablas de los tres esquemas (nombre, posición, tipo, nulabilidad, longitud, precisión, escala) está en [fabric/lakehouse/esquema.tsv](../../fabric/lakehouse/esquema.tsv), que se regenera con cada exportación.

### 2.1 Esquema `100` (raw)

| Tabla | Columnas |
|---|---|
| New_Agings_Clientes | 13 |
| New_Agings_Proveedores | 15 |
| New_HAPA | 42 |
| New_MMS | 183 |
| New_Oracle | 38 |
| New_PT_extrato_contas | 24 |
| RLS (seguridad a nivel de fila) | 3 |

### 2.2 Esquema `200` (silver / histórico)

| Tabla | Columnas | | Tabla | Columnas |
|---|---|---|---|---|
| Aging_Clientes | 13 | | MMS | 192 |
| Aging_Proveedores | 15 | | Mapping Portugal | 5 |
| Budget_historico | 7 | | Mapping_HAPA | 8 |
| COA_Oracle | 5 | | Oracle_historico | 45 |
| HAPA | 24 | | Portugal | 26 |
| Presupuestos | 10 | | Revenues | 13 |

Además de las tablas Delta, el SQL endpoint del lakehouse expone tres **vistas**, con su definición en [fabric/sql/](../../fabric/sql/):

- `200.vw_Export_Grupo` (27 columnas) y `200.vw_Export_Saldos_4_7` (9 columnas), que usa el notebook de exportación (§7).
- `300.vw_Reporting_Actuals`: aplica a `Fact_Actuals` el mapeo de cuentas y de líneas de reporte con su signo (`Importe_Reporting`). Ningún modelo, informe, pipeline ni notebook del workspace la lee (2026-10-26).

`MMS` es la tabla más ancha del lakehouse (192 columnas): datos operativos de medios/campañas (proveedor, soporte, campaña, presupuesto, importes...), con las claves `PERIODO`, `ClienteKey_MMS`, `Compañia` e `IMPORTE` usadas por el modelo semántico (§6).

### 2.3 Esquema `300` (gold — modelo en estrella)

**Tablas de hechos**

| Tabla | Columnas | Descripción |
|---|---|---|
| `Fact_Actuals` | Sociedad, Cuenta_origen, Descripcion, Cliente, Intercía, Fecha, Num. Tercero, Nom. Tercero, Debe, Haber, Saldo, Categoria, Num & Nom Tercero_, Origen_actuals, Fecha_Original, Periodo_Original, Periodo, ID_Account, CodigoSociedad, ClienteKey_Oracle | Movimientos contables reales (actuals) |
| `Fact_Asignacion_RRHH` | CodigoDirectora, Equipo, ClienteOracle, ClienteMMS, Descripcion, Empleado, EmpleadoPosicion, PctDedicacion, TipoDedicacion, ArchivoOrigen, HojaOrigen, EquipoKey | Asignación/dedicación de empleados a clientes/equipos |

**Tablas de dimensiones**

| Tabla | Columnas clave | Descripción |
|---|---|---|
| `Dim_Cuentas` | Cuenta, Descripcion, Mapeo Oracle, Cuenta_magnitude, TIPO, ID_Account, Cuenta & Descripción... | Plan de cuentas y mapeos |
| `Dim_Mapeo_Cuentas` | Cuenta_origen, Descripcion, Cuenta_magnitude, Origen_map, ID_Account | Mapeo cuenta origen → cuenta agregada (magnitud), usada junto con `Dim_Cuentas` |
| `Dim_Sociedades` | CodigoSociedad, Sociedad, Pais, CountryCode, Sociedad_MMS | Sociedades/entidades legales |
| `Dim_Calendar` | Fecha, Ejercicio, NUMMES, Mes, PERIODO, Año_Mes, Trimestre, Dia, Nombre_Dia_Semana, Inicio_Mes, Fin_Mes, Orden_Mes | Calendario financiero |
| `Dim_Clientes` | Cliente ORACLE, Cliente MMS, Descripción, Fecha Inicio/Finaliz., Activ., Ppal., Empresa, SECCION, ClienteKey_Oracle, ClienteKey_MMS | Clientes/proyectos (con claves cruzadas Oracle/MMS) |
| `Dim_Report_Line` | Orden, Fila_Excel, Row_ID, Etiqueta, Codigo_Reporte, Cuenta_Visible, Tipo_Fila, Clase_Formato, Reporte, Report_Line_Key | Estructura de líneas de los reportes financieros (plantilla de P&L/Balance) |
| `Map_Report_Line_Account` | Row_ID, Report_Line_Key, Tipo_Origen, Referencia, Cuenta, Signo, Tipo_Mapeo, Reporte | Mapeo cuenta → línea de reporte (con signo) |
| `Dim_equipos` | EquipoKey, CodigoDirectora, Equipo, Directora, CodigoCDC, CentroCoste | Equipos comerciales/operativos |
| `Dim_RRHH` | NOMBRE, EMPRESA, PUESTO, MANAGER, EQUIPO, CENTRO DE COSTE, OFICINA, Fecha inicio/fin, Jornada, SALARIO 2025/2026, RETRIBUCION ANUAL 2026, COSTE SEGURIDAD SOCIAL 2026, COSTE TOTAL 2026/2027... | Ficha de empleados con costes salariales |
| `Dim_CDC` | Código CDC ORACLE, Nombre, INICIALES CAPTIO, Directora, CENTRO DE COSTE | Centros de coste |
| `Aux_CDC` | CDC, INICIALES CAPTIO | Tabla auxiliar de mapeo de centros de coste |

Las relaciones entre estas tablas (las realmente activas en el modelo de reporting) están documentadas en §6.2.

---

## 3. Dependencias y orígenes de datos (shortcuts)

El lakehouse `lh_tinkle_financiero` tiene un shortcut configurado:

| Ruta en el item | Tipo destino | Origen |
|---|---|---|
| `/Files/Reporting Financiero` | OneDrive/SharePoint | `https://b66388802-my.sharepoint.com/personal/reporting_likuit_com/Documents/Reporting Financiero` |

No hay conexión directa a bases de datos de origen: todos los datos (extractos contables de Oracle, MMS, HAPA, Portugal, agings, maestros, presupuesto, ingresos y RRHH) llegan como ficheros Excel o CSV que se depositan manualmente en esa carpeta y se leen a través del shortcut sin duplicarlos. La carpeta tiene dos subcarpetas de entrada: `1. Entrada de Datos/Arranque` (ficheros de carga inicial) y `1. Entrada de Datos/Dinamicos` (ficheros recurrentes).

El destino de las exportaciones (§8.2) es otra ubicación de SharePoint Online, `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`. La URL completa del sitio no se ha podido obtener.

El lakehouse auxiliar `StagingLakehouseForDataflows_...` y el warehouse `StagingWarehouseForDataflows_...` son artefactos técnicos que Fabric crea automáticamente como staging de los Dataflows Gen2 — no forman parte del modelo de negocio.

---

## 4. Flujo de datos de extremo a extremo

```
Ficheros Excel/CSV en SharePoint (shortcut /Files/Reporting Financiero)
|
|-- Dinamicos --[INGESTA_Carga_Datos]--> capa 100 (New_*)
|                                         |--[TRANS_Silver]--> capa 200 (MMS, Portugal, HAPA,
|                                                               Oracle_historico, Aging_*)
|                                                               |--[TRANS_Gold]--> capa 300 (Fact_Actuals,
|                                                                                  Dim_Cuentas, Dim_Mapeo_Cuentas)
|
|-- Arranque --[INICIAL_Carga_Oracle, INICIAL_Carga_Agings]--> capa 200 (Oracle_historico, Aging_*)
|           --[INICIAL_Carga_budget_fct]--> capa 200 (Presupuestos)
|           --[INICIAL_Carga_Revenues]--> capa 200 (Revenues, sin consumidor conocido)
|           --[INICIAL_Carga_Rentabilidades]--> capa 300 (Fact_Asignacion_RRHH, Dim_equipos, Dim_CDC)
|
|-- Maestros.xlsx, MASTER RRHH --[INGESTA_Maestros]--> capa 200 (Mapping_*, COA_Oracle)
                                                      capa 300 (Dim_Calendar, Dim_Clientes, Dim_Sociedades,
                                                                Dim_Report_Line, Map_Report_Line_Account,
                                                                Dim_CDC, Dim_RRHH, Aux_CDC)

Vistas SQL vw_Export_* (sobre el SQL endpoint)
  --[Notebook Generar_txt_Balance_Saldos]--> Files/Exportaciones/Balance/*.txt
  --[Copy "Grabar balance"]--> SharePoint "2. Salida de ficheros/Balance"

Capas 200 y 300 --> Financial Model (Direct Lake) --> Informes MMS, Presupuesto, Rentabilidad, HAPA, Checklist (Oracle)
                --> Agings (modelo)             --> Informe Agings
Informes --> App "Tinkle - Financiero"

Financial Model --> Planning --[writeback]--> CPM (dbo.FT3_Revenue, dbo.FT8_Revenue). Nada lee de CPM.
```

El pipeline `Generar Reporting` orquesta la primera mitad de esta cadena (ingesta → silver → gold → refresco de los dos modelos semánticos); el pipeline `Grabar salidas` ejecuta el notebook y copia sus salidas a SharePoint. Ambos pueden dispararse bajo demanda desde las dos User Data Functions del workspace. Detalle completo en §7 (notebook), §8 (pipelines) y §9 (UDF).

---

## 5. Dataflows Gen2 — definiciones Power Query M

Todos los dataflows leen y escriben en el lakehouse `lh_tinkle_financiero` (`4d2305f1-7ef6-42c3-87ed-aed12f143ac2`), salvo `Seguridad_CDC`, que no lee ningún origen externo. Los nombres de consultas que aparecen son los definidos dentro de cada dataflow.

Cuatro dataflows tienen un nombre interno distinto del nombre visible en el workspace, lo que conviene saber al buscar en el código o en los logs:

| Nombre en el workspace | Nombre interno en la definición |
|---|---|
| `INICIAL_Carga_Oracle` | `INICIAL_Carga_Oracle_Checklist` |
| `INGESTA_Maestros` | `INGESTAS INICIALES` |
| `INGESTA_Carga_Datos` | `INGESTA_Carga_Oracle` |
| `TRANS_Silver` | `TRANS_Carga_datos` |

### 5.1 Cargas iniciales

| Dataflow (id) | Fuentes de entrada | Transformación principal / consultas M | Destino |
|---|---|---|---|
| `INICIAL_Carga_Oracle` (`bc6e3c41-2f60-4954-9a75-6cd17dd2ca39`) | `/Files/Reporting Financiero/1. Entrada de Datos/Arranque/1-Checklist 2026 03(v11) - copia.xlsm`, hoja `Oracle`. Lakehouse, `DatasourceId` `ebd2d2e1-1cee-4cb0-8333-e6349b6c8528`. | `Carga Oracle historico desde Checklist`: importa, promueve encabezados, renombra, tipa y limpia fechas/texto. | `Oracle_historico`, esquema `200`. |
| `INGESTA_Maestros` (`60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6`) | `Maestros.xlsx` (MAPPING HAPA, CDC, Clientes, MAPPING PORTUGAL, COA Oracle) y `MASTER RRHH 2026 .xlsx` (MASTER). | Limpieza, promoción de encabezados, tipado, ordenación, deduplicación, calendario, normalización de clientes/sociedades y mapeos de cuentas/reportes. También contiene las consultas `Assets_Reporte`, `Liabilities_Reporte`, `PL_Reporte` y sus variantes `*_Cuentas`, que no se cargan en ninguna tabla. | Esquema `200`: `Mapping Portugal`, `Mapping_HAPA`, `COA_Oracle`. Esquema `300`: `Dim_Calendar`, `Dim_Clientes`, `Dim_Sociedades`, `Dim_Report_Line`, `Map_Report_Line_Account`, `Dim_CDC`, `Dim_RRHH`, `Aux_CDC`. |
| `INICIAL_Carga_budget_fct` (`ccf7112d-ffd7-41c0-ac41-ac394ea63e65`) | `1-Checklist 2026 03(v11) - copia.xlsm` (B01 JAZZ, ONION, PORT, CONS y TOTAL) y `TINKLE FORECAST 2026 FT3.xlsm`. | `B01 ...` y `FORECASTS y BUDGET`: combina hojas, promueve encabezados, separa columnas, elimina auxiliares, tipa, desnormaliza meses y deriva año/periodo. | `Presupuestos`, esquema `200`. |
| `INICIAL_Carga_Revenues` (`3efad19a-3c01-449a-a5b2-cb55f4ba2082`) | `Revenue 2026 FT3.xlsx`, hojas `Revenue by client FT3 2026` y otras cuyo nombre contiene `Revenue by`, bajo `.../Arranque`. | Filtra hojas, expande `Data`, promueve encabezados, filtra compañías/clientes, renombra `Origen`, convierte meses a filas, deriva `Año`, rellena compañía y tipa `Valor`. Consultas: `Carga historica revenues`, `Revenue by client FT3 2026`. | `Revenues`, esquema `200`. |
| `INICIAL_Carga_Agings` (`e9e60e41-5456-4d95-9b1e-32e66c795f94`) | `2026 03 31- AGING Clientes Grupo Tinkle TOTAL HMES.xlsx` (DATOS) y `2026 03 31(01) Cartera Prov - TOTAL.xlsx` (Datos). | Promoción de encabezados, selección/renombrado, reemplazo de valores y tipado. | `Aging_Clientes` y `Aging_Proveedores`, esquema `200`. |
| `INICIAL_Carga_Rentabilidades` (`ca02d1da-5790-448a-84ba-e0e6a5e4708e`) | Libro Excel `RENTABILIDAD`, bajo `.../Arranque`. | `Fact_Asignacion_RRHH` importa/combina bloques, detecta encabezados, elimina columnas, convierte números/porcentajes y usa joins; `Dim_equipos` deriva la dimensión; `Dim_CDC` se construye aquí también. | Esquema `300`: `Fact_Asignacion_RRHH`, `Dim_equipos` y `Dim_CDC` (misma tabla que escribe `INGESTA_Maestros`, ver §5.5). |

### 5.2 Ingesta y seguridad

| Dataflow (id) | Fuentes de entrada | Transformación principal / consultas M | Destino |
|---|---|---|---|
| `INGESTA_Carga_Datos` (`c8d12168-9a15-4df6-8632-eb647c58a861`) | `/Files/Reporting Financiero/1. Entrada de Datos/Dinamicos`; ficheros Excel/CSV y hojas `Datos`, `Hoja1`, `AGINGS/Datos` y `HMES___Aging_en_Detalle_todas__`. | `Carga_New_MMS`, `Carga_New_Oracle`, `Carga_New_PT_extrato_contas`, `Carga_New_HAPA_asientos` y cargas de aging: navegación dinámica, `Excel.Workbook`/`Csv.Document`, combinación, promoción de encabezados, limpieza, ordenación y tipado. | Esquema `100`: `New_MMS`, `New_Oracle`, `New_PT_extrato_contas`, `New_Agings_Proveedores`, `New_Agings_Clientes`. La consulta `Carga_New_HAPA_asientos` está marcada como no cargable, así que `New_HAPA` no recibe datos de este dataflow (ver §5.5). |
| `Seguridad_CDC` (`42e8fdba-1dfa-469c-9a26-118ea3df5bb0`) | Tabla literal M (`Table.FromRows`), columnas `Usuario`, `CDC`, `eMail`; no lee fichero externo. `DatasourceId` `f51eee19-0247-47ab-aea7-4c0f6d566601`. | Construcción de la tabla estática de seguridad y tipado de texto; consulta `RLS` no cargable. | Ninguno activo: existe el auxiliar `RLS_DataDestination`, pero la consulta `RLS` no tiene destino asignado. La tabla `100.RLS` no se actualiza desde este dataflow. |

### 5.3 Silver y Gold

| Dataflow (id) | Fuentes de entrada | Transformación principal / consultas M | Destino |
|---|---|---|---|
| `TRANS_Silver` (`e34a567e-3986-467e-ac59-9c89b8014b87`) | Tablas raw del esquema `100`: `New_MMS`, `New_Oracle`, `New_PT_extrato_contas`, `New_HAPA`, `New_Agings_Clientes`, `New_Agings_Proveedores`. | `200_New_MMS_trans`, `200_New_Oracle_trans`, `200_New_HAPA_trans`, `200_Portugal_trans`, `200_HAPA`, `200_Oracle`, `200_MMS` y aging: tipado/limpieza, normalización, deduplicación, filtros, combinaciones y parámetros de fecha. | Esquema `200`: `MMS`, `Portugal`, `HAPA`, `Oracle_historico`, `Aging_Clientes`, `Aging_Proveedores`. |
| `TRANS_Gold` (`2ddb6bc7-1a91-490f-9a6b-60ade6940b4e`) | Tablas del esquema `200`: `Oracle_historico`, `HAPA`, `Portugal`, `Mapping Portugal`, `Mapping_HAPA` y `COA_Oracle` (consultas de referencia no cargables). | Combina fuentes contables, selecciona/renombra, filtra/deduplica, normaliza fechas/texto, deriva periodo/ejercicio y claves. | Esquema `300`: `Fact_Actuals`, `Dim_Cuentas`, `Dim_Mapeo_Cuentas`. |

### 5.4 Observaciones

- Los bloques `*_DataDestination` son consultas auxiliares de referencia; los destinos usan `Kind = "Reference"` y `TypeSettings = [Kind = "Table"]`.
- Ningún dataflow de los anteriores escribe en `Budget_historico` (esquema `200`, §2.2): no tiene productor conocido dentro del workspace (tampoco Planning, ver §10). Puede ser una tabla histórica/legacy en desuso; confirmar con el propietario del proceso antes de archivarla o depender de ella.
- Patrón de carga inicial + recurrente: `Oracle_historico`, `Aging_Clientes` y `Aging_Proveedores` (esquema `200`) tienen dos productores cada una — el dataflow `INICIAL_*` correspondiente (`INICIAL_Carga_Oracle`, `INICIAL_Carga_Agings`) hace la carga histórica/de arranque, y `TRANS_Silver` las mantiene después de forma recurrente a partir de la capa `100`. El resto de dataflows `INICIAL_*` (`INICIAL_Carga_budget_fct`, `INICIAL_Carga_Revenues`) cargan directamente desde Excel a su tabla en `200` sin pasar por la capa `100`, y no tienen contrapartida recurrente documentada.
- `TRANS_Silver` tiene dos parámetros calculados: `pFechaContable_New_Oracle` = `List.Min(#"Changed type"[Fecha Contable])` y `pFecha_New_HAPA` = `List.Min(#"Changed type"[Fecha])`, es decir, la fecha mínima de los datos nuevos. Probablemente sirven para conservar el histórico anterior a esa fecha y sustituir el resto por la carga nueva, lo que explica que `Oracle_historico` se escriba en modo Replace sin perder histórico. Pendiente de verificar en el código M de `200_Oracle` y `200_HAPA`. El resto de dataflows no declara parámetros.

### 5.5 Destinos y modo de escritura

Todas las escrituras son en modo **Replace** (sustituyen la tabla completa en cada ejecución); no hay ningún destino en modo Append. "Automático" indica que el esquema de la tabla se ajusta al de la consulta; "Fijo" indica un esquema definido.

| Dataflow | Consulta | Tabla destino | Esquema de la tabla |
|---|---|---|---|
| `INICIAL_Carga_Oracle` | Carga Oracle historico desde Checklist | `200.Oracle_historico` | Fijo |
| `INGESTA_Maestros` | Mapping HAPA | `200.Mapping_HAPA` | Automático |
| `INGESTA_Maestros` | Mapping Portugal | `200.Mapping Portugal` | Fijo |
| `INGESTA_Maestros` | COA_Oracle | `200.COA_Oracle` | Automático |
| `INGESTA_Maestros` | Dim_CDC, Dim_Calendar, Dim_Clientes, Dim_Sociedades, Map_Report_Line_Account, Dim_Report_Line, Dim_RRHH, Aux_CDC | `300.<mismo nombre>` | Automático |
| `INICIAL_Carga_budget_fct` | FORECASTS y BUDGET | `200.Presupuestos` | Automático |
| `INICIAL_Carga_Revenues` | Carga historica revenues | `200.Revenues` | Automático |
| `INICIAL_Carga_Agings` | Carga Aging Clientes historico | `200.Aging_Clientes` | Automático |
| `INICIAL_Carga_Agings` | Carga Aging Proveedores historico | `200.Aging_Proveedores` | Automático |
| `INICIAL_Carga_Rentabilidades` | Fact_Asignacion_RRHH, Dim_equipos, Dim_CDC | `300.<mismo nombre>` | Automático |
| `INGESTA_Carga_Datos` | Carga_New_MMS, Carga_New_PT_extrato_contas, Carga_New_Agings_Proveedores, Carga_New_Agings_Clientes | `100.New_MMS`, `100.New_PT_extrato_contas`, `100.New_Agings_Proveedores`, `100.New_Agings_Clientes` | Automático |
| `INGESTA_Carga_Datos` | Carga_New_Oracle | `100.New_Oracle` | Fijo |
| `TRANS_Silver` | 200_New_Agings_Proveedores, 200_New_Agings_Clientes, 200_Oracle | `200.Aging_Proveedores`, `200.Aging_Clientes`, `200.Oracle_historico` | Fijo |
| `TRANS_Silver` | 200_Portugal_trans, 200_HAPA, 200_MMS | `200.Portugal`, `200.HAPA`, `200.MMS` | Automático |
| `TRANS_Gold` | Dim_mapeo_cuentas, Dim_Cuentas, Fact_Actuals | `300.Dim_Mapeo_Cuentas`, `300.Dim_Cuentas`, `300.Fact_Actuals` | Automático |
| `Seguridad_CDC` | Ninguna | Ninguna | |

Consultas sin destino (intermedias o de referencia):

- `INGESTA_Maestros`: `Assets_Reporte`, `Assets_Reporte_Cuentas`, `Liabilities_Reporte`, `Liabilities_Reporte_Cuentas`, `PL_Reporte`, `PL_Reporte_Cuentas`.
- `INICIAL_Carga_budget_fct`: `B01 JAZZ`, `B01 ONION`, `B01 PORT`, `B01 CONS`, `B01 TOTAL (Checklist)`.
- `INICIAL_Carga_Revenues`: `Revenue by client FT3 2026`.
- `INGESTA_Carga_Datos`: `Carga_New_HAPA_asientos`.
- `Seguridad_CDC`: `RLS`.
- `TRANS_Silver`: `200_New_MMS_trans`, `200_New_Oracle_trans`, `200_New_HAPA_trans`, `pFechaContable_New_Oracle`, `pFecha_New_HAPA`.
- `TRANS_Gold`: `Oracle_historico`, `HAPA`, `Portugal`, `200_Mapping Portugal`, `200_Mapping_HAPA`, `200_COA_Oracle`.

Consecuencias:

- **Tablas con dos productores**: `200.Oracle_historico`, `200.Aging_Clientes`, `200.Aging_Proveedores` y `300.Dim_CDC`. Al ser todo Replace, prevalece la última ejecución. Relanzar un `INICIAL_*` después de las cargas recurrentes sustituye los datos vigentes por los del fichero de arranque.
- **Tablas sin productor activo**: `100.New_HAPA` (la consulta `Carga_New_HAPA_asientos` no es cargable), `100.RLS` (`Seguridad_CDC` no tiene destino) y `200.Budget_historico`. Conservan los datos de la última escritura. Pendiente de verificar si `200.HAPA` se sigue actualizando por otra vía.
- **Lectores de las tablas `200`**: `Portugal`, `HAPA`, `Mapping Portugal`, `Mapping_HAPA` y `COA_Oracle` solo las lee `TRANS_Gold`. `Presupuestos` y `MMS` solo las lee `Financial Model`. `Revenues` y `Budget_historico` no tienen ningún lector conocido.

---

## 6. Modelo semántico `Financial Model`

- Item `Financial Model` (`847ce270-06ab-408b-85c9-cb8f390fad1c`), origen lakehouse `lh_tinkle_financiero`.
- Modo **Direct Lake**: la expresión de origen apunta al endpoint OneLake del lakehouse, esquemas `200` y `300`.
- 17 tablas (incluida `_Medidas`) y 40 medidas en `_Medidas`. 15 tablas en Direct Lake; `Unidades` y `_Medidas` son tablas calculadas en modo import.
- 16 relaciones, todas activas (las de §6.2). No hay roles de seguridad (RLS ni OLS).
- Definición completa: `fabric/Financial Model.SemanticModel/` (verificado el 2026-10-26).

### 6.1 Tablas cargadas

| Grupo | Tablas | Función |
|---|---|---|
| Hechos contables y operativos | `Fact_Actuals`, `MMS`, `Presupuestos` | Actuals contables, previsiones/operaciones MMS y presupuesto. |
| Hechos de personas | `Fact_Asignacion_RRHH` | Porcentaje de dedicación y coste imputado por empleado, equipo y cliente. |
| Dimensiones financieras | `Dim_Cuentas`, `Dim_Mapeo_Cuentas`, `Dim_Report_Line`, `Map_Report_Line_Account` | Plan de cuentas, equivalencias y construcción de filas de reporting. |
| Dimensiones de negocio | `Dim_Clientes`, `Dim_Sociedades`, `Dim_Calendar` | Clientes, sociedades y calendario financiero. |
| Dimensiones de organización | `Dim_RRHH`, `Dim_equipos`, `Dim_CDC`, `Aux_CDC` | Empleados, equipos, centros de coste y mapeo de CDC. |
| Auxiliares y medidas | `Unidades`, `_Medidas` | `Unidades` es una tabla auxiliar de escala de visualización (unidades/miles), no proviene del lakehouse; `_Medidas` contiene las medidas DAX. |

### 6.2 Relaciones

Salvo indicación, las relaciones son de muchos a uno y filtran en un solo sentido.

| Desde | Hacia | Observaciones |
|---|---|---|
| `Fact_Actuals.Fecha` | `Dim_Calendar.Fecha` | Fecha de los movimientos. |
| `Fact_Actuals.Sociedad` | `Dim_Sociedades.Sociedad` | Sociedad contable. |
| `Fact_Actuals.ID_Account` | `Dim_Mapeo_Cuentas.ID_Account` | Cuenta origen a cuenta mapeada. |
| `Fact_Actuals.ClienteKey_Oracle` | `Dim_Clientes.ClienteKey_Oracle` | Cliente Oracle. |
| `MMS.Compañia` | `Dim_Sociedades.Sociedad_MMS` | Sociedad de MMS. |
| `MMS.PERIODO` | `Dim_Calendar.Orden_Mes` | Periodo mensual; cardinalidad de destino muchos. |
| `MMS.ClienteKey_MMS` | `Dim_Clientes.ClienteKey_MMS` | Cliente MMS. |
| `Dim_Cuentas.ID_Account` | `Dim_Mapeo_Cuentas.ID_Account` | Uno a uno, en ambos sentidos (bidireccional). |
| `Dim_Mapeo_Cuentas.Cuenta_magnitude` | `Presupuestos.Cuenta` | Cuenta presupuestaria; cardinalidad muchos a muchos. |
| `Presupuestos.CodigoSociedad` | `Dim_Sociedades.CodigoSociedad` | Sociedad del presupuesto. |
| `Map_Report_Line_Account.Report_Line_Key` | `Dim_Report_Line.Report_Line_Key` | Línea de informe. |
| `Aux_CDC.INICIALES CAPTIO` | `Dim_CDC.INICIALES CAPTIO` | Mapeo auxiliar de CDC. |
| `Dim_Clientes.SECCION` | `Dim_CDC.INICIALES CAPTIO` | Sección a centro de coste. |
| `Fact_Asignacion_RRHH.Empleado` | `Dim_RRHH.NOMBRE` | Empleado asignado. |
| `Fact_Asignacion_RRHH.ClienteMMS` | `Dim_Clientes.Cliente MMS` | Relación en ambos sentidos (bidireccional). |
| `Fact_Asignacion_RRHH.EquipoKey` | `Dim_equipos.EquipoKey` | Equipo de la asignación. |

### 6.3 Medidas DAX principales

- **Reporting contable y presupuesto:** `ASOC01 - Statutory data`, `FCT`, `Budget Base`, `Budget Net Income`, `Budget Reporting Cuentas`, `DIF_ASOC01_FCT`, `Importe Base`, `Importe Reporting Cuentas`, `Net Income Reporting`, `REAL (Fees & other)`.
- **Escala y fuentes:** `Escala Seleccionado`, `Importe MMS`.
- **Comparativa Real vs MMS / gross income:** `Honorarios Real`, `Producción Real`, `Coste Producción`, `Gross Income Real`, `Honorarios MMS`, `Producción MMS`, `Gross income MMS`, `Desviación Gross Income`, `% Desviación Gross Income`, `Estado GI`.
- **Coste salarial:** `2025_salario`, `2025_salario_total`, `2026_salario`, `2026_salario_total`, `2026_Coste_total_salarial`, `Coste SSGG 2026`, `Coste SSGG Bonus 2025`, `COSTE TOTAL CON BONUS Y GRATIFICACION`, `DIF salarial año anterior`.
- **Dedicación y rentabilidad:** `% Dedicación`, `% Dedicación Total Persona`, `Estado Dedicación Persona`, `Coste Personal Imputado Total 2026`, `Coste Personal Imputado Cliente 2026`, `Contribution MMS 2026`, `% Contribution MMS 2026`, `Nº Personas Asignadas`.
- **Formato:** `Color Fondo Reporting`, que devuelve el color de fondo de una fila según `Dim_Report_Line[Etiqueta]`.

Patrones destacados: `Importe Base` suma `Fact_Actuals[Saldo]` y divide por `Escala Seleccionado`; `Importe MMS` aplica el mismo patrón sobre `MMS[IMPORTE]`. Las medidas de reporting usan `Map_Report_Line_Account` para resolver referencias, factores y signos de las líneas financieras. `Gross Income Real`/`Gross income MMS` combinan honorarios, producción y coste de producción para comparar Real frente a MMS. Las medidas de dedicación calculan porcentajes, personas asignadas y coste salarial prorrateado mediante `SUMX`, `RELATED` y `PctDedicacion`.

### 6.4 Informes consumidores

| Informe | Id | Modelo semántico |
|---|---|---|
| `Checklist (Oracle)` | `ac83ce13-5a64-4ef7-bbb2-05b3e1439b5e` | `Financial Model` |
| `MMS` | `97052b38-d2fd-4a01-afbf-bfb8ebc8b1a7` | `Financial Model` |
| `Presupuesto` | `9f2f023c-592a-4ce0-bc6f-8adad4a28a41` | `Financial Model` |
| `Rentabilidad` | `b4d83714-386f-4a97-abcb-5db71937d442` | `Financial Model` |
| `HAPA` | `97d0a79d-09ff-4d6b-9cf0-b3e2b1e3fa47` | `Financial Model` |
| `Agings` | `05c3bd2c-c699-4d04-92c6-1828a375f9cf` | `Agings` (`e19def87-fdf3-4b44-bd60-d22e5d79ce88`) — no usa `Financial Model`. |

Ningún informe tiene descripción. No se han podido obtener páginas, visuales ni fecha de modificación de los informes, ni qué informes incluye la app.

### 6.5 Modelo semántico `Agings`

Definición completa en `fabric/Agings.SemanticModel/` (verificado el 2026-10-26).

- Id `e19def87-fdf3-4b44-bd60-d22e5d79ce88`. Único consumidor: el informe `Agings`. Se refresca en el paso 7 del pipeline `Generar Reporting` (§8.1).
- Modo **import** (no Direct Lake). Lee `200.Aging_Clientes` y `200.Aging_Proveedores` por el SQL endpoint del lakehouse (tablas `200 Aging_Clientes` y `200 Aging_Proveedores`).
- `Aging_Clientes_Snapshot` y `Aging_Proveedores_Snapshot` son tablas calculadas: cruzan cada factura pendiente con cada fecha de corte de un calendario fijo del 2026-01-01 al 2027-12-31 y calculan los días vencidos (`DaysDue`) y el tramo (`AgingBucket`) a esa fecha. `Fechas` es el mismo calendario.
- 5 medidas: `Saldo pendiente` y `Facturas clientes`, `Importe pendiente` y `Facturas proveedores`, y `fechaseleccionada`.
- Relaciones: cada snapshot con su tabla de origen por `ID_aging` y con `Fechas` por fecha, más las tablas automáticas de fecha de Power BI (`LocalDateTable_*`).
- Sin roles de seguridad.

---

## 7. Notebook `Generar_txt_Balance_Saldos`

- Id: `c649ae24-2b54-4fce-bd5c-d23a9516ec37`. 11 celdas (parámetros, lectura, validaciones, transformación, generación de ficheros).
- **Lecturas**: vía `spark.read.synapsesql`, desde el SQL endpoint del lakehouse, las vistas `vw_Export_Grupo` y `vw_Export_Saldos_4_7` del esquema `200` (§2.2).
- **Transformación "Balance"**: selecciona 27 columnas en orden fijo, castea a string sustituyendo nulos por vacío, redondea `P_AMOUNT` a entero, valida obligatoriedad de campos, formato de periodo `YYYY.MM`, coherencia `D_DP`/`D_PE` y `D_RU`/`D_ORU`, duplicados y multiplicidad de periodo por sociedad; ordena por sociedad/cuenta con un orden especial A, P, R (con `P12000` en posición fija).
- **Transformación "Saldos 4_7"**: selecciona Sociedad, CodigoFichero, PeriodoTexto, Periodo, Cuenta, Descripcion, Saldo; normaliza nulos, calcula `PeriodoCodigo` (`yyyy.MM`), ordena por código de fichero/cuenta, valida unicidad de periodo por código, y formatea importes con convención española (punto de miles, coma decimal, negativos entre paréntesis).
- **Ficheros generados** (normalmente 5+5, uno por sociedad/código):
  - Balance: `.txt` (escrito internamente como CSV), delimitador `;`, con cabecera, UTF-8, nulos como vacío. Ruta: `Files/Exportaciones/Balance/{periodo}/{sociedad}_Balance_{MES-YY}_{YYYYMMDD_HHMMSS}.txt`. Mapeo de sociedad: ESP066→TINKLE_COMM, ESP067→TINKLE_EU, ESP068→TINKLE_JAZZ, ESP069→TINKLE_ONION, ESP070→TINKLE_CONS.
  - Saldos 4_7: TXT de ancho fijo, con fecha/hora, sociedad, cabeceras, separadores y saltos CRLF. Ruta: `Files/Exportaciones/Balance/{periodo}/{CodigoFichero}_Saldos_4_7_{MES-YY}_{YYYYMMDD_HHMMSS}.txt`.
  - Timestamp incluido (`INCLUIR_TIMESTAMP = True`) y sobrescritura activada (`SOBRESCRIBIR = True`).
- El notebook implementa la generación directamente en Python (`escribir_balance`, `construir_saldos_4_7`, `escribir_lineas_txt`); no llama a las UDF `Generar_txt` ni `Ejecución Reporting` (§9) — la relación con ellas es indirecta, a través del pipeline que lo ejecuta (§8.2).

---

## 8. Pipelines

### 8.1 `Generar Reporting` (`147b24eb-352f-4f88-9d64-b4a7fc1d67f6`)

Flujo lineal y secuencial, sin ramas de fallo explícitas (condiciones observadas: `Succeeded`/`Completed`) y sin trigger/schedule embebido en la definición (se dispara manualmente o desde la UDF `Ejecución Reporting`, §9.1):

1. **Carga** — `RefreshDataflow` del dataflow `INGESTA_Carga_Datos` (`c8d12168-9a15-4df6-8632-eb647c58a861`). Timeout 12 h, sin reintentos.
2. **RefreshSqlEndpoint1_copy1** — `RefreshSqlEndpoint` sobre el SQL endpoint de `lh_tinkle_financiero` (`485f1bd4-2372-44a3-b279-e00a63a80137`). Depende de 1 (Succeeded).
3. **Transformaciones SILVER** — `RefreshDataflow` del dataflow `TRANS_Silver` (`e34a567e-3986-467e-ac59-9c89b8014b87`). Depende de 2 (Succeeded).
4. **RefreshSqlEndpoint1** — `RefreshSqlEndpoint` sobre el mismo SQL endpoint. Depende de 3 (Succeeded).
5. **Transformaciones GOLD** — `RefreshDataflow` del dataflow `TRANS_Gold` (`2ddb6bc7-1a91-490f-9a6b-60ade6940b4e`). Depende de 4 (Succeeded).
6. **Semantic model refresh1** — `PBI SemanticModelRefresh` del modelo `Financial Model` (`847ce270-06ab-408b-85c9-cb8f390fad1c`), conexión `634b4683-a1cb-4197-8442-b23d936b319d`. Depende de 5 (Completed).
7. **Semantic model refresh1_copy1** — `PBI SemanticModelRefresh` del modelo `Agings` (`e19def87-fdf3-4b44-bd60-d22e5d79ce88`), misma conexión. Depende de 6 (Completed).

Orquesta la actualización íntegra del reporting: ingesta → silver → gold → refresco de los dos modelos semánticos consumidos por los informes.

### 8.2 `Grabar salidas` (`56a37cd5-3664-47b4-b28f-ec7f26d23075`)

Sin parámetros de pipeline. Dos actividades:

1. **Notebook1** (`TridentNotebook`) — ejecuta el notebook `Generar_txt_Balance_Saldos` (`c649ae24-2b54-4fce-bd5c-d23a9516ec37`, §7). Sin dependencias.
2. **Grabar balance** (`Copy`) — depende de que Notebook1 termine correctamente (timeout 12 h, sin reintentos). Origen: Lakehouse/OneLake, `lh_tinkle_financiero`, carpeta `Files/Exportaciones/Balance`, patrón `*.txt`, lectura recursiva. Destino: SharePoint Online, `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, conservando jerarquía de carpetas.

No existe dependencia declarada entre `Generar Reporting` y `Grabar salidas` a nivel de definición — cada uno solo referencia sus propias actividades. El orden entre ambos (típicamente Generar Reporting antes que Grabar salidas) lo da quien los invoca externamente: las dos UDF del workspace (§9) o una programación no incluida en las definiciones de los pipelines.

### 8.3 Programaciones e historial

En las definiciones de pipelines, dataflows, notebook y modelos no aparece ninguna programación. El conector no permite leer el programador de Fabric ni el historial de ejecuciones, por lo que no se ha podido confirmar si existen programaciones, ni su frecuencia, duración o tasa de fallos. Pendiente de verificar en el portal (Monitor y configuración de programación de cada item).

---

## 9. User Data Functions

### 9.1 `Ejecución Reporting` (`27467e82-89d3-44fc-8c93-4ae54fd4d193`)

Función `ejecutar_reporte_financiero() -> str`, sin parámetros, endpoint público habilitado. Obtiene un token de Entra ID (`ClientSecretCredential`) y hace `POST` a la API REST de Fabric para ejecutar el pipeline **`Generar Reporting`** (§8.1). Comprueba HTTP 202, extrae `job_id` de la cabecera `Location` y devuelve mensaje de éxito/error.

### 9.2 `Generar_txt` (`30f6466d-8780-4886-84b8-70ebc13e6d1e`)

Función `ejecutar_generacion_txt() -> str`, misma estructura que la anterior, pero ejecuta el pipeline **`Grabar salidas`** (§8.2).

Ambas funciones usan el SDK de User Data Functions de Fabric (`@udf.function()`), `azure.identity` (`ClientSecretCredential`) y `requests`, y solicitan el alcance `https://api.fabric.microsoft.com/.default`. No usan conexión gestionada ni Key Vault. No se ha podido confirmar si `TENANT_ID` y `CLIENT_ID` también están incrustados ni qué permiso exacto hace falta para invocarlas.

### 9.3 Flujo de ejecución bajo demanda

```
UDF "Ejecución Reporting" --API REST--> Pipeline "Generar Reporting" (ingesta -> silver -> gold -> refresco modelos)
UDF "Generar_txt"          --API REST--> Pipeline "Grabar salidas"    (Notebook Generar_txt_Balance_Saldos -> Copy a SharePoint)
```

Ambos endpoints son públicos: también podrían invocarse desde fuera del workspace (Power BI, Power Automate, etc.).

### 9.4 Riesgo de seguridad

El código fuente de ambas funciones tiene el `CLIENT_SECRET` de la aplicación Entra ID incrustado en texto plano en `function_app.py`, en vez de leerse desde un almacén seguro (Key Vault / Connection gestionada de Fabric). Cualquier principal con acceso de lectura al item (rol Viewer/Contributor del workspace, exportación, backup, sync a git) puede leer ese secreto y autenticarse como esa aplicación contra la API de Fabric con sus mismos permisos; es una credencial que no caduca hasta rotarse manualmente.

Para corregirlo hacen falta dos acciones independientes: (1) rotar el secreto en Entra ID — Azure Portal / Microsoft Graph / Azure CLI, requiere permisos de administrador de la aplicación registrada, ningún conector de Fabric puede hacerlo; y (2) editar `function_app.py` para leer el secreto desde una Connection gestionada de Fabric o Key Vault — esto sí requiere el conector `fabric` con permisos de escritura sobre el item. Pendiente de decisión, sin tocar por ahora.

---

## 10. Planning y CPM

- `Planning` (`50ce99b8-0525-435f-bc71-56235a557714`) está conectado al modelo semántico `Financial Model` y contiene 4 hojas de planificación:
  - **Revenue FT3**: forecast de ingresos FT3 (medidas `REAL (Fees & other)`, `Importe MMS`, `FC3 Revenue`; dimensiones cliente/ejercicio/mes).
  - **Revenue FT8**: forecast de ingresos FT8 (`REAL (Fees & other)`, `Importe MMS`, `FC8 Revenue`).
  - **Dedicaciones**: planificación de dedicación de recursos (`% Dedicación`, directora, equipo, cliente, empleado).
  - **Revenue_testing**: hoja oculta de pruebas, estructura equivalente a Revenue FT3.
- **Writeback a `CPM`** (`b85d1457-6ce1-441c-b8cb-21cb839d688a`, esquema `dbo`): `Revenue FT3` escribe en `CPM.dbo.FT3_Revenue` y `Revenue FT8` en `CPM.dbo.FT8_Revenue`, mediante operación `PushData` con precisión decimal de 2 posiciones y mapeo `Dim_Clientes[Descripción]` → columna SQL `Descripcion`. `Dedicaciones` no tiene destino de writeback configurado.
- Las medidas `FC3 Revenue` y `FC8 Revenue` no figuran entre las 40 medidas de `Financial Model` (§6.3); lo más probable es que se definan en Planning. Pendiente de verificar junto con su fórmula.
- No se han podido consultar las tablas de `CPM` ni su número de filas. Ningún dataflow, pipeline, notebook ni modelo del workspace lee de `CPM`.
- **Sincronización con el lakehouse**: unidireccional lakehouse → Planning, no al revés. El lakehouse alimenta `Financial Model` vía dataflows (p. ej. `INICIAL_Carga_budget_fct` carga `200.Presupuestos`, §5.1) y transformaciones silver/gold; Planning consume ese modelo. No existe sincronización de vuelta desde `CPM` hacia `lh_tinkle_financiero` — los datos introducidos en Planning quedan en `CPM` salvo que se añada una carga adicional (no presente hoy).

---

## 11. Gobierno, seguridad y capacidad

### 11.1 Roles del workspace

| Rol | Usuarios | Grupos | Entidades de servicio | Total |
|---|---|---|---|---|
| Admin | 3 | 0 | 0 | 3 |
| Member | 3 | 0 | 2 | 5 |
| Contributor | 0 | 0 | 0 | 0 |
| Viewer | 4 | 0 | 0 | 4 |

Todos los permisos se asignan a personas o entidades de servicio individuales; no hay grupos de Entra ID. Las dos entidades de servicio tienen rol Member, que permite editar y ejecutar cualquier item del workspace; una de ellas es previsiblemente la aplicación usada por las UDF (§9).

### 11.2 Capacidad

| Campo | Valor |
|---|---|
| Id | `c410e399-2954-4304-a90c-95f0444a7f46` (2026-10-26) |
| Región | West Europe |
| Nombre y SKU | No visibles con la cuenta `reporting@likuit.com`: no la tiene entre sus capacidades. |

El 2026-09-24 el workspace estaba en una capacidad **de prueba** (`Trial-20260817T105409Z-...`, id `a9930e38-9c96-4e90-bde2-70677c5fb90a`, SKU `FTL64`). El 2026-10-26 está en otra capacidad. Pendiente de confirmar con el cliente que es de pago y quién la administra.

### 11.3 Seguridad de datos

- `Financial Model` y `Agings` no tienen roles RLS ni OLS (verificado en el TMDL el 2026-10-26): cualquier usuario con acceso a un informe ve todos los datos, incluidos los salariales.
- La tabla `100.RLS` no se actualiza (§5.5) y no está entre las tablas de `Financial Model` (§6.1).
- `Dim_RRHH` contiene datos salariales y se carga en `Financial Model`.
- Audiencias de la app: consta `test_app`; número de miembros y otras audiencias pendientes de verificar.
- Integración con git y deployment pipelines: no se ha podido comprobar.

---

## 12. Glosario

Los términos marcados como "a confirmar" se han deducido de los nombres de tablas y ficheros.

| Término | Significado |
|---|---|
| Actuals | Datos contables reales (frente a presupuesto o forecast). |
| Agings | Antigüedad de saldos pendientes de cobro (clientes) y de pago (proveedores). |
| ASOC01 | Datos estatutarios (`ASOC01 - Statutory data`). A confirmar. |
| Captio | Herramienta de gestión de gastos; `INICIALES CAPTIO` es el código de centro de coste usado en ella. A confirmar. |
| CDC | Centro de coste. |
| Checklist | Libro Excel de cierre mensual (`1-Checklist 2026 03(v11)`) que contiene hojas de Oracle y presupuesto. |
| CPM | Base de datos SQL donde Planning guarda los datos introducidos (writeback). |
| FT3, FT8 | Versiones de forecast del ejercicio (`TINKLE FORECAST 2026 FT3`, `Revenue 2026 FT3`). A confirmar el significado exacto del número. |
| HAPA | Origen contable adicional con asientos propios y mapeo de cuentas (`Mapping_HAPA`). A confirmar. |
| MMS | Sistema operativo de medios y campañas (proveedor, soporte, campaña, importes). |
| Oracle | ERP contable. Sus datos llegan como extractos Excel, no por conexión directa. |
| PT extrato contas | Extracto de cuentas de la sociedad de Portugal. |
| SSGG | Concepto de coste salarial (`Coste SSGG 2026`). A confirmar. |

---

## 13. Auditoría: problemas detectados y mejoras posibles

Primera revisión el 2026-09-24 a partir del contenido de este documento. Ese mismo día se contrastó con el workspace en modo solo lectura (respuestas `res1.txt` a `res8.txt`); el resultado de esa verificación y los hallazgos nuevos están en §13.6. Las tablas de §13.1 a §13.4 recogen la redacción original de cada punto.

Prioridad: Alta (riesgo de seguridad, pérdida o corrupción de datos), Media (fiabilidad, mantenimiento, errores de reporting), Baja (claridad y calidad de la documentación).

### 13.1 Seguridad y gobierno

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| S1 | Alta | `CLIENT_SECRET` en texto plano en `function_app.py` de las dos UDF (§9.4), marcado como "pendiente de decisión". | Rotar el secreto de inmediato y leerlo desde Key Vault o una Connection gestionada. Asignar responsable y fecha. Revisar si el item se ha exportado o sincronizado a git y purgar el historial. |
| S2 | Alta | Endpoints públicos de las UDF sin parámetros ni control adicional (§9.3): cualquiera con permiso de invocación puede lanzar los pipelines repetidamente. | Restringir quién puede invocar, registrar el llamante y evitar ejecuciones concurrentes (comprobar si hay un job en curso antes de lanzar otro). |
| S3 | Alta | `Dim_RRHH` contiene salarios y costes por empleado (§2.3) y se carga en `Financial Model`, que alimenta varios informes y la app. El documento no indica ninguna restricción (RLS, OLS, permisos). | Documentar y aplicar OLS o un modelo separado para datos salariales; limitar la audiencia de la app. |
| S4 | Alta | La tabla `RLS` (esquema `100`) no figura entre las tablas de `Financial Model` (§6.1) ni se mencionan roles. Todo indica que la seguridad por centro de coste no se aplica en los informes. | Confirmar si existen roles RLS en `Financial Model` y `Agings`; si no, definirlos o eliminar la tabla y el dataflow `Seguridad_CDC`. |
| S5 | Media | `Seguridad_CDC` define usuarios y correos como tabla literal en código M (§5.2): datos personales en el código y mantenimiento manual editando el dataflow. | Mover la tabla de seguridad a un fichero o tabla mantenida por negocio, o a grupos de Entra ID. |
| S6 | Media | El shortcut de entrada apunta a un OneDrive personal (`/personal/reporting_likuit_com/`, §3). Si la cuenta se desactiva, se rompe toda la ingesta. Además, el dominio `likuit` no coincide con Tinkle. | Migrar a un sitio de SharePoint de equipo y documentar la cuenta propietaria. |
| S7 | Media | Existe una audiencia `test_app` y una hoja oculta `Revenue_testing` en Planning (§1, §10) dentro del entorno productivo. | Separar entornos (desarrollo, pruebas, producción) con deployment pipelines o eliminar los elementos de prueba. |
| S8 | Baja | No se documentan roles del workspace, propietarios de items, audiencias reales de la app ni integración con git. | Añadir una sección de gobierno con roles, propietarios y control de versiones. |

### 13.2 Orquestación y fiabilidad

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| O1 | Alta | En `Generar Reporting` los refrescos de modelos dependen de la condición `Completed` (§8.1, pasos 6 y 7): se refrescan aunque `TRANS_Gold` falle, publicando datos incompletos o inconsistentes. | Cambiar a `Succeeded` y añadir una rama de fallo con notificación (correo, Teams). |
| O2 | Alta | No hay dependencia entre `Generar Reporting` y `Grabar salidas` (§8.2). Las UDF solo comprueban el HTTP 202 (§9.1), es decir, que el job se ha encolado, no que haya terminado. Se puede generar el TXT antes de que termine la actualización. | Crear un pipeline padre que ejecute ambos en secuencia, o que la UDF espere el estado final del job antes de devolver éxito. |
| O3 | Alta | Doble productor de `Oracle_historico`, `Aging_Clientes` y `Aging_Proveedores` (§5.4). El documento no indica el modo de escritura (reemplazar o anexar) de ningún dataflow. Relanzar un `INICIAL_*` o `TRANS_Silver` en modo reemplazo puede borrar el histórico. | Documentar el modo de actualización de cada destino y bloquear o archivar los dataflows `INICIAL_*` ya ejecutados. |
| O4 | Media | `INGESTA_Maestros`, `Seguridad_CDC`, `INICIAL_Carga_budget_fct`, `INICIAL_Carga_Revenues` e `INICIAL_Carga_Rentabilidades` no están en ningún pipeline. No se sabe cómo ni cuándo se actualizan maestros, presupuesto, RRHH y dedicaciones. | Incluirlos en la orquestación o documentar su proceso y frecuencia de ejecución manual. |
| O5 | Media | `Grabar salidas` lee las vistas vía SQL endpoint (§7) sin refrescar antes los metadatos del endpoint, a diferencia de `Generar Reporting`. | Añadir `RefreshSqlEndpoint` antes del notebook. |
| O6 | Media | Timeout de 12 min y sin reintentos en la carga (§8.1); sin reintentos en ninguna actividad. | Ajustar timeouts a la duración real y configurar al menos un reintento en actividades idempotentes. |
| O7 | Media | Los TXT se generan con timestamp y nunca se borran; la copia a SharePoint es recursiva sobre `*.txt` (§7, §8.2). Cada ejecución vuelve a copiar todo el histórico y la carpeta crece sin límite. | Copiar solo la carpeta del periodo actual o mover los ficheros procesados a una carpeta de archivo. |
| O8 | Media | El documento dice que no hay programación en la definición (§8.1, §8.2), pero las programaciones de Fabric se guardan fuera de la definición. | Verificar y documentar las programaciones reales, horarios y responsables. |
| O9 | Baja | Nombres de actividades por defecto (`RefreshSqlEndpoint1_copy1`, `Semantic model refresh1_copy1`, `Notebook1`). | Renombrar con nombres descriptivos para facilitar el seguimiento en el monitor. |
| O10 | Baja | Las dos UDF duplican el mismo código cambiando solo el pipeline (§9.2). | Una única función parametrizada por nombre de pipeline, con lista cerrada de valores permitidos. |

### 13.3 Arquitectura y modelo de datos

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| M1 | Media | Arquitectura medallion no respetada: `INGESTA_Maestros` e `INICIAL_Carga_Rentabilidades` escriben directamente en `300`, otros `INICIAL_*` escriben en `200` sin pasar por `100`, y `TRANS_Gold` lee Excel directamente (§5). | Documentar las excepciones o hacer que todas las fuentes pasen por `100`. |
| M2 | Media | Rutas y nombres de fichero fijos y frágiles: `1-Checklist 2026 03(v11) - copia.xlsm`, `MASTER RRHH 2026 .xlsx` (con espacio final), `Revenue 2026 FT3.xlsx`, `2026 03 31- AGING ...` (§5.1). Cualquier cambio de nombre rompe la carga. | Nombres estables o carga por carpeta con filtros; parametrizar año y periodo. |
| M3 | Media | Año fijo en medidas y columnas (`2025_salario`, `2026_Coste_total_salarial`, `SALARIO 2025/2026`, §2.3 y §6.3). Obliga a modificar modelo e informes cada año. | Modelar los salarios en formato largo (empleado, año, concepto, importe) y medidas relativas al año seleccionado. |
| M4 | Media | Relación `MMS.PERIODO` hacia `Dim_Calendar.Orden_Mes` muchos a muchos (§6.2) y dos relaciones bidireccionales (`Dim_Cuentas` y `Dim_Mapeo_Cuentas`, `Fact_Asignacion_RRHH` y `Dim_Clientes`). Riesgo de ambigüedad, resultados inesperados y peor rendimiento. | Crear una dimensión de periodo mensual con clave única y revisar si las bidireccionales son imprescindibles. |
| M5 | Media | Relaciones sobre texto libre: `Fact_Asignacion_RRHH.Empleado` hacia `Dim_RRHH.NOMBRE`, `ClienteMMS` hacia `Cliente MMS` (§6.2). Un cambio de escritura rompe el cruce. | Usar claves de empleado y cliente estables. |
| M6 | Media | `Presupuestos` y `Fact_Asignacion_RRHH` no tienen relación con `Dim_Calendar` (§6.2). Además, `Fact_Actuals` se relaciona con `Dim_Sociedades` por `Sociedad` y `Presupuestos` por `CodigoSociedad`. | Relacionar todos los hechos con el calendario y usar la misma clave de sociedad. |
| M7 | Media | Tablas sin consumidor conocido: `Budget_historico` (ya señalada), `Revenues`, `Portugal`, `HAPA`, `Mapping Portugal`, `Mapping_HAPA` y `COA_Oracle` de `200` no aparecen en el modelo (§6.1) ni se indica qué dataflow las lee. | Documentar el linaje tabla a tabla o eliminar lo que no se use. |
| M8 | Media | Mapeo de sociedades fijo en el notebook (ESP066 a ESP070, §7). Una sociedad nueva quedaría fuera o fallaría sin aviso. | Leer el mapeo de `Dim_Sociedades` y fallar de forma explícita si falta una sociedad. |
| M9 | Media | Planning no devuelve datos al lakehouse (§10): los forecasts FT3/FT8 quedan en `CPM` y no se pueden usar en los informes. `Dedicaciones` no tiene writeback, por lo que lo introducido se pierde fuera de Planning. | Decidir si se necesita una carga de `CPM` hacia el lakehouse y un destino para `Dedicaciones`. |
| M10 | Baja | Nombres de columnas con espacios, tildes y símbolos (`Num. Tercero`, `Intercía`, `Num & Nom Tercero_`, `Cuenta & Descripción`, `Compañia`), mezcla de convenciones (`Dim_equipos` y `Dim_CDC`, español e inglés) y esquemas numéricos (`100`, `200`, `300`) que obligan a entrecomillar en SQL. | Definir y aplicar una convención de nombres. |
| M11 | Baja | Los TXT de Saldos 4_7 se guardan en la carpeta `Balance` (§7). | Usar carpetas separadas por tipo de fichero. |
| M12 | Baja | `Unidades` no procede del lakehouse en un modelo Direct Lake (§6.1). A verificar cómo está implementada, porque Direct Lake tiene limitaciones con tablas calculadas. | Documentar su implementación o sustituirla por un parámetro de campo o una tabla en el lakehouse. |

### 13.4 Problemas de la propia documentación

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| D1 | Media | Contradicción sobre el origen Oracle: §3 y §4 hablan de "ingesta desde Oracle", pero §5.1 muestra que `INICIAL_Carga_Oracle` lee una hoja `Oracle` de un Excel y `INGESTA_Carga_Datos` lee ficheros Excel/CSV. No hay conexión directa a Oracle. | Corregir §3 y §4 para indicar que todas las fuentes son ficheros. |
| D2 | Media | §2 describe la capa `100` como "cargas iniciales tal cual origen", pero las cargas `INICIAL_*` escriben en `200` o `300`; la capa `100` la llena `INGESTA_Carga_Datos`. | Corregir la descripción de la capa `100`. |
| D3 | Media | §6 indica 17 relaciones, pero la tabla de §6.2 solo tiene 16. Tampoco queda claro si las 17 tablas incluyen `_Medidas`. | Revisar los recuentos y completar la relación que falta. |
| D4 | Media | §6.2 no indica cardinalidad, dirección de filtro ni estado activo o inactivo de cada relación, y la columna "Desde/Hacia" no sigue un criterio uniforme (por ejemplo `Dim_Mapeo_Cuentas` hacia `Presupuestos`). | Añadir columnas de cardinalidad, dirección y estado. |
| D5 | Media | Informes duplicados: `MMS` y `Checklist (Oracle)` tienen dos ids en §1, pero §6.4 solo recoge uno de cada (faltan `a0c690f7...` y `ee58e006...`). | Documentar qué es cada copia o eliminar las sobrantes. |
| D6 | Media | El modelo semántico `Agings` no está documentado (tablas, modo, relaciones, medidas). | Añadir una sección equivalente a §6. |
| D7 | Media | El diagrama de §4 no muestra `INGESTA_Maestros` ni las escrituras directas a `200`/`300`, y coloca el notebook tras la capa `300` cuando lee vistas de `200` (§7). | Actualizar el diagrama con el flujo real. |
| D8 | Media | Faltan las definiciones SQL de `vw_Export_Grupo` y `vw_Export_Saldos_4_7`, quién las mantiene y de qué tablas leen. | Incluir el SQL o al menos su linaje. |
| D9 | Media | Destino de `Assets_Reporte`, `Liabilities_Reporte`, `PL_Reporte` y "consultas de cuentas" de `TRANS_Gold` (§5.3) sin concretar; no aparecen en §2.3. | Indicar si se cargan en alguna tabla o son intermedias. |
| D10 | Media | Posible doble productor de `Dim_CDC` (`INGESTA_Maestros` y `INICIAL_Carga_Rentabilidades`, §5.1) sin aclarar cuál prevalece. | Aclarar el productor efectivo. |
| D11 | Baja | Medidas usadas por Planning (`FC3 Revenue`, `FC8 Revenue`) no aparecen entre las 40 medidas de §6.3. | Indicar dónde se definen. |
| D12 | Baja | Esquema de columnas incompleto para `300`: §2 dice "detallado más abajo", pero §2.3 recorta con "..." (`Dim_Cuentas`, `Dim_RRHH`). | Generar un TSV equivalente para `300` o completar las tablas. |
| D13 | Baja | Faltan metadatos del documento: fecha de extracción, versión, autor, responsable del proceso y registro de cambios. Existe una copia `_backu_20262209` con nombre y fecha mal formados. | Añadir cabecera de control de versiones y usar git o el historial de SharePoint en lugar de copias manuales. |
| D14 | Baja | Sin glosario de términos de negocio (MMS, HAPA, CDC, Captio, FT3, FT8, ASOC01, SSGG, Agings). | Añadir un glosario. |
| D15 | Baja | Sin información operativa: frecuencia de ejecución, duración esperada, calendario de cierre, cómo diagnosticar fallos y a quién avisar. | Añadir una sección de operación y soporte (runbook). |
| D16 | Baja | Texto técnico interno poco útil para el lector (`get_item_definition`, "nombres internos `shared` de `mashup.pq`"). En §1, la app aparece con dos ids sin explicar a qué corresponde cada uno. | Simplificar y aclarar. |
| D17 | Baja | El documento depende de ids concretos del workspace, que cambian entre entornos. | Indicar el entorno al que corresponde y, si hay varios, separar los ids por entorno. |

### 13.5 Acciones recomendadas por orden

Orden actualizado tras la verificación de §13.6:

1. Confirmar la fecha de caducidad de la capacidad de prueba y planificar el paso a una capacidad de pago (N1).
2. Rotar el secreto y sacarlo del código de las UDF (S1).
3. Corregir las condiciones `Completed` y añadir alertas de fallo (O1).
4. Encadenar `Generar Reporting` y `Grabar salidas` en un pipeline padre (O2).
5. Revisar la seguridad de datos salariales y RLS; decidir qué hacer con la tabla `RLS` sin actualizar (S3, S4, N3).
6. Revisar la carga de HAPA, que no tiene destino activo en la capa `100` (N2).
7. Proteger el histórico: bloquear o archivar los `INICIAL_*` ya ejecutados y fijar un único productor de `Dim_CDC` (O3, N4).
8. Reducir privilegios de las entidades de servicio y usar grupos de Entra ID (N5).
9. Migrar el origen de ficheros desde el OneDrive personal a un sitio de equipo (S6).
10. Completar lo que sigue pendiente (§13.7): programaciones, historial, Planning y capacidad.

### 13.6 Verificación del 2026-09-24 y hallazgos nuevos

**Estado de los puntos anteriores**

| # | Estado | Resultado |
|---|---|---|
| S1 | Confirmado | Secreto incrustado; las UDF no usan Key Vault ni conexión gestionada (§9.2). |
| S2 | Parcial | Endpoints públicos confirmados; permiso exacto de invocación no disponible. |
| S3, S4 | Pendiente | Roles RLS/OLS no verificables sin TMDL. Agravado por N3. |
| S6 | Confirmado | Sin cambios; la URL del sitio de destino de las exportaciones tampoco está disponible. |
| S7 | Confirmado | `test_app` existe; miembros no disponibles. |
| S8 | Resuelto en parte | Roles documentados en §11.1. Git y deployment pipelines no verificables. |
| O3 | Confirmado | Todo es Replace y hay cuatro tablas con dos productores (§5.5). |
| O4 | Confirmado | No se han encontrado programaciones para los dataflows fuera de pipelines. |
| O8 | Pendiente | No hay programaciones en las definiciones; el programador no es accesible (§8.3). |
| M1 | Corregido | `TRANS_Gold` no lee Excel: solo tablas `200`. La lectura de Excel se hace en `INGESTA_Maestros`. |
| M7 | Resuelto | Lectores identificados (§5.5). `Revenues` y `Budget_historico` siguen sin consumidor. |
| M9 | Confirmado | Nada lee de `CPM`. |
| D1, D2, D7, D16 | Resuelto | Corregidos §1, §2, §3, §4 y §5. |
| D3, D4 | Pendiente | TMDL no disponible (§6). |
| D5 | Resuelto | Las copias `a0c690f7...` y `ee58e006...` ya no existen (§1). |
| D6 | Pendiente | Sección §6.5 creada con lo conocido; TMDL no disponible. |
| D8, D12 | Pendiente | El conector no ejecuta SQL. |
| D9 | Resuelto | Las consultas `*_Reporte` están en `INGESTA_Maestros` y no tienen destino (§5.1, §5.5). |
| D10 | Resuelto | `INGESTA_Maestros` e `INICIAL_Carga_Rentabilidades` escriben `Dim_CDC` en Replace; prevalece la última ejecución. |
| D11 | Pendiente | `FC3 Revenue` y `FC8 Revenue` probablemente en Planning (§10). |
| D13 | Resuelto en parte | Cabecera de control añadida al inicio. |
| D14 | Resuelto en parte | Glosario en §12, con términos a confirmar. |
| D15 | Pendiente | Sin historial de ejecuciones ni programaciones no se puede redactar la guía de operación. |

**Hallazgos nuevos**

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| N1 | Alta | El workspace está en una capacidad de prueba (`FTL64`, creada el 2026-08-17 según su nombre, §11.2). Al caducar, pipelines, dataflows, modelos e informes dejan de funcionar. | Confirmar la fecha de caducidad y asignar el workspace a una capacidad de pago antes de esa fecha. |
| N2 | Alta | `Carga_New_HAPA_asientos` no es cargable, así que `100.New_HAPA` no se actualiza (§5.2, §5.5). `TRANS_Silver` y `TRANS_Gold` siguen procesando HAPA con datos antiguos, lo que puede dejar desactualizado el informe `HAPA`. | Verificar si es intencionado; si no, restaurar el destino de la consulta. |
| N3 | Alta | `Seguridad_CDC` no tiene destino activo: `100.RLS` no se actualiza y los cambios de usuarios o CDC no llegan a la tabla. | Decidir si la RLS por CDC sigue vigente; si es así, restaurar el destino y enlazarla al modelo; si no, retirar el dataflow y la tabla. |
| N4 | Media | Cuatro tablas con dos productores en Replace (`Oracle_historico`, `Aging_Clientes`, `Aging_Proveedores`, `Dim_CDC`). | Un solo productor por tabla; deshabilitar o archivar los `INICIAL_*` ya ejecutados. |
| N5 | Media | Dos entidades de servicio con rol Member y ningún grupo de Entra ID (§11.1). Si el secreto de S1 pertenece a una de ellas, quien lo lea puede modificar cualquier item del workspace. | Rol mínimo necesario para cada entidad de servicio (o permiso solo sobre los pipelines) y roles asignados a grupos. |
| N6 | Media | Nombres internos de dataflows distintos de los visibles (`INGESTA_Carga_Datos` se llama internamente `INGESTA_Carga_Oracle`, §5). | Alinear los nombres internos con los visibles. |
| N7 | Baja | Ningún informe tiene descripción (§6.4). | Añadir una descripción breve a cada informe y modelo. |
| N8 | Baja | `Revenues` (`200`) se carga pero nadie la lee (§5.5). | Confirmar si se necesita (quizá para Planning) o retirarla junto con `INICIAL_Carga_Revenues`. |

### 13.7 Verificación del 2026-10-26 con las definiciones exportadas

Contraste con `reporting-financiero/fabric/` (exportado por API) y con el SQL endpoint. Los items de §1 siguen existiendo y los destinos de los dataflows de §5.5 no han cambiado.

| # | Estado | Resultado |
|---|---|---|
| S3, S4 | Confirmado | Ni `Financial Model` ni `Agings` tienen roles RLS u OLS. Los datos salariales de `Dim_RRHH` son visibles para cualquiera con acceso a los informes de `Financial Model`. |
| O6 | Corregido | El timeout de las actividades de los pipelines es de 12 h, no de 12 min. Ninguna tiene reintentos. |
| M12 | Resuelto | `Unidades` y `_Medidas` son tablas calculadas en modo import dentro del modelo Direct Lake. |
| D3, D4 | Resuelto | 16 relaciones, todas activas; 17 tablas con `_Medidas`. Cardinalidad y dirección en §6.2. |
| D6 | Resuelto | Modelo `Agings` documentado en §6.5. |
| D8 | Resuelto | Definiciones de las vistas en `fabric/sql/`. |
| D12 | Resuelto | Esquema de columnas de `100`, `200` y `300` en `fabric/lakehouse/esquema.tsv`. |
| N1 | Cambiado | El workspace ya no está en la capacidad de prueba (§11.2); falta confirmar el tipo de la nueva. |
| O8, D15, D11 | Pendiente | Programaciones, historial y medidas de Planning no se han revisado. |

**Hallazgos nuevos**

| # | Prioridad | Problema | Mejora propuesta |
|---|---|---|---|
| N9 | Baja | `300.vw_Reporting_Actuals` no estaba documentada y nada del workspace la lee. | Confirmar si es un trabajo en curso (por ejemplo, para sustituir medidas de reporting) o retirarla. |
| N10 | Media | Las tablas snapshot del modelo `Agings` usan un calendario fijo del 2026-01-01 al 2027-12-31. A partir de 2028 el informe no tendrá fechas de corte. | Generar el calendario a partir de las fechas de los datos o de la fecha actual. |

Cómo se obtiene y se mantiene al día esta información: `docs/flujo-fabric.md`.
