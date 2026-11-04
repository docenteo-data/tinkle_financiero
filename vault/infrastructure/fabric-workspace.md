---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, fabric-workspace]
---

# Microsoft Fabric - workspace "Tinkle - Financiero"

**Responsabilidad:** workspace de Microsoft Fabric que aloja todos los items del reporting financiero: lakehouse, dataflows Gen2, pipelines de datos, notebook Spark, modelos semánticos e informes de Power BI. Es el único entorno del cliente; no hay workspace de pruebas.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - copia en texto de los 28 items del workspace: 10 dataflows, 9 pipelines, 1 notebook, 2 modelos semánticos y 6 informes (conteo de carpetas `*.Dataflow`, `*.DataPipeline`, `*.Notebook`, `*.SemanticModel` y `*.Report` en `reporting-financiero/fabric/`; `reporting-financiero/fabric/Generar Reporting.DataPipeline/pipeline-content.json`, `reporting-financiero/fabric/Agings.SemanticModel/.platform`)
- [[repos/rf-scripts/README|rf-scripts]] - exporta las definiciones del workspace, compara con un commit, publica cambios en items existentes y crea items nuevos solo con `publicar_fabric.py --crear --confirmar` (`reporting-financiero/scripts/fabric_comun.py#WORKSPACE_ID`, `reporting-financiero/scripts/fabric_comun.py#crear_item`, `reporting-financiero/scripts/publicar_fabric.py`); lanza pipelines y espera su job con `reporting-financiero/scripts/ejecutar_fabric.py` (`reporting-financiero/scripts/fabric_comun.py#lanzar_pipeline`, `reporting-financiero/scripts/fabric_comun.py#esperar_job`)

## Pipelines y flujos

- Pipelines modulares (9 en total): `Ingesta_datos` (dataflows INGESTA_Maestros e INGESTA_Carga_Datos, y refresco del SQL endpoint), `Transformacion_datos` (TRANS_Silver y TRANS_Gold, con refresco del SQL endpoint tras cada capa), `Refresco_modelos` (refresco de Financial Model y Agings), `Generar_salidas` (notebook `Generar_txt_Balance_Saldos` y copia a SharePoint), `Flujo_actualizar_datos`, `Flujo_total_reporting` y `Flujo_total_txt` (flujos que encadenan pipelines con `ExecutePipeline` y `waitOnCompletion`), y los dos pipelines anteriores `Generar Reporting` y `Grabar salidas`. Fuente: `reporting-financiero/fabric/*.DataPipeline/pipeline-content.json`.
- Condición de dependencia: `Succeeded` en los pipelines nuevos. `Generar Reporting` usa `Completed` en sus refrescos de modelos, así que un fallo previo no lo detiene.
- El historial de jobs de un pipeline no lista las ejecuciones que otro pipeline lanza con `ExecutePipeline`; para saber si un hijo corrió dentro de un flujo hay que mirar el flujo o las tablas (`reporting-financiero/docs/flujo-fabric.md`, sección 2).

## Configuration & deployment

- **How it is deployed**: no hay despliegue como código. Los items se crean y editan en Fabric; el repositorio guarda una copia exportada en `reporting-financiero/fabric/`. La publicación inversa la hace `rf-scripts`, con confirmación explícita. Los items nuevos se crean vacíos en Fabric o con `--crear`, y luego se rellenan desde el repositorio (`reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`).
- **Key settings**: el identificador del workspace y del tenant están en las constantes de `reporting-financiero/scripts/fabric_comun.py` y no se copian aquí. Pipelines: sin reintentos (0), timeout de 12 horas en todas las actividades. La programación de los pipelines no figura en la definición exportada.
- **Modelo Agings**: está enlazado a una conexión explícita en la nube del SQL endpoint de `lh_tinkle_financiero`, con OAuth2, y su configuración la gestiona la cuenta `reporting@likuit.com`. Antes, usaba la conexión por defecto y el refresco fallaba con Premium_ASWL_Error. El arreglo se hizo el 04/11/2026 (`reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`, sección "Arreglo de Agings").

## Notes

- Capacidad: asignada en West Europe, con id no copiado aquí. Desde el 2026-10-26 ya no es la capacidad de prueba del 2026-09-24. Su nombre y SKU no son visibles con la cuenta `reporting@likuit.com`, que no la tiene entre sus capacidades; si es de pago y quién la administra está pendiente de confirmar con el cliente (`reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`, §11.2).
- TBD: nombres de los responsables del workspace (la fuente cuenta los roles por número de usuarios, §11.1, sin nombres).
- Los dataflows INICIAL_Carga_Agings, INICIAL_Carga_Oracle, INICIAL_Carga_Rentabilidades, INICIAL_Carga_Revenues e INICIAL_Carga_budget_fct, y Seguridad_CDC, no aparecen en ningún pipeline; su forma de ejecución está por confirmar.
- Las User Data Functions existen en el workspace, pero quedan fuera del versionado y de la publicación por decisión documentada en `rf-scripts`.
- Publicar una definición no restaura datos; el rollback solo restaura definiciones (`reporting-financiero/docs/flujo-fabric.md`). Crear un item solo sucede con `--crear`.
