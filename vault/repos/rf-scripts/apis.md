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
tags: [rf-scripts, apis]
---

# rf-scripts - APIs

> Cuándo cargar: necesitas ejecutar los scripts de Fabric de Tinkle o de reporting financiero, conocer sus argumentos y códigos de salida, o reutilizar una función de `fabric_comun.py`.

## Interfaz de línea de comandos

Todos se ejecutan desde la raíz del repositorio con `python reporting-financiero/scripts/<script>.py`. Los que leen o escriben en Fabric (`exportar_fabric.py`, `publicar_fabric.py`, `ejecutar_fabric.py`, `consultar_sql.py` y `validar_ficheros_grupo.py`) requieren Azure CLI con la cuenta de Tinkle por defecto. Ningún script guarda tokens.

Si Azure CLI o git fallan, los scripts de Fabric imprimen el error y salen con código 2, para no confundirlo con el 1 (hay diferencias).

### exportar_fabric.py

Solo lectura sobre Fabric. Sin argumentos regenera `reporting-financiero/fabric/` entera (salvo `temas/`). Omite los items de sistema que Power BI crea al abrir las métricas de uso de un informe, porque la API no permite exportarlos (`fabric_comun.py#es_exportable`).

| Argumento | Por defecto | Significado |
|---|---|---|
| (ninguno) | - | Exporta items, vistas SQL y esquema del lakehouse. |
| `--comprobar [REF]` | `main` si no se indica REF | No escribe. Compara Fabric con `fabric/` en el commit REF. |

| Código | Significado |
|---|---|
| 0 | Exportado, o Fabric coincide con REF. |
| 1 | Solo con `--comprobar`: hay diferencias (solo en Fabric, distintas o solo en el repo). |
| 2 | Cuenta incorrecta, fallo de Azure CLI, REF de `--comprobar` inexistente en git, o algún item o las vistas no se han podido leer. No escribe ni compara nada. |

### publicar_fabric.py

Escribe en el workspace del cliente. Sin `--confirmar` solo simula. Los items existentes se actualizan; los que no existen solo se crean con `--crear`; nunca se borran. Las vistas SQL se crean (`CREATE`) si no existen o se actualizan (`CREATE OR ALTER`) si existen; tampoco se borran. Las UDF no se publican.

| Argumento | Por defecto | Significado |
|---|---|---|
| `items` | obligatorio, uno o más | Carpetas de `fabric/`, por ejemplo `"Financial Model.SemanticModel"`, o vistas `sql/<esquema>.<vista>.sql` (esquema 100, 200 o 300), por ejemplo `"sql/300.vw_Export_Grupo.sql"`. Solo tipos con formato publicable. |
| `--ref` | `HEAD` | Commit, rama o etiqueta de donde se leen las definiciones. Se lee de git, no de la carpeta de trabajo. |
| `--base` | `main` | Referencia con la que Fabric debe coincidir antes de publicar. Vale para items y para vistas. |
| `--confirmar` | desactivado | Sin él, simulación. Con él, publica o crea. |
| `--forzar` | desactivado | Publica aunque Fabric no coincida con `--base`, perdiendo esos cambios. Solo con decisión explícita. |
| `--crear` | desactivado | Crea en Fabric los items que están en `--ref` pero no existen, con su definición. Sin él, un item inexistente es error. |

Una vista cuyo fichero tiene una línea `GO` o no crea la vista de su ruta al principio se rechaza (código 2). Las vistas se comprueban y se publican antes que los items. Una vista sin cambios respecto a Fabric se salta al publicar.

| Código | Significado |
|---|---|
| 0 | Publicado o creado, o simulación correcta. |
| 1 | Fabric no coincide con `--base` (sin `--forzar`). |
| 2 | Tipo no publicable, item inexistente sin `--crear`, item o vista ausente en `--ref`, vista no válida, error de lectura (Fabric o SQL endpoint) o de publicación o creación, cuenta incorrecta, fallo de Azure CLI, o `--ref`/`--base` inexistente en git. |

### ejecutar_fabric.py

Lanza un pipeline de Fabric (`DataPipeline`) y espera a que termine. Escribe en el workspace del cliente, porque el pipeline puede escribir tablas del lakehouse. Sin `--confirmar` solo comprueba la cuenta y que el pipeline existe, y dice qué lanzaría.

