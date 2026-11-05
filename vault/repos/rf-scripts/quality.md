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
tags: [rf-scripts, quality]
---

# rf-scripts - Quality

> Cuándo cargar: necesitas saber qué prueban los tests de los scripts de Fabric y de los generadores de documentos, cómo ejecutarlos o qué protecciones tienen antes de tocar el workspace de Tinkle o los ficheros de Grupo. Contexto de los ficheros de Grupo: [[domains/ficheros-de-grupo]].

## Tests unitarios de Fabric

`reporting-financiero/tests/test_fabric_comun.py` no necesita conexión. Según su docstring y sus nombres, cubre:

- Sincronía: `comparar` detecta ficheros nuevos, cambiados y borrados, y no da falsos positivos cuando no hay diferencias.
- Metadatos: `partes_para_publicar` excluye `.platform` y codifica las partes en base64 (`InlineBase64`).
- Formatos: `FORMATOS` fija TMDL para SemanticModel, PBIR para Report e ipynb para Notebook. Dataflow y DataPipeline no tienen formato y UserDataFunction no figura.
- Alcance: `solo_items` conserva las carpetas de items y las del lakehouse (`sql`, `lakehouse`) y excluye `temas/` y las UDF.
- Items de uso: `es_exportable` descarta los informes y modelos "Report Usage Metrics" que Power BI crea al abrir las métricas de uso, las UDF y el lakehouse, y mantiene los modelos e informes de negocio.
- SQL generado: `ficheros_sql` produce `sql/<esquema>.<vista>.sql` y `lakehouse/esquema.tsv` con la cabecera esperada.
- Nombres: `separar_item` separa tipo y nombre, también cuando el nombre tiene paréntesis.
- Solo lectura: `es_consulta_de_lectura` acepta SELECT y WITH y rechaza DELETE, UPDATE, INSERT, EXEC, SELECT INTO, MERGE, CREATE y las sentencias encadenadas con `;`. No se deja engañar por palabras dentro de textos o nombres entre corchetes.
- Errores de herramienta: un fallo de Azure CLI (`token`) o de git (`ficheros_en_git`) sale con código 2 y no con 1, para que no se confunda con "hay diferencias con Fabric".

## Tests de exportación con --solo

`reporting-financiero/tests/test_exportar_fabric.py` prueba la opción `--solo` de `exportar_fabric.py` con las llamadas a Fabric y a git sustituidas. Modos de fallo que cubre:

- `carpetas_solo` convierte `lakehouse` en las carpetas `sql` y `lakehouse`, y sin `--solo` devuelve `None`.
- Con `--solo` no se descarga ningún item que no se pidió, y las vistas solo se leen si se pide `lakehouse`.
- Con `--solo` no se borran las carpetas de los demás items al exportar, y `lakehouse` regenera solo vistas y esquema.
- Un nombre que no existe en el workspace sale con código 2 sin descargar nada.
- Con `--comprobar --solo` se comparan solo las carpetas pedidas; sin `--solo`, lo que falta en Fabric cuenta como diferencia.
- Sin `--solo` se mantiene el comportamiento de siempre: regenerar y comparar todo.

## Tests de publicación y ejecución de Fabric

Estos tests no abren conexión: sustituyen las llamadas a Fabric, Azure CLI y el SQL endpoint por funciones falsas.

