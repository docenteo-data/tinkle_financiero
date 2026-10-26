---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
source_globs: ["fabric_comun.py", "consultar_sql.py"]
tags: [rf-scripts, integrations]
---

# rf-scripts - Integrations

> Cuándo cargar: necesitas saber con qué sistemas externos hablan los scripts de Fabric, cómo se autentican y por qué se usan estas herramientas.

## Visión general

Los scripts de `reporting-financiero/scripts` hablan con cuatro sistemas: la API REST de Fabric, Azure CLI (origen de los tokens), el SQL endpoint del lakehouse y git local. La lógica común vive en `fabric_comun.py`; `consultar_sql.py` es una consulta de solo lectura que la reutiliza.

## Fabric REST API

- Base: API v1 de Fabric, siempre sobre el workspace de Tinkle (identificador en `fabric_comun.py`).
- Listar items: GET sobre los items del workspace. Cada item se identifica como `<nombre>.<tipo>` en las carpetas locales.
- getDefinition: POST sobre el item. Los tipos con formato (semantic model en TMDL, report en PBIR, notebook en ipynb) piden el formato en la query; dataflow y data pipeline no. Si la respuesta no es 200, se trata como operación asíncrona y se lee su resultado.
- updateDefinition: POST con las partes en base64 (`InlineBase64`), ordenadas por ruta y sin el fichero `.platform`. Si responde 202, se espera la operación.
- Operaciones asíncronas: se lee el identificador de `x-ms-operation-id`, se espera según `Retry-After` (3 segundos por defecto) y se consulta el estado hasta 120 veces. Succeeded termina; Failed lanza error; agotar los intentos lanza timeout.
- Excluido: User Data Functions, porque su código lleva un secreto incrustado.

## Azure CLI

- Los scripts no tienen credenciales propias: piden un token a `az` en cada ejecución (`account get-access-token`), uno para el recurso de Fabric y otro para el de bases de datos.
- Antes de llamar a Fabric o al SQL endpoint se comprueba que la cuenta activa de Azure CLI pertenece al tenant de Tinkle. Si no, el script sale con código 2 e indica el comando `az account set`.
- Si `az` falla, el script termina con código 2 pidiendo que se ejecute `az login`.
- Por qué el token no se guarda: la regla escrita en el código es que ningún script imprime tokens ni los escribe en ficheros. Cada ejecución pide uno nuevo.

## SQL endpoint del lakehouse

- Conexión con el driver `mssql-python`, versión fijada en `requirements.txt`, al SQL endpoint del lakehouse de Tinkle (valores en `fabric_comun.py`).
- Autenticación: token de Entra para el recurso de bases de datos, pasado al driver como atributo de conexión. La cadena de conexión solo lleva servidor, base de datos y cifrado; no hay usuario, contraseña ni DSN.
- `descargar_sql` lee las vistas de los esquemas 100, 200 y 300 y las columnas del esquema de información. Las vistas van a `sql/` y las columnas a `lakehouse/esquema.tsv`.
- `consultar_sql.py` solo admite sentencias que empiezan por SELECT o WITH y no contienen palabras de escritura. Códigos de salida: 0 correcto, 1 error de consulta, 2 sin sentencia, sentencia no permitida, CSV fuera de `reporting-financiero/data/`, cuenta incorrecta o fallo de Azure CLI. Con `--csv` solo escribe dentro de `reporting-financiero/data/`, que no se versiona.
- Por qué no ODBC: el código no lo justifica. Ver preguntas abiertas.

## Git

- `ficheros_en_git` lee un commit sin hacer checkout: `git archive` de `reporting-financiero/fabric` en la referencia indicada, con `core.autocrlf=false` para que no haya conversión de finales de línea. Así los bytes del commit se comparan tal cual con los de Fabric.
- Los ficheros se leen del tar en memoria; no se escriben en el árbol de trabajo.
- `comparar` clasifica las diferencias en nuevos, cambiados y borrados.
- Si `git archive` falla (referencia inexistente), el script sale con código 2.

## Señales para el grafo

- Infraestructura: workspace de Fabric; SQL endpoint del lakehouse.
- Tecnologías: Fabric REST API; Azure CLI; mssql-python.

## Open questions

- TBD: motivo de usar mssql-python con token de Entra en lugar de ODBC; no está documentado en el código.

## Evidence

- `fabric_comun.py#peticion`, `#esperar_operacion`, `#items`, `#descargar_definicion`, `#partes_para_publicar`, `#publicar_definicion` - API REST de Fabric y operaciones asíncronas.
- `fabric_comun.py#_az`, `#comprobar_cuenta`, `#token` - Azure CLI, tenant y tokens.
- `fabric_comun.py#conectar_sql`, `#ficheros_sql`, `#descargar_sql` - SQL endpoint y driver.
- `fabric_comun.py#es_consulta_de_lectura` - filtro de solo lectura.
- `fabric_comun.py#ficheros_en_git`, `#comparar` - lectura de commits con git archive.
- `consultar_sql.py#main` - restricción de CSV y códigos de salida.
- `reporting-financiero/requirements.txt` - versión fijada de mssql-python.