| Argumento | Por defecto | Significado |
|---|---|---|
| `pipeline` | obligatorio | Nombre del pipeline tal como aparece en Fabric. Debe ser de tipo `DataPipeline`. |
| `--parametro` | ninguno | Parámetro del pipeline con formato `CLAVE=VALOR`. Se puede repetir. Se parte por el primer `=`. |
| `--confirmar` | desactivado | Sin él, simulación. Con él, lanza el pipeline y espera. |
| `--max-minutos` | `180` | Tiempo máximo de espera. Si se supera, el pipeline puede seguir en marcha en Fabric. |

| Código | Significado |
|---|---|
| 0 | Simulación correcta, o pipeline `Completed`. |
| 1 | Pipeline `Failed`, `Cancelled` o `Deduped`. Imprime el motivo si Fabric lo informa. |
| 2 | Parámetro mal formado, pipeline inexistente o que no es `DataPipeline`, tiempo agotado, cuenta incorrecta, fallo de Azure CLI o error al lanzar. |

Defecto conocido (no corregido): un `HTTPError` al listar los items, antes del `try`, no se captura. El script termina con traza y código 1, igual que un pipeline `Failed`, y no con 2 como el resto de errores.

El historial de jobs no lista los pipelines lanzados por otro con `ExecutePipeline` (ver `reporting-financiero/docs/flujo-fabric.md`, sección 2).

### consultar_sql.py

Consulta de solo lectura al SQL endpoint del lakehouse. Acepta solo sentencias que empiezan por SELECT o WITH y sin palabras de escritura.

| Argumento | Por defecto | Significado |
|---|---|---|
| `sql` | - | Sentencia SELECT o WITH. Alternativa a `--fichero`. |
| `--fichero` | - | Lee la sentencia de un fichero `.sql`. |
| `--csv` | - | Escribe todas las filas en CSV UTF-8 con separador `;`. La ruta debe estar dentro de `reporting-financiero/data/`. |
| `--max-filas` | 50 | Filas que se imprimen cuando no hay `--csv`. |

| Código | Significado |
|---|---|
| 0 | Consulta correcta. |
| 1 | Error de la consulta en el servidor (`mssql_python.Error`). |
| 2 | Sin sentencia, sentencia no permitida, CSV fuera de `reporting-financiero/data/`, cuenta incorrecta, o fallo de Azure CLI. |

### validar_ficheros_grupo.py

Reproduce desde las fuentes los ficheros de Grupo de Ageing y Revenue y los compara con los TXT de Magnitude de marzo de 2026. Lee `3.Fuentes` de OneDrive y consulta Fabric en solo lectura. Contexto en [[domains/ficheros-de-grupo]].

| Argumento | Por defecto | Significado |
|---|---|---|
| `ageing` o `revenue` | obligatorio | Fichero de Grupo a validar (argumento posicional). |
| `--fuentes RUTA` | carpeta `3.Fuentes` de la biblioteca Reporting financiero en OneDrive | Carpeta de fuentes. Debe contener la carpeta de TXT "2026 03 - 0001 Magnitude Marzo". |

Líneas de salida (las leen los tests):

- `TRAMOS combinaciones=N diferencia_maxima=X` (ageing): compara el importe por sociedad y tramo (`GR0` a `GR9C`) del TXT con el aging de clientes al 31-03-2026. Es la cifra de control.
- `  DIFERENCIA sociedad tramo txt=... calculado=...` (ageing): una línea por combinación con diferencia de al menos 0,001.
- `SOCIEDAD codigo txt=... calculado=... dif=...` (revenue): total por sociedad desde Fact_Actuals frente al TXT. Es la cifra de control.
- `CLIENTES lineas_txt=N exactas=N distintas=N solo_txt=N solo_calculadas=N` (ambos): cruce línea a línea por código de cliente Magnitude. Es informativa.
- `  importe_sin_codigo=X` (ambos): importe sin código de cliente.
- `GRICFLAG txt=N calculados=N coinciden=N` (ageing): compara los marcadores de intercompañía del TXT con los de la fuente. Es informativa.

