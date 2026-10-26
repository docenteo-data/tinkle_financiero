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
tags: [rf-scripts, quality]
---

# rf-scripts - Quality

> Cuándo cargar: necesitas saber qué prueban los tests de los scripts de Fabric, cómo ejecutarlos o qué protecciones tienen antes de tocar el workspace de Tinkle.

## Tests unitarios

`reporting-financiero/tests/test_fabric_comun.py` no necesita conexión. Según su docstring y sus nombres, cubre:

- Sincronía: `comparar` detecta ficheros nuevos, cambiados y borrados, y no da falsos positivos cuando no hay diferencias.
- Metadatos: `partes_para_publicar` excluye `.platform` y codifica las partes en base64 (`InlineBase64`).
- Formatos: `FORMATOS` fija TMDL para SemanticModel, PBIR para Report e ipynb para Notebook. Dataflow y DataPipeline no tienen formato y UserDataFunction no figura.
- Alcance: `solo_items` conserva las carpetas de items y las del lakehouse (`sql`, `lakehouse`) y excluye `temas/` y las UDF.
- SQL generado: `ficheros_sql` produce `sql/<esquema>.<vista>.sql` y `lakehouse/esquema.tsv` con la cabecera esperada.
- Nombres: `separar_item` separa tipo y nombre, también cuando el nombre tiene paréntesis.
- Solo lectura: `es_consulta_de_lectura` acepta SELECT y WITH y rechaza DELETE, UPDATE, INSERT, EXEC, SELECT INTO, MERGE, CREATE y las sentencias encadenadas con `;`. No se deja engañar por palabras dentro de textos o nombres entre corchetes.
- Errores de herramienta: un fallo de Azure CLI (`token`) o de git (`ficheros_en_git`) sale con código 2 y no con 1.

## Test E2E

`reporting-financiero/tests/test_fabric_e2e.py` se omite salvo que `FABRIC_E2E=1` y haya sesión de Azure CLI en la cuenta de Tinkle. Solo lee de Fabric:

- `exportar_fabric.py --comprobar main`: main debe coincidir con Fabric (código 0).
- `consultar_sql.py` con un SELECT sobre INFORMATION_SCHEMA del esquema 300: debe terminar con 0 y mencionar "300". La comprobación es débil, solo busca el texto en la salida.
- `consultar_sql.py` con un DELETE: debe terminar con 2.

## Ejecución

Desde la raíz del repositorio, con el Python del entorno virtual de `reporting-financiero`:

- Unitarios: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests/test_fabric_comun.py`
- Con E2E: `FABRIC_E2E=1 reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests` (en PowerShell, `$env:FABRIC_E2E = "1"` antes).
- `pytest==9.1.1` está fijado en `reporting-financiero/requirements.txt` e instalado en el `.venv`.

## Protecciones

- Cuenta: `comprobar_cuenta` compara el tenant de `az account show` con el de Tinkle y sale con código 2 si no coincide. Lo llaman `consultar_sql`, `exportar_fabric` y `publicar_fabric`.
- Solo lectura en SQL: `consultar_sql.py#main` devuelve 2 si la sentencia no pasa `es_consulta_de_lectura`. Es un filtro por palabras clave, no un analizador SQL. TBD: confirmar que los permisos de la conexión son de solo lectura.
- CSV solo en `data/`: `consultar_sql.py#main` devuelve 2 si `--csv` apunta fuera de `reporting-financiero/data/`, carpeta que no se versiona.
- Simulación por defecto: `publicar_fabric.py#main` solo publica con `--confirmar`. Sin él muestra el resumen y no escribe nada.
- Solo items existentes: no crea ni borra items. Sale con 2 si un item no existe en Fabric o no está en `--ref`.
- Comprobación de sincronía: antes de publicar, descarga el item de Fabric y lo compara con `--base` (por defecto main). Si hay diferencias sale con 1 y no publica. `--forzar` lo omite y avisa de que se pierden los cambios de Fabric.
- UDF excluidas: `FORMATOS` no incluye UserDataFunction, `solo_items` las descarta y `publicar_fabric` rechaza ese tipo con 2.

## No cubierto

- La publicación real no se prueba: escribiría en el workspace del cliente, que no tiene entorno de pruebas. Los tests cubren funciones puras y la salida con código 2 ante fallos de Azure CLI o git; la simulación de `publicar_fabric.py` no tiene test.
- Sin test: `publicar_fabric.main` (simulación, código 1, `--forzar`), `comprobar_cuenta`, las llamadas REST (`items`, `descargar_definicion`, `publicar_definicion`), `conectar_sql` y `exportar_fabric.main`, salvo el `--comprobar` del E2E.
- El E2E de SQL no verifica resultados concretos.
- No hay workspace de pruebas: es el único entorno del cliente. Una publicación se valida así: una persona refresca o ejecuta en Fabric y comprueba las cifras de control; después se exporta, se revisa `git diff` y `exportar_fabric.py --comprobar main` debe dar 0.

## Evidence

- `reporting-financiero/tests/test_fabric_comun.py` - tests unitarios y modos de fallo.
- `reporting-financiero/tests/test_fabric_e2e.py` - E2E de solo lectura, activado con FABRIC_E2E=1.
- `reporting-financiero/scripts/fabric_comun.py#comprobar_cuenta`, `#comparar`, `#solo_items`, `#partes_para_publicar`, `#es_consulta_de_lectura`, `#ficheros_sql`, `FORMATOS`.
- `reporting-financiero/scripts/publicar_fabric.py#main` - simulación, sincronía, `--forzar` y códigos de salida.
- `reporting-financiero/scripts/consultar_sql.py#main` - filtro de lectura y CSV en `data/`.
- `reporting-financiero/scripts/exportar_fabric.py#main` - códigos de salida.
- `test_fabric_comun.py#test_fallo_de_azure_cli_sale_con_codigo_2`, `test_fabric_comun.py#test_fallo_de_git_sale_con_codigo_2` - errores de herramienta con código 2.