- `reporting-financiero/tests/test_publicar_vistas.py` prueba las vistas de `publicar_fabric.py`. Modos de fallo que cubre: `vista_de_ruta` acepta solo `sql/100|200|300.nombre.sql`; una vista nueva se ejecuta tal cual y una existente usa `CREATE OR ALTER`; una sentencia que no crea la vista de su ruta se rechaza; la simulación no escribe; `--confirmar` crea o actualiza la vista; si Fabric difiere de `--base` sale con 1; una vista ausente en `--ref` sale con 2.
- `reporting-financiero/tests/test_crear_items.py` prueba `publicar_fabric.py --crear`. Modos de fallo que cubre: se crea un item sin `--crear` (error 2); la simulación crea algo; se recrea un item que `main` tenía y que alguien ha borrado en Fabric (sale con 1); la creación no espera a una operación asíncrona; `--crear` cambia los items existentes.
- `reporting-financiero/tests/test_ejecutar_fabric.py` prueba `ejecutar_fabric.py` y `esperar_job`. Modos de fallo que cubre: la simulación lanza el pipeline; un pipeline inexistente o que no es `DataPipeline` sale con 2; un pipeline `Failed` se da por bueno (sale con 1); la espera se agota sin terminar nunca (error); un parámetro mal escrito (sin `=`) se pasa a Fabric.

## Tests de generadores de documentos

Estos tests no tocan Fabric.

- `reporting-financiero/tests/test_anexo_pendientes.py` prueba `scripts/anexo_pendientes.py` sobre una copia de `docs/auditoria/auditoria-general.md`, nunca sobre el original. Modos de fallo que cubre:
  - Un punto del registro (P-001 a P-226) falta o aparece dos veces en el anexo.
  - Una referencia técnica (S, O, M, D, N) o una de las preguntas pendientes de `PREGUNTAS_PARA_TINKLE.md` (el test las lee del propio fichero, porque se renumeran al llegar respuestas) queda sin explicar.
  - El anexo contiene rayas largas o flechas.
  - Volver a ejecutarlo duplica el anexo en lugar de reemplazarlo.
- `reporting-financiero/tests/test_md_a_docx.py` prueba `scripts/md_a_docx.py` generando un .docx de prueba con portada. Necesita la plantilla `docenteo-documento.dotx` de la skill docenteo-design; si no está instalada, los tests se saltan. Modos de fallo que cubre:
  - El resultado sale como plantilla (.dotx) y Word no lo abre como documento.
  - El título no llega a la portada ni a las propiedades del documento.
  - Se usan formatos directos en lugar de los estilos de la plantilla, o quedan comentarios Markdown en el resultado.
  - Una segunda lista numerada continúa la numeración de la primera.
  - La tabla de conceptos no sale por bloques o pierde la nota de pendientes.
  - Dos tablas seguidas se funden en una, o una etiqueta de bloque se separa de su tabla.

## Test E2E de Fabric

`reporting-financiero/tests/test_fabric_e2e.py` se omite salvo que `FABRIC_E2E=1` y haya sesión de Azure CLI en la cuenta de Tinkle. Solo lee de Fabric:

- `exportar_fabric.py --comprobar main`: main debe coincidir con Fabric (código 0).
- `consultar_sql.py` con un SELECT sobre INFORMATION_SCHEMA del esquema 300: debe terminar con 0 y mencionar "300". La comprobación es débil, solo busca el texto en la salida.
- `consultar_sql.py` con un DELETE: debe terminar con 2.

## E2E de ficheros de Grupo

`reporting-financiero/tests/test_validar_ficheros_grupo_e2e.py` prueba `scripts/validar_ficheros_grupo.py` contra los ficheros de marzo de 2026 de la carpeta `3.Fuentes` de OneDrive (TXT de Magnitude, aging de clientes y Revenue FT3). Se omite salvo que `FABRIC_E2E=1` y la carpeta esté sincronizada; el docstring pide además la sesión de Azure CLI de Tinkle. Comprueba:

