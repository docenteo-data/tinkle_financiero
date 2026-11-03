---
type: repo-card
load_tier: 1
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
tags: [rf-scripts, repo-card]
---

# rf-scripts - Repo Card

> Resumen tier 1. Cárgalo primero para cualquier tarea sobre los scripts de `reporting-financiero/scripts`: Fabric de Tinkle, validación de ficheros de Grupo, anexo de pendientes y generación de Word.

- **Propósito**: scripts Python para exportar, comprobar, publicar y consultar el workspace de Fabric de Tinkle, y para validar ficheros de Grupo, generar el anexo de pendientes de la auditoría y convertir Markdown a Word. El repo `main` refleja lo publicado en Fabric, y su copia en texto está en `reporting-financiero/fabric/`. Los scripts de Fabric no definen entidades propias: manipulan definiciones de items (TMDL, PBIR, dataflows, pipelines, notebooks, vistas SQL). Solo publica cuando se le pide.
- **Stack**: Python en el entorno `.venv` de `reporting-financiero`. Biblioteca estándar, mssql-python para el SQL endpoint y openpyxl para leer Excel.
- **Puntos de entrada y cuándo usar cada uno**:
  - `exportar_fabric.py`: sin argumentos, regenera `fabric/` desde Fabric. Con `--comprobar [REF]` (por defecto `main`) solo compara y dice si Fabric coincide con ese commit. Úsalo para comprobar sincronía o traer cambios al repo. Omite los items de sistema de las métricas de uso de informes (Report Usage Metrics y Usage Metrics), que la API no permite exportar.
  - `publicar_fabric.py`: publica en Fabric la definición de uno o más items tal como está en un commit. Úsalo para publicar un cambio ya commiteado o hacer rollback. Sin `--confirmar` solo simula.
  - `consultar_sql.py`: consulta de solo lectura al SQL endpoint del lakehouse, para validar o analizar datos. Acepta solo sentencias SELECT o WITH. Con `--csv` escribe en `reporting-financiero/data/`, que no se versiona.
  - `validar_ficheros_grupo.py`: reproduce los ficheros de Grupo de Ageing o Revenue de marzo de 2026 desde las fuentes y los compara con los TXT de Magnitude. Uso: `ageing` o `revenue`; `--fuentes` indica otra carpeta 3.Fuentes. Úsalo antes de entregar esos ficheros. Detalle en [[domains/ficheros-de-grupo]].
  - `anexo_pendientes.py`: regenera el anexo de pendientes por concepto (sección 11) de la auditoría general que se le pasa como argumento. Lee la tabla de conceptos de la sección 1 y copia las descripciones del registro de reuniones, de la auditoría técnica y de las preguntas para Tinkle. Es idempotente: entre las marcas de inicio y fin del anexo no se edita a mano.
  - `md_a_docx.py`: convierte un Markdown del proyecto a Word con la plantilla `docenteo-documento.dotx`. Uso: entrada, salida y `--titulo` (obligatorio), más `--subtitulo`, `--antetitulo` y `--plantilla`. La primera línea "# " no se pinta (el título de la portada sale de `--titulo`) y lo anterior al primer "## " va como ficha del documento; "## " son capítulos, "### " apartados y "#### " subapartados sin número. Úsalo para entregar documentos en Word.
  - `fabric_comun.py`: módulo compartido. No es punto de entrada.
