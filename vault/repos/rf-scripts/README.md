---
type: repo-readme
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
tags: [rf-scripts]
---

# rf-scripts

Unidad de scripts Python que exportan, comparan, publican y consultan el workspace de Fabric de Tinkle, validan los ficheros de Grupo contra los TXT de Magnitude y generan documentos de la auditoría.

## Secciones

- [[overview]]: qué script usar para cada tarea, qué escribe cada uno en Fabric y dónde está el procedimiento completo.
- [[architecture]]: módulo compartido `fabric_comun.py`, puntos de entrada y flujos de exportar, publicar, consultar SQL y validar ficheros de Grupo.
- [[apis]]: argumentos, valores por defecto y códigos de salida de cada script, y funciones públicas del módulo común.
- [[integrations]]: API REST de Fabric, Azure CLI como origen de los tokens, SQL endpoint del lakehouse, carpeta `3.Fuentes` de OneDrive y git local.
- [[configuration]]: constantes de conexión, entorno Python, cuenta de Azure CLI, rutas de fuentes y datos locales.
- [[quality]]: tests unitarios, tests E2E de solo lectura (Fabric y ficheros de Grupo) y protecciones frente a escrituras accidentales.

## Módulos

- [[repos/rf-scripts/modules/documentos]]: `anexo_pendientes.py` y `md_a_docx.py`, herramientas de documentos que no consultan Fabric.

## Dominio relacionado

- [[domains/ficheros-de-grupo]]: reglas de los ficheros de Grupo que comprueba `validar_ficheros_grupo.py`.

## Sin domain-model ni data-model

Esta unidad no define entidades, esquemas ni modelos propios. Manipula definiciones que ya existen en Fabric (TMDL, PBIR, dataflows, pipelines, notebooks y vistas SQL) tratándolas como texto, por lo que no hay secciones `domain-model` ni `data-model`. Las reglas de negocio de los ficheros de Grupo están en el dominio, no aquí. Detalle en [[overview]].
