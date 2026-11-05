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

- **Propósito**: scripts Python para exportar, comprobar, publicar y consultar el workspace de Fabric de Tinkle, y para validar ficheros de Grupo, generar el anexo de pendientes de la auditoría y convertir Markdown a Word. El repo `main` refleja lo publicado en Fabric, y su copia en texto está en `reporting-financiero/fabric/`. Los scripts de Fabric no definen entidades propias: manipulan definiciones de items (TMDL, PBIR, dataflows, pipelines, notebooks, vistas SQL). Solo publica o lanza pipelines cuando se le pide.
- **Stack**: Python en el entorno `.venv` de `reporting-financiero`. Biblioteca estándar, mssql-python para el SQL endpoint y openpyxl para leer Excel.
- **Puntos de entrada y cuándo usar cada uno**:
  - `exportar_fabric.py`: sin argumentos, regenera `fabric/` desde Fabric. Con `--comprobar [REF]` (por defecto `main`) solo compara y dice si Fabric coincide con ese commit. Con `--solo ITEM [ITEM ...]` exporta o compara solo esos items (`lakehouse` para vistas y esquema) sin tocar el resto de `fabric/`. Úsalo para comprobar sincronía o traer cambios al repo. Omite los items de sistema de las métricas de uso de informes (Report Usage Metrics y Usage Metrics), que la API no permite exportar.
  - `publicar_fabric.py`: publica en Fabric la definición de uno o más items tal como está en un commit, y vistas SQL `sql/<esquema>.<vista>.sql` (CREATE si son nuevas, CREATE OR ALTER si existen). Con `--crear` crea los items que no existen. Úsalo para publicar un cambio ya commiteado o hacer rollback. Sin `--confirmar` solo simula.
  - `ejecutar_fabric.py`: lanza un pipeline de Fabric con `--parametro clave=valor` (repetible), espera a que termine y sale con 0 si es `Completed`, 1 si `Failed`, `Cancelled` o `Deduped`, y 2 si hay error o tiempo agotado (`--max-minutos`, 180 por defecto). Sin `--confirmar` solo simula.
  - `consultar_sql.py`: consulta de solo lectura al SQL endpoint del lakehouse, para validar o analizar datos. Acepta solo sentencias SELECT o WITH. Con `--csv` escribe en `reporting-financiero/data/`, que no se versiona.
  - `validar_ficheros_grupo.py`: reproduce los ficheros de Grupo de Ageing o Revenue de marzo de 2026 desde las fuentes y los compara con los TXT de Magnitude. Uso: `ageing` o `revenue`; `--fuentes` indica otra carpeta 3.Fuentes. Con `ageing --vista` valida la vista `300.vw_Export_Ageing` de Fabric contra los TXT, sin leer Excel. Úsalo antes de entregar esos ficheros. Detalle en [[domains/ficheros-de-grupo]].
  - `anexo_pendientes.py`: regenera el anexo de pendientes por concepto (sección 10) de la auditoría general que se le pasa como argumento. Lee la tabla de conceptos de la sección 1 y copia las descripciones del registro de reuniones, de la auditoría técnica y de las preguntas para Tinkle. Es idempotente: entre las marcas de inicio y fin del anexo no se edita a mano.
  - `md_a_docx.py`: convierte un Markdown del proyecto a Word con la plantilla `docenteo-documento.dotx`. Uso: entrada, salida y `--titulo` (obligatorio), más `--subtitulo`, `--antetitulo` y `--plantilla`. La primera línea "# " no se pinta (el título de la portada sale de `--titulo`) y lo anterior al primer "## " va como ficha del documento; "## " son capítulos, "### " apartados y "#### " subapartados sin número. Úsalo para entregar documentos en Word.
  - `fabric_comun.py`: módulo compartido. No es punto de entrada.
