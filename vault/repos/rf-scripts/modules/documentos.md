---
type: module
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
source_globs: ["anexo_pendientes.py", "md_a_docx.py"]
tags: [rf-scripts, module, documentos]
---

# rf-scripts - Herramientas de documentos

> Cuándo cargar: vas a regenerar el anexo de pendientes de la auditoría o a convertir un Markdown del proyecto a Word.

Dos scripts que trabajan sobre ficheros de `reporting-financiero/docs/` y no consultan Fabric ni Azure CLI. Se ejecutan desde la raíz del repositorio con el Python del `.venv`.

## anexo_pendientes.py

Genera el anexo "Pendientes por concepto" de la auditoría general.

| Argumento | Por defecto | Significado |
|---|---|---|
| `AUDITORIA` | obligatorio | Ruta del Markdown de la auditoría, por ejemplo `reporting-financiero/docs/auditoria/20261028-auditoria-general.md`. |

Lee la tabla de conceptos de la sección 1 y, de sus fuentes (registro de reuniones, auditoría técnica y preguntas para Tinkle), copia la descripción de cada punto pendiente. Escribe entre las marcas `<!-- anexo:inicio -->` y `<!-- anexo:fin -->` (las añade al final si no existen); volver a ejecutarlo deja el mismo resultado. Imprime `OK anexo con N puntos del registro`.

| Código | Significado |
|---|---|
| 0 | Anexo generado. |
| 1 | Algún punto P-nnn del registro no pertenece a ningún concepto (se aborta antes de escribir), o falta el argumento o el fichero. |

## md_a_docx.py

Convierte un Markdown del proyecto a Word con la plantilla `docenteo-documento.dotx` de la skill `docenteo-design`, usando solo sus estilos.

| Argumento | Por defecto | Significado |
|---|---|---|
| `ENTRADA.md` | obligatorio | Markdown de origen. |
| `SALIDA.docx` | obligatorio | Word de destino. |
| `--titulo TEXTO` | obligatorio | Título de la portada. |
| `--subtitulo TEXTO` | vacío | Subtítulo de la portada. |
| `--antetitulo TEXTO` | vacío | Línea superior de la portada, por ejemplo fecha y cliente. |
| `--plantilla RUTA` | la de la versión más alta de `docenteo-skills` instalada | Plantilla alternativa. |

Convenciones: la primera línea `# ` no se pinta (la portada usa `--titulo`) y lo anterior al primer `## ` es la ficha del documento; `## n. Título` es capítulo, `### ` apartado con numeración automática y `#### ` subapartado sin número; una línea que solo tiene `**texto**` es una etiqueta; los comentarios `<!-- ... -->` se ignoran; las tablas de 8 columnas cuya cabecera empieza por "Nº" se parten por bloque. Imprime `OK SALIDA`. Después conviene pasar el verificador de tokens de la skill (`scripts/comprobar-tokens.sh`).

| Código | Significado |
|---|---|
| 0 | Word generado. |
| 1 | La primera línea del Markdown no es un título `# ` (aserción), o excepción no controlada. |
| 2 | Argumentos incorrectos, o plantilla no encontrada (indicar `--plantilla`). |

## Evidence

- `anexo_pendientes.py#main` - argumento, escritura entre marcas y aborto si hay puntos sin concepto.
- `md_a_docx.py` - argumentos, búsqueda de la plantilla, convenciones del Markdown y códigos de salida.