- Ageing: la diferencia máxima entre los importes de cada sociedad y tramo es menor de 0,001. Modo de fallo: los tramos de días, el corte a 31-03-2026 o los importes en miles dejan de reproducir el TXT.
- Ageing: el informe da la cobertura de clientes (líneas del TXT reproducidas).
- Revenue: el total por sociedad de ESP067, ESP068, ESP069 y ESP070 cuadra con tolerancia de 0,05, porque cada línea del TXT viene redondeada a dos decimales. Modo de fallo: la medida REAL (Fees & other), el acumulado del año, el signo o los importes en miles dejan de reproducir el TXT.
- Revenue ESP066 (COMM): xfail estricto por una diferencia conocida de 6,82 (0,24%) sin explicar. Si se corrige, el test pasa a fallar y hay que quitar la marca.
- Revenue: el informe da la cobertura de clientes.
- Vista de Ageing (`300.vw_Export_Ageing`, sin GRICFLAG): la suma de importes coincide con `200.Aging_Clientes` en miles, sin duplicados por sociedad, cliente y tramo; tiene los valores fijos esperados y solo las sociedades ESP066 a ESP070. Modo de fallo: se pierden o duplican facturas al construir la vista.
- Vista de Ageing contra marzo (`ageing --vista`): la diferencia máxima por sociedad y tramo es menor de 0,001 y el informe da la cobertura de clientes y de GRICFLAG.

## Ejecución

Desde la raíz del repositorio, con el Python del entorno virtual de `reporting-financiero`:

- Unitarios de Fabric: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests/test_fabric_comun.py`
- Batería completa sin E2E: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests`
- Batería completa con E2E: en PowerShell, `$env:FABRIC_E2E = "1"` y después el mismo comando de la batería completa. Incluye el E2E de Fabric y el de ficheros de Grupo, que además necesita la carpeta `3.Fuentes` sincronizada.
- `pytest==9.1.1` está fijado en `reporting-financiero/requirements.txt` e instalado en el `.venv`.

## Protecciones

- Cuenta: `comprobar_cuenta` compara el tenant de `az account show` con el de Tinkle y sale con código 2 si no coincide. Lo llaman `consultar_sql`, `exportar_fabric`, `publicar_fabric`, `ejecutar_fabric` y `validar_ficheros_grupo`.
- Solo lectura en SQL: `consultar_sql.py#main` devuelve 2 si la sentencia no pasa `es_consulta_de_lectura`. Es un filtro por palabras clave, no un analizador SQL. TBD: confirmar que los permisos de la conexión son de solo lectura.
- CSV solo en `data/`: `consultar_sql.py#main` devuelve 2 si `--csv` apunta fuera de `reporting-financiero/data/`, carpeta que no se versiona.
- Simulación por defecto: `publicar_fabric.py#main` solo publica con `--confirmar`. Sin él muestra el resumen y no escribe nada.
- Solo con `--crear` se crean items que no existen en Fabric, y nunca se borran items ni vistas. Sin `--crear`, sale con 2 si un item no existe en Fabric, o si no está en `--ref`.
- Vistas: las sentencias se preparan antes de ejecutar nada. Se rechazan líneas `GO`, ficheros que no crean la vista de su ruta, y rutas fuera de los esquemas 100, 200 y 300.
- Pipelines: `ejecutar_fabric.py` lanza solo con `--confirmar`. Sin él, comprueba la cuenta y que el item existe y es `DataPipeline`, y no lanza nada. Un pipeline que termina en `Failed`, `Cancelled` o `Deduped` sale con 1.
- Comprobación de sincronía: antes de publicar, descarga el item de Fabric y lo compara con `--base` (por defecto main). Si hay diferencias sale con 1 y no publica. `--forzar` lo omite y avisa de que se pierden los cambios de Fabric.
- Exportación parcial: con `--solo`, solo se descargan y regeneran las carpetas pedidas, y un nombre inexistente sale con 2 antes de tocar `fabric/`.
- UDF excluidas: `FORMATOS` no incluye UserDataFunction, `solo_items` las descarta, `es_exportable` las filtra y `publicar_fabric` rechaza ese tipo con 2.

## No cubierto

