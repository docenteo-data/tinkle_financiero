---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
source_globs: ["*.py"]
tags: [rf-scripts, architecture]
---

# rf-scripts - Architecture

> Cuándo cargar: necesitas entender cómo se relacionan los scripts de Fabric de Tinkle (exportar, publicar, consultar SQL), dónde vive la lógica compartida (cuenta, API REST, git, SQL), o cómo funcionan los scripts de validación de ficheros del Grupo, de anexo de pendientes y de conversión a Word.

## Núcleo: fabric_comun.py

Módulo compartido sin punto de entrada propio. Tiene cuatro bloques:

- Cuenta y tokens: `comprobar_cuenta` verifica que Azure CLI apunta a la cuenta de Tinkle (si no, sale con código 2). `token` pide al CLI un token para Fabric o para SQL. `_az` sale con código 2 si Azure CLI falla. Ningún script guarda ni imprime tokens.
- API REST: `peticion` hace las llamadas HTTP con token Bearer. `esperar_operacion` sondea las operaciones asíncronas hasta `Succeeded` o `Failed`. `items`, `descargar_definicion`, `publicar_definicion` y `crear_item` cubren listar, leer, actualizar y crear definiciones. `partes_para_publicar` excluye los ficheros que no son publicables (`.platform`). `lanzar_pipeline` y `esperar_job` lanzan un pipeline y siguen su job hasta un estado final; `leer_parametros` convierte los `clave=valor` de la línea de comandos.
- Git: `ficheros_en_git` lee la carpeta `reporting-financiero/fabric` de un commit con `git archive`, sin tocar la carpeta de trabajo. `solo_items` filtra a lo exportable y `comparar` clasifica las diferencias en nuevos, cambiados y borrados.
- SQL: `conectar_sql` abre la conexión al SQL endpoint del lakehouse con token. `descargar_sql` y `ficheros_sql` leen vistas y columnas de los esquemas 100, 200 y 300. `es_consulta_de_lectura` bloquea las sentencias de escritura. `vista_de_ruta`, `sentencia_de_vista` y `publicar_vista` preparan y ejecutan la creación o actualización de una vista; `sentencia_de_vista` rechaza líneas `GO` y ficheros que no crean la vista de su ruta.

Configuración clave en el módulo: `FORMATOS` define qué tipos de item se exportan y publican y con qué formato de definición. Las User Data Functions quedan fuera a propósito. `CARPETAS_LAKEHOUSE` marca las carpetas de vistas y esquema. `ITEMS_DE_SISTEMA` y `es_exportable` excluyen los items que Power BI crea al abrir las métricas de uso de un informe (Report Usage Metrics Report, Report Usage Metrics Model y Usage Metrics Report), que no forman parte de la solución y que la API no permite exportar.

## Puntos de entrada

- `exportar_fabric.py`: lee Fabric y escribe `fabric/` o compara con un commit.
- `publicar_fabric.py`: escribe en Fabric desde un commit de git: actualiza items existentes, crea los que faltan con `--crear` y publica vistas SQL (`sql/<esquema>.<vista>.sql`). Nunca borra.
- `ejecutar_fabric.py`: lanza un pipeline de Fabric, espera a que termine y devuelve su estado. Solo lanza con `--confirmar`.
- `consultar_sql.py`: consulta de solo lectura al SQL endpoint.
- `validar_ficheros_grupo.py`: reproduce los ficheros de Grupo de Ageing y Revenue de marzo de 2026 desde las fuentes y los compara con los TXT de Magnitude. Lee Excel y consulta Fabric en solo lectura.
- `anexo_pendientes.py`: genera el anexo de pendientes de la auditoría general, a partir del registro de reuniones, la auditoría técnica y las preguntas para Tinkle.
- `md_a_docx.py`: convierte un documento Markdown del proyecto a Word con la plantilla de Docenteo.

## Flujos

### Exportar

1. Comprobar la cuenta y obtener el token de Fabric (`comprobar_cuenta`, `token`).
2. Listar los items del workspace (`items`) y quedarse con los que cumplen `es_exportable`, ordenados por tipo y nombre.
3. Descargar cada definición con `descargar_definicion`. Si la respuesta no es 200, espera la operación asíncrona (`esperar_operacion`) y lee el resultado. Un error en un item se registra y el proceso sigue.
4. Añadir las vistas y el esquema del lakehouse con `descargar_sql` (`sql/` y `lakehouse/esquema.tsv`).
5. Si hay errores en cualquier item o en SQL, no escribe ni compara y sale con código 2.
6. Modo normal: `exportar` borra las carpetas generadas y las vuelve a escribir enteras. `temas/` no se toca.
7. Modo `--comprobar [REF]`: `ficheros_en_git` lee el commit (por defecto `main`), `solo_items` filtra y `comparar` clasifica las diferencias. Sale con 0 si coincide, con 1 si no, y con 2 si la REF no existe en git.

### Publicar

