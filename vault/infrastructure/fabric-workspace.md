---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, fabric-workspace]
---

# Microsoft Fabric - workspace "Tinkle - Financiero"

**Responsabilidad:** workspace de Microsoft Fabric que aloja todos los items del reporting financiero: lakehouse, dataflows Gen2, pipelines de datos, notebook Spark, modelos semánticos e informes de Power BI. Es el único entorno del cliente; no hay workspace de pruebas.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - copia en texto de los 21 items del workspace (10 dataflows, 2 pipelines, 1 notebook, 2 modelos semánticos y 6 informes) (`reporting-financiero/fabric/Generar Reporting.DataPipeline/pipeline-content.json`, `reporting-financiero/fabric/Agings.SemanticModel/.platform`)
- [[repos/rf-scripts/README|rf-scripts]] - exporta las definiciones del workspace, compara con un commit y publica cambios solo en items existentes (`reporting-financiero/scripts/fabric_comun.py#WORKSPACE_ID`, `reporting-financiero/scripts/publicar_fabric.py`)

## Configuration & deployment

- **How it is deployed**: no hay despliegue como código. Los items se crean y editan en Fabric; el repositorio guarda una copia exportada en `reporting-financiero/fabric/` y la publicación inversa solo se hace con `rf-scripts`, con confirmación explícita.
- **Key settings**: el identificador del workspace y del tenant están en las constantes de `reporting-financiero/scripts/fabric_comun.py` y no se copian aquí. Pipelines: sin reintentos (0), timeout de 12 horas y dependencias con condición Completed. La programación de los pipelines no figura en la definición exportada.

## Notes

- TBD: capacidad de Fabric, SKU y responsables del workspace (no aparecen en las fuentes revisadas).
- Los items INICIAL_*, INGESTA_Maestros y Seguridad_CDC no aparecen en ningún pipeline; su forma de ejecución está por confirmar.
- Las User Data Functions existen en el workspace, pero quedan fuera del versionado y de la publicación por decisión documentada en `rf-scripts`.
- Publicar una definición no restaura datos ni crea items; el rollback solo restaura definiciones (`reporting-financiero/docs/flujo-fabric.md`).