| Código | Significado |
|---|---|
| 0 | Las cifras de control cuadran: en ageing, diferencia máxima por tramo menor de 0,001; en revenue, diferencia por sociedad menor de 0,05. |
| 1 | No cuadran. Las líneas CLIENTES, GRICFLAG e importe_sin_codigo no cambian el código de salida. |
| 2 | Cuenta de Azure CLI incorrecta (comprobada por `fabric_comun.py`), o no se encuentra la carpeta de TXT de marzo en la ruta de `--fuentes`. | Un error no controlado también sale con 1.

### anexo_pendientes.py y md_a_docx.py

Herramientas de documentos que no consultan Fabric: `anexo_pendientes.py AUDITORIA` regenera el anexo de pendientes de la auditoría (0 generado, 1 puntos sin concepto o falta el fichero) y `md_a_docx.py ENTRADA.md SALIDA.docx --titulo ...` convierte Markdown a Word con la plantilla de Docenteo (0 generado, 1 Markdown sin título `# `, 2 argumentos o plantilla). Argumentos y convenciones completos en [[repos/rf-scripts/modules/documentos]].

## Funciones públicas de fabric_comun.py

Módulo importado como `fc` por los scripts de Fabric. Las funciones con prefijo `_` son privadas.

### Cuenta y tokens

- `comprobar_cuenta()`: devuelve el usuario de Azure CLI si es la cuenta de Tinkle; si no, sale con código 2.
- `token(recurso)`: devuelve un access token de Azure CLI para el recurso indicado, por defecto la API de Fabric.

### API REST de Fabric

- `peticion(metodo, url, tok, cuerpo)`: llamada HTTP con bearer; devuelve estado, cabeceras y cuerpo JSON.
- `esperar_operacion(cabeceras, tok, con_resultado)`: sondea una operación larga hasta terminar y devuelve su resultado si se pide.
- `items(tok)`: devuelve la lista de items del workspace.
- `nombre_carpeta(item)`: devuelve el nombre de carpeta `Nombre.Tipo` de un item.
- `separar_item(carpeta)`: devuelve la pareja (nombre, tipo) de una carpeta `Nombre.Tipo`.
- `es_exportable(item)`: indica si un item se exporta: su tipo tiene formato en `FORMATOS` y su nombre no está en `ITEMS_DE_SISTEMA`.
- `descargar_definicion(item, tok)`: devuelve un diccionario ruta a bytes con la definición actual del item.
- `partes_para_publicar(ficheros)`: devuelve las partes de la definición en base64, sin los ficheros no publicables.
- `publicar_definicion(item, ficheros, tok)`: envía la definición al item y espera a que la operación termine.
- `crear_item(nombre, tipo, ficheros, tok)`: crea un item nuevo con esa definición, sin `.platform`, y espera si la respuesta es asíncrona (202).
- `lanzar_pipeline(item, tok, parametros)`: lanza una instancia de pipeline con esos parámetros y devuelve la URL de la instancia del job (cabecera `Location`). RuntimeError si la respuesta no es 202 o no trae `Location`.
- `esperar_job(url, tok, intervalo, max_segundos, dormir)`: consulta el job cada `intervalo` segundos (20 por defecto) hasta un estado final y devuelve su cuerpo. TimeoutError si el tiempo esperado superaría `max_segundos`.
- `leer_parametros(lista)`: convierte `["clave=valor", ...]` en un diccionario. ValueError si un elemento no tiene `=` o la clave queda vacía.

### Git y comparación

- `ficheros_en_git(ref, carpeta)`: devuelve, como ruta a bytes, los ficheros de `carpeta` tal como están en el commit ref.
- `solo_items(ficheros, carpetas)`: filtra los ficheros a los items exportables o a las carpetas indicadas.
- `comparar(fabric, repo)`: devuelve tres listas de rutas: nuevas, cambiadas y borradas.

### SQL