- **Qué escribe en Fabric**: `publicar_fabric.py` y `ejecutar_fabric.py`, y solo con `--confirmar`. `publicar_fabric.py` actualiza items existentes, crea items nuevos solo con `--crear` y publica vistas SQL; nunca borra items ni vistas. `ejecutar_fabric.py` lanza un pipeline, que puede escribir datos en el lakehouse. No publica User Data Functions, porque su código lleva un secreto incrustado. `exportar_fabric.py`, `consultar_sql.py` y `validar_ficheros_grupo.py` no escriben en Fabric. Ningún script imprime ni guarda tokens.
- **Escrituras locales**: `exportar_fabric.py` sin argumentos borra y reescribe `fabric/` entera, salvo `temas/`; con `--solo` solo las carpetas pedidas. `anexo_pendientes.py` reescribe el fichero de auditoría que recibe, conservando el texto anterior a la marca de inicio del anexo. `md_a_docx.py` crea el `.docx` de salida.
- **Integraciones**: API REST de Fabric (listar, leer, actualizar y crear definiciones, lanzar pipelines y seguir sus jobs, con operaciones asíncronas); Azure CLI (pide un token en cada ejecución); SQL endpoint del lakehouse con mssql-python (lectura en `consultar_sql.py` y `validar_ficheros_grupo.py`; escritura de vistas solo en `publicar_fabric.py`); carpeta 3.Fuentes de OneDrive y ficheros Excel con openpyxl, solo lectura; git local con `git archive`, sin checkout.
- **Códigos de salida**:
  - exportar: 0 exportado o coincide; 1 solo con `--comprobar`, hay diferencias; 2 cuenta incorrecta, item o vistas no leídos, o nombre de `--solo` inexistente.
  - publicar: 0 publicado, creado o simulación correcta; 1 Fabric no coincide con `--base` (salvo `--forzar`); 2 tipo no publicable, item inexistente sin `--crear`, item o vista ausente en `--ref`, vista no válida, error de lectura o publicación, o cuenta incorrecta.
  - ejecutar: 0 simulación correcta o `Completed`; 1 `Failed`, `Cancelled` o `Deduped`; 2 parámetro mal formado, pipeline inexistente o que no es `DataPipeline`, tiempo agotado, o cuenta incorrecta.
  - consultar: 0 correcta; 1 error de la consulta en el servidor; 2 sentencia no permitida, CSV fuera de `data/`, sin sentencia o cuenta incorrecta.
  - validar_ficheros_grupo: 0 las cifras de control cuadran; 1 no cuadran; 2 cuenta incorrecta, carpeta de fuentes sin los TXT de marzo, o `--vista` con `revenue`.
  - anexo_pendientes: 0 anexo generado; 1 hay puntos del registro sin concepto, en cuyo caso no escribe nada.
  - md_a_docx: 0 documento generado; 2 no se encuentra la plantilla (salvo con `--plantilla`); 1 por error de Python, por ejemplo si el Markdown no empieza por "# ".
  - Un fallo de Azure CLI o de git sale con código 2.
- **Requisitos**:
  - Cuenta por defecto de Azure CLI la de Tinkle. Compruébala con la cuenta activa; si no coincide, el script sale con código 2.
  - Entorno `.venv` de `reporting-financiero` con Python 3.14 y las dependencias de `reporting-financiero/requirements.txt`: mssql-python 1.16.0, openpyxl 3.1.5 (lo usa `validar_ficheros_grupo.py`) y pytest 9.1.1.
  - `md_a_docx.py` necesita la plantilla `docenteo-documento.dotx` de la skill docenteo-design del plugin docenteo-skills: se usa la versión más alta instalada, salvo que se indique con `--plantilla`.
  - Ejecutar desde la raíz del repo con el Python del `.venv`.
  - La salida va en ASCII, porque la consola de Windows es cp1252.
- **Procedimiento completo**: `reporting-financiero/docs/flujo-fabric.md` (lectura, consulta, publicación, validación de cuenta, flujos de cambio y rollback). Detalle del repo: [[repos/rf-scripts/README]].

## Common pitfalls

- Publicar con `--forzar` descarta los cambios que haya en Fabric y no están en `--base`.
- La publicación real no se prueba: el workspace del cliente no tiene entorno de pruebas. Los tests cubren funciones puras, la simulación y los códigos de `publicar_fabric.py` y `ejecutar_fabric.py` con sustitutos, y la salida con código 2 ante fallos de Azure CLI o git.
- `ejecutar_fabric.py` no cancela el pipeline si se agota `--max-minutos`: sale con 2 y el pipeline sigue en Fabric. El historial de jobs de un pipeline no lista los que lanza otro con `ExecutePipeline` (ver `reporting-financiero/docs/flujo-fabric.md`, sección 2).
- El filtro de `consultar_sql.py` es por palabras clave, no un analizador SQL. TBD: confirmar que los permisos de la conexión son de solo lectura.
- No hay workspace de pruebas: es el único entorno del cliente. Una publicación se valida así: una persona refresca o ejecuta en Fabric y comprueba las cifras de control; después se exporta, se revisa `git diff` y `exportar_fabric.py --comprobar main` debe dar 0.
- `ejecutar_fabric.py`: un `HTTPError` al listar items sale con código 1, no con 2 (defecto conocido, sin corregir; ver [[repos/rf-scripts/apis]]).
- `exportar_fabric.py --solo`: un item de sistema (Usage Metrics) cuenta como inexistente y sale con 2.
- La sesión se inicia una vez con `az login`, y otra vez si caduca. Después se fija la cuenta con `az account set --subscription <TENANT_ID>` y se comprueba con `az account show`.
- `validar_ficheros_grupo.py`: el código de cliente Magnitude es informativo, porque el Excel Revenue FT3 no es el maestro de Magnitude. La validación pasa por las cifras de control, no por ese código.
- `anexo_pendientes.py` depende del formato de la tabla de conceptos de la auditoría y de los identificadores P-nnn, S, O, M, D y N. Si cambian, revisa el anexo con `git diff`.
- TBD: versión mínima de Azure CLI.
- El E2E (`FABRIC_E2E=1`) solo lee de Fabric, pero necesita sesión de Azure CLI en la cuenta de Tinkle.
