---
type: repo-readme
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
tags: [rf-scripts]
---

# rf-scripts

Unidad de scripts Python que exportan, comparan, publican y consultan el workspace de Fabric de Tinkle.

## Secciones

- [[overview]]: qué script usar para cada tarea, qué escribe cada uno en Fabric y dónde está el procedimiento completo.
- [[architecture]]: módulo compartido `fabric_comun.py`, puntos de entrada y flujos de exportar, publicar y consultar SQL.
- [[apis]]: argumentos, valores por defecto y códigos de salida de cada script, y funciones públicas del módulo común.
- [[integrations]]: API REST de Fabric, Azure CLI como origen de los tokens, SQL endpoint del lakehouse y git local.
- [[configuration]]: constantes de conexión, entorno Python, cuenta de Azure CLI y datos locales.
- [[quality]]: tests unitarios, test E2E de solo lectura y protecciones frente a escrituras accidentales.

## Sin domain-model ni data-model

Esta unidad no define entidades, esquemas ni modelos propios. Manipula definiciones que ya existen en Fabric (TMDL, PBIR, dataflows, pipelines, notebooks y vistas SQL) tratándolas como texto, por lo que no hay secciones `domain-model` ni `data-model`. Detalle en [[overview]].