- `conectar_sql()`: abre una conexión al SQL endpoint del lakehouse con un token de Azure CLI.
- `ficheros_sql(vistas, columnas)`: convierte las filas de vistas y columnas en ficheros de `sql/` y `lakehouse/`.
- `descargar_sql()`: lee vistas y esquema del lakehouse y devuelve esos ficheros.
- `es_consulta_de_lectura(sql)`: devuelve True si la sentencia empieza por SELECT o WITH y no contiene palabras de escritura.
- `vista_de_ruta(ruta)`: devuelve (esquema, vista) de una ruta `sql/<100|200|300>.<nombre>.sql`. ValueError si no tiene ese formato.
- `sentencia_de_vista(ruta, contenido, existe)`: prepara la sentencia que publica la vista. ValueError si el contenido tiene una línea `GO` o no crea la vista de la ruta al principio. Si la vista existe, cambia `CREATE VIEW` por `CREATE OR ALTER VIEW`.
- `publicar_vista(sentencia)`: ejecuta la sentencia en el SQL endpoint del lakehouse y confirma el cambio.

### Utilidad

- `ascii(texto)`: devuelve el texto en ASCII, sustituyendo los caracteres no válidos, para la consola de Windows.

## Constantes públicas

- `FORMATOS`: tipo de item a formato de definición pedido a la API. `SemanticModel` usa TMDL, `Report` PBIR y `Notebook` ipynb; `Dataflow` y `DataPipeline` no piden formato. Solo estos tipos se exportan y publican.
- `ITEMS_DE_SISTEMA`: nombres de items de métricas de uso de informes que la API no permite exportar. Los excluye `es_exportable`.
- `NO_PUBLICABLES`: ficheros que la API devuelve pero no se publican (`.platform`).
- `ESTADOS_FINALES_JOB`: estados de un job que terminan la espera de `esperar_job`: `Completed`, `Failed`, `Cancelled` y `Deduped`.
- `ESCRITURA_SQL`: palabras clave que hacen rechazar una consulta.
- `CARPETAS_LAKEHOUSE` (carpetas `sql` y `lakehouse` de `fabric/`), `COLUMNAS_ESQUEMA` (cabecera de `lakehouse/esquema.tsv`), `CONSULTA_VISTAS` y `CONSULTA_COLUMNAS` (vistas y columnas de las capas 100, 200 y 300).
- Rutas, URL de la API e identificadores del workspace, tenant, cuenta y SQL endpoint: ver [[configuration]]; sus valores no se documentan aquí.

Dependencias y versiones: ver [[configuration]].

## Evidence

- `exportar_fabric.py#descargar_todo` - exportación de items, filtrada por `es_exportable`.
- `exportar_fabric.py#main`, `exportar_fabric.py#comprobar`, `exportar_fabric.py#exportar` - argumentos y códigos de salida de exportar.
- `publicar_fabric.py#main`, `publicar_fabric.py#_preparar_vistas`, `publicar_fabric.py#_publicar_vistas` - argumentos, simulación, creación con `--crear`, vistas y códigos de salida de publicar.
- `ejecutar_fabric.py#main` - argumentos, simulación, espera y códigos de salida de ejecutar.
- `fabric_comun.py#lanzar_pipeline`, `#esperar_job`, `#leer_parametros`, `#ESTADOS_FINALES_JOB` - lanzamiento y espera de jobs.
- `fabric_comun.py#crear_item`, `#vista_de_ruta`, `#sentencia_de_vista`, `#publicar_vista` - creación de items y publicación de vistas.
- `consultar_sql.py#main` - argumentos y códigos de salida de la consulta.
- `validar_ficheros_grupo.py#main`, `validar_ficheros_grupo.py#validar_ageing`, `validar_ficheros_grupo.py#validar_revenue` - argumentos, líneas de salida y códigos de salida de la validación.
- `fabric_comun.py#comprobar_cuenta`, `fabric_comun.py#token` - cuenta y tokens.
- `fabric_comun.py#es_exportable`, `fabric_comun.py#ITEMS_DE_SISTEMA` - exclusión de items de sistema.
- `fabric_comun.py#descargar_definicion`, `fabric_comun.py#publicar_definicion`, `fabric_comun.py#partes_para_publicar` - definiciones de items.
- `fabric_comun.py#ficheros_en_git`, `fabric_comun.py#solo_items`, `fabric_comun.py#comparar` - lectura de git y comparación.
- `fabric_comun.py#descargar_sql`, `fabric_comun.py#ficheros_sql`, `fabric_comun.py#es_consulta_de_lectura` - SQL del lakehouse.
- `fabric_comun.py#FORMATOS`, `fabric_comun.py#NO_PUBLICABLES` - constantes de formato y exclusión.
