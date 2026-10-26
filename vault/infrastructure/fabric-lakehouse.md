---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, fabric-lakehouse]
---

# Lakehouse lh_tinkle_financiero (Fabric)

**Responsabilidad:** lakehouse del workspace de Fabric que guarda las tablas del reporting en tres esquemas (100 bruto, 200 silver, histórico y mapeos, 300 gold en estrella), expone una zona Files con los ficheros de entrada y las exportaciones, y ofrece un SQL analytics endpoint de lectura para los modelos semánticos, las vistas y los scripts.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - los dataflows escriben tablas en los esquemas 100, 200 y 300 (`reporting-financiero/fabric/INGESTA_Carga_Datos.Dataflow/mashup.pq`); el modelo Financial Model abre el lakehouse en Direct Lake (`reporting-financiero/fabric/Financial Model.SemanticModel/definition/expressions.tmdl`); Agings lee el esquema 200 por el SQL endpoint (`reporting-financiero/fabric/Agings.SemanticModel/definition/tables/200 Aging_Clientes.tmdl`); el notebook lee dos vistas y escribe TXT en Files (`reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb`)
- [[repos/rf-scripts/README|rf-scripts]] - consulta el SQL endpoint, descarga las vistas y el esquema de columnas, y ofrece una consulta de solo lectura (`reporting-financiero/scripts/fabric_comun.py#SQL_SERVIDOR`, `reporting-financiero/scripts/fabric_comun.py#descargar_sql`, `reporting-financiero/scripts/consultar_sql.py`)

## Configuration & deployment

- **How it is deployed**: se crea en el workspace de Fabric; sus tablas las generan los dataflows y el notebook. El esquema de columnas exportado está en `reporting-financiero/fabric/lakehouse/esquema.tsv`.
- **Key settings**: nombre `lh_tinkle_financiero`; esquemas 100, 200 y 300; servidor y base de datos del SQL endpoint en constantes de `reporting-financiero/scripts/fabric_comun.py`, no copiados aquí. La carpeta de entrada de la zona Files es un shortcut a OneDrive o SharePoint (ver [[infrastructure/sharepoint-online|SharePoint Online]]).
- **Acceso**: los scripts usan el SQL endpoint con token de Entra, sin usuario ni contraseña, y el filtro de `consultar_sql.py` solo admite SELECT o WITH.

## Notes

- Tablas con dos productores en modo Replace (Oracle_historico, Aging_Clientes y Aging_Proveedores): relanzar una carga inicial puede sustituir el histórico.
- Budget_historico no tiene productor en la definición exportada.
- TBD: confirmar que la identidad de las consultas de los scripts tiene permisos de solo lectura; el filtro es por palabras clave, no un analizador SQL.
