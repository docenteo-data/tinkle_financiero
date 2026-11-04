---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, fabric-lakehouse]
---

# Lakehouse lh_tinkle_financiero (Fabric)

**Responsabilidad:** lakehouse del workspace de Fabric que guarda las tablas del reporting en tres esquemas (100 bruto, 200 silver, histórico y mapeos, 300 gold en estrella), expone una zona Files con los ficheros de entrada y las exportaciones, y ofrece un SQL analytics endpoint que leen los modelos semánticos, el notebook de salida y los scripts, y en el que `rf-scripts` también crea las vistas de exportación.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - los dataflows escriben tablas en los esquemas 100, 200 y 300 (`reporting-financiero/fabric/INGESTA_Carga_Datos.Dataflow/mashup.pq`); el modelo Financial Model abre el lakehouse en Direct Lake (`reporting-financiero/fabric/Financial Model.SemanticModel/definition/expressions.tmdl`); Agings lee el esquema 200 por el SQL endpoint (`reporting-financiero/fabric/Agings.SemanticModel/definition/tables/200 Aging_Clientes.tmdl`); el notebook lee las vistas de exportación del esquema 300 (`300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7`, `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb#ESQUEMA`) y escribe TXT en Files
- [[repos/rf-scripts/README|rf-scripts]] - consulta el SQL endpoint, descarga las vistas y el esquema de columnas, y ofrece una consulta de solo lectura (`reporting-financiero/scripts/fabric_comun.py#SQL_SERVIDOR`, `reporting-financiero/scripts/fabric_comun.py#descargar_sql`, `reporting-financiero/scripts/consultar_sql.py`); crea o reemplaza vistas de los esquemas 100, 200 y 300 con `CREATE VIEW` o `CREATE OR ALTER VIEW`, solo con `publicar_fabric.py --confirmar` (`reporting-financiero/scripts/fabric_comun.py#publicar_vista`, `reporting-financiero/scripts/fabric_comun.py#sentencia_de_vista`, `reporting-financiero/scripts/publicar_fabric.py`); lee `200.MMS`, `300.Fact_Actuals`, `300.Dim_Cuentas` y `300.Dim_Clientes` para validar los ficheros de Grupo (`reporting-financiero/scripts/validar_ficheros_grupo.py#consultar`)

## Configuration & deployment

- **How it is deployed**: se crea en el workspace de Fabric; sus tablas las generan los dataflows y el notebook. Las vistas de exportación se crean en el esquema 300 (`reporting-financiero/fabric/sql/`), y el esquema de columnas exportado está en `reporting-financiero/fabric/lakehouse/esquema.tsv`. Las vistas de exportación del esquema 200 (`vw_Export_*`) ya no están en Fabric: tras la corrección de la tarea 1, `Grabar salidas` terminó Completed "ya sin vistas en el 200" (`reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`, tarea 1).
- **Key settings**: nombre `lh_tinkle_financiero`; esquemas 100, 200 y 300; servidor y base de datos del SQL endpoint en constantes de `reporting-financiero/scripts/fabric_comun.py`, no copiados aquí. La carpeta de entrada de la zona Files es un shortcut a OneDrive o SharePoint (ver [[infrastructure/sharepoint-online|SharePoint Online]]).
- **Acceso**: los scripts usan el SQL endpoint con token de Entra, sin usuario ni contraseña. Las lecturas pasan por `consultar_sql.py`, que solo admite SELECT o WITH. Las escrituras son solo la creación de vistas: `publicar_vista` ejecuta la sentencia y confirma, mientras que las comprobaciones (líneas GO, esquemas fuera de 100, 200 y 300 y ficheros que no crean la vista indicada) están en `reporting-financiero/scripts/fabric_comun.py#sentencia_de_vista` y `#vista_de_ruta`; no borra vistas.

## Notes

- Tablas con dos productores en modo Replace (Oracle_historico, Aging_Clientes y Aging_Proveedores): relanzar una carga inicial puede sustituir el histórico.
- Budget_historico no tiene productor en la definición exportada.
- El refresco del SQL endpoint lo hacen los pipelines con actividades `RefreshSqlEndpoint`: `Ingesta_datos` tiene una sola, que espera a los dos dataflows (Maestros y Carga); `Transformacion_datos` refresca tras silver y tras gold; `Generar Reporting` refresca dos veces, tras la carga y tras silver (`reporting-financiero/fabric/*.DataPipeline/pipeline-content.json`).
- TBD: confirmar qué permisos concretos tiene la identidad de Azure CLI sobre el SQL endpoint. Hoy la lectura la garantiza el filtro de `consultar_sql.py`, no un permiso, y la identidad puede crear vistas (lo hace `publicar_vista`). El filtro es por palabras clave, no un analizador SQL.