- **Qué escribe en Fabric**: solo `publicar_fabric.py`, y solo con `--confirmar`. Actualiza items que ya existen; no crea ni borra items. No publica User Data Functions, porque su código lleva un secreto incrustado. `exportar_fabric.py`, `consultar_sql.py` y `validar_ficheros_grupo.py` no escriben en Fabric. Ningún script imprime ni guarda tokens.
- **Escrituras locales**: `exportar_fabric.py` sin argumentos borra y reescribe `fabric/` entera, salvo `temas/`. `anexo_pendientes.py` reescribe el fichero de auditoría que recibe, conservando el texto anterior a la marca de inicio del anexo. `md_a_docx.py` crea el `.docx` de salida.
- **Integraciones**: API REST de Fabric (listar, leer y actualizar definiciones, con operaciones asíncronas); Azure CLI (pide un token en cada ejecución); SQL endpoint del lakehouse con mssql-python (también en `validar_ficheros_grupo.py`, en solo lectura); carpeta 3.Fuentes de OneDrive y ficheros Excel con openpyxl, solo lectura; git local con `git archive`, sin checkout.
- **Códigos de salida**:
  - exportar: 0 exportado o coincide; 1 solo con `--comprobar`, hay diferencias; 2 cuenta incorrecta o item o vistas no leídos.
  - publicar: 0 publicado o simulación correcta; 1 Fabric no coincide con `--base` (salvo `--forzar`); 2 tipo no publicable, item inexistente o ausente en `--ref`, error de lectura o publicación, o cuenta incorrecta.
  - consultar: 0 correcta; 1 error de la consulta en el servidor; 2 sentencia no permitida, CSV fuera de `data/`, sin sentencia o cuenta incorrecta.
  - validar_ficheros_grupo: 0 las cifras de control cuadran; 1 no cuadran; 2 cuenta incorrecta o carpeta de fuentes sin los TXT de marzo.
  - anexo_pendientes: 0 anexo generado; 1 hay puntos del registro sin concepto, en cuyo caso no escribe nada.
  - md_a_docx: 0 documento generado; 2 no se encuentra la plantilla (salvo con `--plantilla`); 1 por error de Python, por ejemplo si el Markdown no empieza por "# ".
  - Un fallo de Azure CLI o de git sale con código 2.
- **Requisitos**:
  - Cuenta por defecto de Azure CLI la de Tinkle. Compruébala con la cuenta activa; si no coincide, el script sale con código 2.
  - Entorno `.venv` de `reporting-financiero` con Python 3.14 y las dependencias de `reporting-financiero/requirements.txt`: mssql-python 1.16.0, openpyxl 3.1.5 (solo lo usa `validar_ficheros_grupo.py`) y pytest 9.1.1.
  - `md_a_docx.py` necesita la plantilla `docenteo-documento.dotx` de la skill docenteo-design del plugin docenteo-skills: se usa la versión más alta instalada, salvo que se indique con `--plantilla`.
  - Ejecutar desde la raíz del repo con el Python del `.venv`.
  - La salida va en ASCII, porque la consola de Windows es cp1252.
- **Procedimiento completo**: `reporting-financiero/docs/flujo-fabric.md` (lectura, consulta, publicación, validación de cuenta, flujos de cambio y rollback). Detalle del repo: [[repos/rf-scripts/README]].

## Common pitfalls

- Publicar con `--forzar` descarta los cambios que haya en Fabric y no están en `--base`.
- La publicación real no se prueba: el workspace del cliente no tiene entorno de pruebas. Los tests cubren funciones puras y la salida con código 2 ante fallos de Azure CLI o git; la simulación de `publicar_fabric.py` no tiene test.
- El filtro de `consultar_sql.py` es por palabras clave, no un analizador SQL. TBD: confirmar que los permisos de la conexión son de solo lectura.
- No hay workspace de pruebas: es el único entorno del cliente. Una publicación se valida así: una persona refresca o ejecuta en Fabric y comprueba las cifras de control; después se exporta, se revisa `git diff` y `exportar_fabric.py --comprobar main` debe dar 0.
- La sesión se inicia una vez con `az login`, y otra vez si caduca. Después se fija la cuenta con `az account set --subscription <TENANT_ID>` y se comprueba con `az account show`.
- `validar_ficheros_grupo.py`: el código de cliente Magnitude es informativo, porque el Excel Revenue FT3 no es el maestro de Magnitude. La validación pasa por las cifras de control, no por ese código.
- `anexo_pendientes.py` depende del formato de la tabla de conceptos de la auditoría y de los identificadores P-nnn, S, O, M, D y N. Si cambian, revisa el anexo con `git diff`.
- TBD: versión mínima de Azure CLI.
- El E2E (`FABRIC_E2E=1`) solo lee de Fabric, pero necesita sesión de Azure CLI en la cuenta de Tinkle.
