---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
source_globs: ["*.py"]
tags: [rf-scripts, apis]
---

# rf-scripts - APIs

> Cuándo cargar: necesitas ejecutar los scripts de Fabric de Tinkle, conocer sus argumentos y códigos de salida, o reutilizar una función de `fabric_comun.py`.

## Interfaz de línea de comandos

Todos se ejecutan desde la raíz del repositorio con `python reporting-financiero/scripts/<script>.py`. Requieren Azure CLI con la cuenta de Tinkle por defecto. Ningún script guarda tokens.

Si Azure CLI o git fallan, el script imprime el error y sale con código 2, para no confundirlo con el 1 (hay diferencias).

### exportar_fabric.py

Solo lectura sobre Fabric. Sin argumentos regenera `reporting-financiero/fabric/` entera (salvo `temas/`).

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

Escribe en el workspace del cliente. Sin `--confirmar` solo simula. Solo actualiza items que ya existen; no crea ni borra.

| Argumento | Por defecto | Significado |
|---|---|---|
| `items` | obligatorio, uno o más | Carpetas de `fabric/`, por ejemplo `"Financial Model.SemanticModel"`. Solo tipos con formato publicable. |
| `--ref` | `HEAD` | Commit, rama o etiqueta de donde se leen las definiciones. Se lee de git, no de la carpeta de trabajo. |
| `--base` | `main` | Referencia con la que Fabric debe coincidir antes de publicar. |
| `--confirmar` | desactivado | Sin él, simulación. Con él, publica. |
| `--forzar` | desactivado | Publica aunque Fabric no coincida con `--base`, perdiendo esos cambios. Solo con decisión explícita. |

| Código | Significado |
|---|---|
| 0 | Publicado, o simulación correcta. |
| 1 | Fabric no coincide con `--base` (sin `--forzar`). |
| 2 | Tipo no publicable, item inexistente en Fabric, item ausente en `--ref`, error de lectura o publicación, cuenta incorrecta, fallo de Azure CLI, o `--ref`/`--base` inexistente en git. |

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

## Funciones públicas de fabric_comun.py

Módulo importado como `fc` por los tres scripts. Las funciones con prefijo `_` son privadas.

### Cuenta y tokens

- `comprobar_cuenta()`: devuelve el usuario de Azure CLI si es la cuenta de Tinkle; si no, sale con código 2.
- `token(recurso)`: devuelve un access token de Azure CLI para el recurso indicado, por defecto la API de Fabric.

### API REST de Fabric

- `peticion(metodo, url, tok, cuerpo)`: llamada HTTP con bearer; devuelve estado, cabeceras y cuerpo JSON.
- `esperar_operacion(cabeceras, tok, con_resultado)`: sondea una operación larga hasta terminar y devuelve su resultado si se pide.
- `items(tok)`: devuelve la lista de items del workspace.
- `nombre_carpeta(item)`: devuelve el nombre de carpeta `Nombre.Tipo` de un item.
- `separar_item(carpeta)`: devuelve la pareja (nombre, tipo) de una carpeta `Nombre.Tipo`.
- `descargar_definicion(item, tok)`: devuelve un diccionario ruta a bytes con la definición actual del item.
- `partes_para_publicar(ficheros)`: devuelve las partes de la definición en base64, sin los ficheros no publicables.
- `publicar_definicion(item, ficheros, tok)`: envía la definición al item y espera a que la operación termine.

### Git y comparación

- `ficheros_en_git(ref, carpeta)`: devuelve, como ruta a bytes, los ficheros de `carpeta` tal como están en el commit ref.
- `solo_items(ficheros, carpetas)`: filtra los ficheros a los items exportables o a las carpetas indicadas.
- `comparar(fabric, repo)`: devuelve tres listas de rutas: nuevas, cambiadas y borradas.

### SQL

- `conectar_sql()`: abre una conexión al SQL endpoint del lakehouse con un token de Azure CLI.
- `ficheros_sql(vistas, columnas)`: convierte las filas de vistas y columnas en ficheros de `sql/` y `lakehouse/`.
- `descargar_sql()`: lee vistas y esquema del lakehouse y devuelve esos ficheros.
- `es_consulta_de_lectura(sql)`: devuelve True si la sentencia empieza por SELECT o WITH y no contiene palabras de escritura.

### Utilidad

- `ascii(texto)`: devuelve el texto en ASCII, sustituyendo los caracteres no válidos, para la consola de Windows.

## Constantes públicas

- `FORMATOS`: tipo de item a formato de definición pedido a la API. `SemanticModel` usa TMDL, `Report` PBIR y `Notebook` ipynb; `Dataflow` y `DataPipeline` no piden formato. Solo estos tipos se exportan y publican.
- `NO_PUBLICABLES`: ficheros que la API devuelve pero no se publican (`.platform`).
- `ESCRITURA_SQL`: palabras clave que hacen rechazar una consulta.
- `CARPETAS_LAKEHOUSE`: carpetas de `fabric/` que salen del SQL endpoint (`sql` y `lakehouse`).
- `COLUMNAS_ESQUEMA`: cabecera de `lakehouse/esquema.tsv`.
- `CONSULTA_VISTAS` y `CONSULTA_COLUMNAS`: consultas que leen las vistas y las columnas de las capas 100, 200 y 300.
- `API`: URL base de la API REST de Fabric.
- `RAIZ_REPO` y `CARPETA_FABRIC`: raíz del repositorio y carpeta `reporting-financiero/fabric`.
- `WORKSPACE_ID`, `TENANT_ID`, `CUENTA`, `SQL_SERVIDOR` y `SQL_BASE_DATOS`: identificadores del workspace, tenant, cuenta y SQL endpoint. Son constantes de `fabric_comun.py`; sus valores no se documentan aquí.

## Dependencias

- Python 3.14.7 (`reporting-financiero/.venv/pyvenv.cfg`); `mssql-python==1.16.0` y `pytest==9.1.1` en `reporting-financiero/requirements.txt`; Azure CLI no está declarado en ningún fichero.

## Evidence

- `exportar_fabric.py#main`, `exportar_fabric.py#comprobar`, `exportar_fabric.py#exportar` - argumentos y códigos de salida de exportar.
- `publicar_fabric.py#main` - argumentos, simulación y códigos de salida de publicar.
- `consultar_sql.py#main` - argumentos y códigos de salida de la consulta.
- `fabric_comun.py#comprobar_cuenta`, `fabric_comun.py#token` - cuenta y tokens.
- `fabric_comun.py#descargar_definicion`, `fabric_comun.py#publicar_definicion`, `fabric_comun.py#partes_para_publicar` - definiciones de items.
- `fabric_comun.py#ficheros_en_git`, `fabric_comun.py#solo_items`, `fabric_comun.py#comparar` - lectura de git y comparación.
- `fabric_comun.py#descargar_sql`, `fabric_comun.py#ficheros_sql`, `fabric_comun.py#es_consulta_de_lectura` - SQL del lakehouse.
- `fabric_comun.py#FORMATOS`, `fabric_comun.py#NO_PUBLICABLES` - constantes de formato y exclusión.
