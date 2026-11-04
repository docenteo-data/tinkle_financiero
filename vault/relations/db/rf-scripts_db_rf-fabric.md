---
type: relation
load_tier: 2
schema_version: 1
from: "[[repos/rf-scripts/README|rf-scripts]]"
to: "[[repos/rf-fabric/README|rf-fabric]]"
relation_type: db
tags: [relation, db]
---

# rf-scripts - db - rf-fabric

> One typed edge of the system graph. File path: `relations/db/rf-scripts_db_rf-fabric.md`.

## Type

Base de datos compartida: el SQL endpoint del lakehouse `lh_tinkle_financiero`. `rf-scripts` crea o actualiza en ese endpoint las vistas cuya definición vive en `fabric/sql/` de `rf-fabric`, y `rf-fabric` lee las de exportación desde su notebook. Además, `rf-scripts` lanza pipelines de `rf-fabric` que refrescan dataflows, y esos dataflows escriben tablas del lakehouse. No hay llamada de red entre repos: el acoplamiento pasa por los objetos de la base de datos.

## Detail

| Touchpoint | Mechanism | Configuration |
|---|---|---|
| `300.vw_Export_Grupo`, `300.vw_Export_Saldos_4_7`, `300.vw_Reporting_Actuals` | Escritura DDL: `CREATE VIEW` si la vista es nueva, `CREATE OR ALTER VIEW` si existe; nunca borra vistas | `publicar_fabric.py` con `sql/<esquema>.<vista>.sql`, `--ref` y `--base`; solo con `--confirmar` |
| `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` | Lectura SELECT desde el notebook `Generar_txt_Balance_Saldos` por el SQL analytics endpoint | Parámetro `periodo_esperado` del notebook (vacío no comprueba el periodo) |
| Tablas del lakehouse escritas por los dataflows que refrescan `Ingesta_datos`, `Transformacion_datos` y `Generar Reporting` | Escritura indirecta: los pipelines lanzados por `ejecutar_fabric.py` ejecutan actividades `RefreshDataflow`, directamente o mediante `ExecutePipeline`. `Flujo_actualizar_datos` lanza `Ingesta_datos` y `Transformacion_datos`; `Flujo_total_reporting` y `Flujo_total_txt` lanzan `Flujo_actualizar_datos` (como `Actualizar datos`), así que también escriben tablas | `ejecutar_fabric.py` con `--parametro` y `--confirmar`; el pipeline se busca por `displayName` en el workspace y no se lee de `fabric/`, así que editar `fabric/` sin publicar no cambia lo que se ejecuta |
| Ficheros de salida y refresco de modelos | `Generar_salidas` y `Grabar salidas` escriben ficheros; `Refresco_modelos` solo refresca modelos. `Flujo_total_txt` lanza `Generar_salidas` y `Flujo_total_reporting` lanza `Refresco_modelos` | `ejecutar_fabric.py` con `--confirmar` |
| Lectura de vistas y esquema para la copia local | Lectura SELECT del SQL endpoint al exportar; no modifica la base | `exportar_fabric.py` (sección de vistas y columnas) |

## Direction & contract

- **Caller / producer**: [[repos/rf-scripts/README|rf-scripts]]. Aplica en el SQL endpoint el DDL de las vistas y lanza pipelines cuyos dataflows escriben tablas del lakehouse.
- **Callee / consumer**: [[repos/rf-fabric/README|rf-fabric]]. Define las vistas en `fabric/sql/` y consume las de exportación en el notebook `Generar_txt_Balance_Saldos`.
- **Contract**: un fichero por vista, `fabric/sql/<esquema>.<vista>.sql`, cuya primera sentencia crea esa misma vista; sin líneas `GO`; esquemas 100, 200 y 300. Columnas en `fabric/lakehouse/esquema.tsv`. Sin versión formal.

## Evidence

En `rf-scripts` (origen de la escritura en la base de datos):
- `scripts/fabric_comun.py` - `vista_de_ruta` acepta solo `sql/100|200|300.<nombre>.sql`; `sentencia_de_vista` rechaza líneas `GO` y ficheros que no crean su vista y cambia `CREATE VIEW` por `CREATE OR ALTER VIEW` si existe; `publicar_vista` ejecuta la sentencia en el SQL endpoint y confirma el cambio.
- `scripts/publicar_fabric.py` - `_preparar_vistas` compara Fabric con `--base` y prepara las sentencias; `_publicar_vistas` las ejecuta con `--confirmar`.
- `scripts/ejecutar_fabric.py` - `main` busca el pipeline por `displayName` en el workspace y lo lanza; no lee nada de `fabric/`.
- Documentación del repo: `vault/repos/rf-scripts/integrations.md` (sección SQL endpoint del lakehouse, escritura de vistas) y `architecture.md` (flujo Publicar, paso de vistas).

En `rf-fabric` (origen de las vistas y consumidor de las de exportación):
- `fabric/sql/300.vw_Export_Grupo.sql`, `fabric/sql/300.vw_Export_Saldos_4_7.sql`, `fabric/sql/300.vw_Reporting_Actuals.sql` - definiciones de las vistas que `rf-scripts` publica.
- `fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` - lee `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` por el SQL endpoint.
- `fabric/Ingesta_datos.DataPipeline/pipeline-content.json`, `fabric/Transformacion_datos.DataPipeline/pipeline-content.json` y `fabric/Generar Reporting.DataPipeline/pipeline-content.json` - actividades `RefreshDataflow` que refrescan dataflows (los dataflows escriben tablas del lakehouse).
- `fabric/Flujo_actualizar_datos.DataPipeline/pipeline-content.json` - actividades `ExecutePipeline` que lanzan `Ingesta_datos` y `Transformacion_datos`. `fabric/Flujo_total_reporting.DataPipeline/pipeline-content.json` y `fabric/Flujo_total_txt.DataPipeline/pipeline-content.json` - lanzan `Flujo_actualizar_datos` (como `Actualizar datos`) y después `Refresco_modelos` o `Generar_salidas`.
- `fabric/Generar_salidas.DataPipeline/pipeline-content.json` y `fabric/Grabar salidas.DataPipeline/pipeline-content.json` - escriben ficheros.
- `fabric/Refresco_modelos.DataPipeline/pipeline-content.json` - actividades `PBISemanticModelRefresh`; solo refresca modelos.
- Documentación del repo: `vault/repos/rf-fabric/integrations.md` (sección Notebook y pipelines de salida), `apis.md` (sección Vistas SQL) y `lineage.md` (lectores de cada vista).

## Open questions

- TBD: lectores de `300.vw_Reporting_Actuals` fuera de los repositorios revisados; el repositorio no tiene ningún lector.
- TBD: si las versiones `200.vw_Export_*` siguen existiendo en el SQL endpoint; no las publica ni borra `rf-scripts`.