- La publicación real no se prueba: escribiría en el workspace del cliente, que no tiene entorno de pruebas. Los tests cubren funciones puras, la simulación y la salida de `publicar_fabric.py` y `ejecutar_fabric.py` con sustitutos, y la salida con código 2 ante fallos de Azure CLI o git.
- Sin test: `--forzar` de `publicar_fabric.main`, `comprobar_cuenta`, las llamadas REST reales (`items`, `descargar_definicion`, `publicar_definicion`, `lanzar_pipeline`), `publicar_vista` y `conectar_sql`, y `exportar_fabric.main` (sus funciones `descargar_todo`, `exportar` y `comprobar` sí tienen tests con sustitutos; el `--comprobar` del E2E cubre la sincronía real). `crear_item` sí tiene tests, con la petición sustituida.
- El E2E de SQL no verifica resultados concretos.
- `validar_ficheros_grupo.py` no tiene tests unitarios: sus cálculos solo se comprueban con el E2E, que requiere la carpeta de OneDrive y FABRIC_E2E=1. Lo mismo ocurre con el modo `--vista`.
- Los tests de `md_a_docx.py` dependen de la plantilla externa de docenteo-design: sin ella se saltan y no fallan.
- La diferencia de 6,82 en COMM no está explicada.
- No hay workspace de pruebas: es el único entorno del cliente. Una publicación se valida así: una persona refresca o ejecuta en Fabric y comprueba las cifras de control; después se exporta, se revisa `git diff` y `exportar_fabric.py --comprobar main` debe dar 0.

## Evidence

- `reporting-financiero/tests/test_fabric_comun.py` - tests unitarios y modos de fallo de Fabric.
- `reporting-financiero/tests/test_exportar_fabric.py` - tests de `--solo` con sustitutos (`carpetas_solo`, `descargar_todo`, `exportar`, `comprobar`).
- `reporting-financiero/tests/test_fabric_e2e.py` - E2E de solo lectura, activado con FABRIC_E2E=1.
- `reporting-financiero/tests/test_anexo_pendientes.py` - sobre `scripts/anexo_pendientes.py` y `docs/auditoria/auditoria-general.md`.
- `reporting-financiero/tests/test_md_a_docx.py` - sobre `scripts/md_a_docx.py`, con la plantilla de docenteo-design.
- `reporting-financiero/tests/test_validar_ficheros_grupo_e2e.py` - E2E de ficheros de Grupo, vista de Ageing y modo `--vista` sobre `scripts/validar_ficheros_grupo.py`.
- `reporting-financiero/tests/test_publicar_vistas.py`, `test_crear_items.py` - vistas, creación de items y códigos de `scripts/publicar_fabric.py#main`.
- `reporting-financiero/tests/test_ejecutar_fabric.py` - `scripts/ejecutar_fabric.py#main` y `fabric_comun.py#esperar_job`, `#leer_parametros`.
- `reporting-financiero/scripts/fabric_comun.py#comprobar_cuenta`, `#comparar`, `#solo_items`, `#es_exportable`, `#partes_para_publicar`, `#es_consulta_de_lectura`, `#ficheros_sql`, `FORMATOS`.
- `reporting-financiero/scripts/publicar_fabric.py#main` - simulación, sincronía, `--forzar` y códigos de salida.
- `reporting-financiero/scripts/consultar_sql.py#main` - filtro de lectura y CSV en `data/`.
- `reporting-financiero/scripts/exportar_fabric.py#carpetas_solo`, `#descargar_todo`, `#exportar`, `#comprobar`, `#main` - opción `--solo` y códigos de salida.
- `reporting-financiero/scripts/validar_ficheros_grupo.py#validar_vista_ageing` - modo `--vista`.
- `test_fabric_comun.py#test_fallo_de_azure_cli_sale_con_codigo_2`, `test_fabric_comun.py#test_fallo_de_git_sale_con_codigo_2` - errores de herramienta con código 2.
- `test_fabric_comun.py#test_items_de_metricas_de_uso_no_se_exportan` - exclusión de items de uso.