1. Validar que los argumentos son vistas `sql/<100|200|300>.<nombre>.sql` o items de tipo publicable, y comprobar la cuenta.
2. Vistas (`_preparar_vistas`): leer de git, con `--ref`, cada fichero y las vistas actuales del SQL endpoint. Si una vista no está en `--ref`, sale con código 2. Si Fabric difiere de `--base` en alguna vista, sale con código 1 salvo `--forzar`. Prepara la sentencia (`sentencia_de_vista`): `CREATE` si la vista es nueva, `CREATE OR ALTER` si existe.
3. Items: los que no existen en Fabric dan error, salvo con `--crear`. Se leen de git, con `--ref` (por defecto `HEAD`), las definiciones a publicar, y de git, con `--base` (por defecto `main`), la referencia esperada.
4. Descargar de Fabric el estado actual de los items existentes y compararlo con `--base`. Los items que faltan y están en `--base` también cuentan como diferencia. Si hay diferencias, sale con código 1, salvo con `--forzar`.
5. Por cada vista, calcular su estado: nueva, cambiada o sin cambios. Sin `--confirmar` solo simula. Con `--confirmar` ejecuta la sentencia (`publicar_vista`) y salta las vistas sin cambios. Las vistas se publican antes que los items.
6. Por cada item existente, calcular el resumen de cambios (nuevos, cambiados, quitados). Con `--confirmar` llama a `publicar_definicion`, que envía `updateDefinition` y espera la operación si la respuesta es 202.
7. Por cada item nuevo, sin `--confirmar` solo simula. Con `--confirmar` llama a `crear_item`, que envía el item con su definición y espera si la respuesta es 202.
8. Sale con 0 si todo va bien y con 2 ante un error.

### Ejecutar pipeline

1. Leer `--parametro` con `leer_parametros`. Un parámetro mal formado sale con código 2.
2. Comprobar la cuenta y buscar el item por nombre. Debe existir y ser de tipo `DataPipeline`; si no, sale con código 2.
3. Sin `--confirmar` termina aquí, con código 0, sin lanzar nada.
4. Con `--confirmar`, `lanzar_pipeline` envía la petición de lanzamiento con los parámetros y guarda la URL del job de la cabecera `Location`.
5. `esperar_job` consulta ese job cada 20 segundos hasta un estado final (`Completed`, `Failed`, `Cancelled` o `Deduped`). Si el tiempo de espera supera `--max-minutos`, sale con código 2 sin cancelar nada, porque el pipeline sigue en marcha.
6. Sale con 0 si el estado es `Completed`, con 1 en los demás estados finales.
7. Defecto conocido (no corregido): un `HTTPError` al listar los items (paso 2, fuera del `try`) no se captura. El script termina con traza y código 1, el mismo código que un pipeline `Failed`, en vez del 2 que documenta el resto de errores.

### Consultar SQL

1. Leer la sentencia del argumento o de `--fichero`.
2. `es_consulta_de_lectura` quita comentarios, literales y nombres entre corchetes. Después exige que la sentencia empiece por SELECT o WITH y que no contenga palabras de escritura. Si no lo cumple, sale con código 2 sin conectar.
3. Con `--csv`, comprobar que la ruta está dentro de `reporting-financiero/data/`.
4. Comprobar la cuenta y conectar con `conectar_sql`.
5. Ejecutar. Con `--csv` escribe todas las filas en UTF-8 separadas por punto y coma. Sin él imprime como mucho `--max-filas` filas (50 por defecto) en ASCII.
6. Un error del driver sale con código 1.

### Validar ficheros de Grupo

Procesa un fichero por ejecución (`ageing` o `revenue`), con la carpeta `3.Fuentes` de OneDrive como origen (o `--fuentes`).

1. Comprobar que existe la carpeta de TXT de marzo. Si no, sale con código 2. Después comprobar la cuenta con `comprobar_cuenta`.
2. Leer los TXT de marzo (`leer_txt`), separados por punto y coma.
3. Modo `ageing`: `validar_ageing` lee la hoja DATOS del aging de clientes a 31-03-2026 y asigna cada factura a un tramo (GR0 a GR9C) según los días hasta el corte (`tramo`). Compara los importes por sociedad y tramo con los TXT. Aparte, cruza factura y NIF con la tabla MMS del esquema 200 (`consultar`) y con el código de cliente Magnitude de `mapeo_magnitude`. El código es informativo y se compara línea a línea, junto con los flags GRICFLAG.
4. Modo `revenue`: `validar_revenue` suma `Fact_Actuals` del primer trimestre (esquema 300) por sociedad y lo compara con los TXT, con una tolerancia de 0,05. El código de cliente se obtiene con `Dim_Clientes` y el mismo mapeo, también de forma informativa.
5. `mapeo_magnitude` lee el Excel Revenue FT3 de `Presupuestos`. La hoja FT3 2026 tiene prioridad y el resto solo completa huecos. Los códigos numéricos se rellenan a 8 dígitos.
6. Sale con 0 si las cifras de control cuadran, con 1 si no cuadran y con 2 si fallan la cuenta o los ficheros. La salida es ASCII.

