---
type: repo-readme
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
tags: [rf-fabric]
---

# rf-fabric

Copia en texto, exportada por API, del workspace de Microsoft Fabric "Tinkle - Financiero": modelos, informes, dataflows, pipelines, notebook y vistas SQL del reporting financiero de Tinkle.

## Secciones

- [[overview]]: qué items hay en el workspace, de qué tipo son y cómo se regenera la copia.
- [[architecture]]: capas del lakehouse, dataflows, orden de los pipelines Generar Reporting y Grabar salidas, y modelos que se refrescan.
- [[domain-model]]: tablas, relaciones y modo de almacenamiento de los modelos Financial Model y Agings.
- [[apis]]: medidas DAX por familia, informes, páginas y vistas SQL que consume el reporting.
- [[data-model]]: tablas del lakehouse por esquema (100, 200 y 300), con su productor, y tablas con dos productores o sin productor.
- [[integrations]]: ficheros de entrada desde OneDrive o SharePoint, conexiones de los modelos y salida del balance a SharePoint.
- [[configuration]]: formato de cada tipo de item, ficheros de metadatos, política de reintentos y flujo de publicación y rollback.
- [[quality]]: validaciones del notebook de Grupo, comprobación de coincidencia con Fabric y riesgos de calidad abiertos.