### Generar anexo de pendientes

1. Recibe la ruta de la auditoría como argumento. Su sección 1 contiene la tabla de conceptos, con filas de 5 columnas (Nº, concepto, qué falta, prioridad y pendientes) agrupadas por bloque (`leer_conceptos`).
2. Carga el registro de reuniones (`leer_registro`), la auditoría técnica con el estado más reciente de cada riesgo (`leer_tecnica`, donde manda el apartado 13.7 sobre el 13.6) y las preguntas para Tinkle (`leer_preguntas`).
3. Por cada concepto extrae los puntos P-nnn, los riesgos S, O, M, D y N, y el rango de preguntas, y copia sus descripciones desde las fuentes (`generar`).
4. Limpia el texto copiado de caracteres de redacción (rayas, flechas y barras verticales).
5. Escribe el anexo entre las marcas `<!-- anexo:inicio -->` y `<!-- anexo:fin -->`, o lo añade al final si no existen (`main`). Volver a ejecutarlo deja el mismo resultado.
6. Si un punto del registro no pertenece a ningún concepto, termina con error.

### Convertir Markdown a Word

1. Localiza la plantilla `docenteo-documento.dotx` de la skill docenteo-design en la versión más alta instalada del plugin docenteo-skills (`plantilla_por_defecto`), salvo que se pase `--plantilla`. Si no la encuentra, sale con código 2.
2. La primera línea `# ` es el título y no se pinta, porque va en la portada. Lo que hay hasta el primer capítulo se pinta como ficha del documento.
3. Convierte capítulos, apartados, subapartados, etiquetas en negrita, listas (cada lista numerada reinicia su numeración) y párrafos a los estilos de la plantilla. Las cinco formas de tabla conocidas (cabecera Nº con Tareas, Fase, Id/Tipo/Descripción/Responsable/Estado, Id/Prioridad/Problema/Situación y Nº de dos columnas) usan anchos fijos; el resto calcula sus anchos según el contenido (`anchos_automaticos`). Una sigla corta seguida de una cifra se une con espacio duro (`pegar_cifras`). La tabla de conceptos de 8 columnas se parte en una tabla por bloque, con anchos fijos y una nota de pendientes (`tablas_de_conceptos`).
4. Reescribe el cuerpo del documento, la numeración, el tipo de contenido y el título de las propiedades. El resto del paquete de la plantilla se copia tal cual.
5. El script termina sin verificar el resultado. Indica revisarlo después con el verificador de la skill.

## Dependencias

- Azure CLI (`az`) en el PATH, con sesión en la cuenta de Tinkle. Lo usa `fabric_comun.py` y, por tanto, todos los scripts que consultan Fabric.
- Biblioteca `mssql_python`, para `consultar_sql.py` y para la exportación de vistas y esquema en `exportar_fabric.py`. `validar_ficheros_grupo.py` consulta SQL a través de `fabric_comun.py`.
- Biblioteca `openpyxl`, para leer los Excel de `validar_ficheros_grupo.py`.
- Carpeta `3.Fuentes` de OneDrive, con los Excel de aging y Revenue y los TXT de Magnitude de marzo.
- Plantilla `docenteo-documento.dotx` de la skill docenteo-design, para `md_a_docx.py`.
- `anexo_pendientes.py` y `md_a_docx.py` usan solo la biblioteca estándar de Python.

## Evidence

- `fabric_comun.py#comprobar_cuenta`, `#token`, `#peticion`, `#esperar_operacion`, `#descargar_definicion`, `#publicar_definicion`, `#ficheros_en_git`, `#solo_items`, `#comparar`, `#descargar_sql`, `#ficheros_sql`, `#conectar_sql`, `#es_consulta_de_lectura`, `#es_exportable`, `#ITEMS_DE_SISTEMA`.
- `exportar_fabric.py#descargar_todo`, `#exportar`, `#comprobar`, `#main`.
- `publicar_fabric.py#main`, `#_preparar_vistas`, `#_publicar_vistas`.
- `ejecutar_fabric.py#main`.
- `consultar_sql.py#main`.
- `validar_ficheros_grupo.py#main`, `#validar_ageing`, `#validar_revenue`, `#mapeo_magnitude`, `#leer_txt`, `#tramo`, `#consultar`, `#comparar_lineas`.
- `anexo_pendientes.py#generar`, `#leer_conceptos`, `#leer_registro`, `#leer_tecnica`, `#leer_preguntas`, `#main`.
- `md_a_docx.py#plantilla_por_defecto`, `#tabla`, `#anchos_automaticos`, `#pegar_cifras`, `#tablas_de_conceptos`, `#lista`, `#convertir`.
- `fabric_comun.py#crear_item`, `#lanzar_pipeline`, `#esperar_job`, `#vista_de_ruta`, `#sentencia_de_vista`, `#publicar_vista`.
