---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
source_globs: ["fabric_comun.py", "consultar_sql.py", "validar_ficheros_grupo.py", "anexo_pendientes.py", "md_a_docx.py"]
tags: [rf-scripts, integrations]
---

# rf-scripts - Integrations

> Cuándo cargar: necesitas saber con qué sistemas externos y ficheros hablan los scripts de `reporting-financiero/scripts`, cómo se autentican y por qué se usan estas herramientas.

## Visión general

Los scripts de `reporting-financiero/scripts` hablan con cuatro sistemas externos: la API REST de Fabric, Azure CLI (origen de los tokens), el SQL endpoint del lakehouse y git local. Además leen ficheros de la carpeta `3.Fuentes` del OneDrive del proyecto y producen documentos Word a partir de Markdown del propio repositorio. La lógica común de Fabric vive en `fabric_comun.py`; `consultar_sql.py` y `validar_ficheros_grupo.py` reutilizan su conexión SQL.

## Fabric REST API

- Base: API v1 de Fabric, siempre sobre el workspace de Tinkle (identificador en `fabric_comun.py`).
- Listar items: GET sobre los items del workspace. Cada item se identifica como `<nombre>.<tipo>` en las carpetas locales.
- getDefinition: POST sobre el item. Los tipos con formato (semantic model en TMDL, report en PBIR, notebook en ipynb) piden el formato en la query; dataflow y data pipeline no. Si la respuesta no es 200, se trata como operación asíncrona y se lee su resultado.
- updateDefinition: POST con las partes en base64 (`InlineBase64`), ordenadas por ruta y sin el fichero `.platform`. Si responde 202, se espera la operación.
- Operaciones asíncronas: se lee el identificador de `x-ms-operation-id`, se espera según `Retry-After` (3 segundos por defecto) y se consulta el estado hasta 120 veces. Succeeded termina; Failed lanza error; agotar los intentos lanza timeout.
- Excluido de la exportación: User Data Functions, porque su código lleva un secreto incrustado. Los items que Power BI crea solo al abrir las métricas de uso de un informe (Report Usage Metrics Report, Report Usage Metrics Model y Usage Metrics Report) también se omiten, porque la API no permite exportarlos. El criterio está en `es_exportable`, que usa `exportar_fabric.py` al descargar todo el workspace.

## Azure CLI

- Los scripts no tienen credenciales propias: piden un token a `az` en cada ejecución (`account get-access-token`), uno para el recurso de Fabric y otro para el de bases de datos.
- Antes de llamar a Fabric o al SQL endpoint se comprueba que la cuenta activa de Azure CLI pertenece al tenant de Tinkle. Si no, el script sale con código 2 e indica el comando `az account set`. `validar_ficheros_grupo.py` hace la misma comprobación antes de consultar.
- Si `az` falla, el script termina con código 2 pidiendo que se ejecute `az login`.
- Por qué el token no se guarda: la regla escrita en el código es que ningún script imprime tokens ni los escribe en ficheros. Cada ejecución pide uno nuevo.

## SQL endpoint del lakehouse

- Conexión con el driver `mssql-python`, versión fijada en `requirements.txt`, al SQL endpoint del lakehouse de Tinkle (valores en `fabric_comun.py`).
- Autenticación: token de Entra para el recurso de bases de datos, pasado al driver como atributo de conexión. La cadena de conexión solo lleva servidor, base de datos y cifrado; no hay usuario, contraseña ni DSN.
- `descargar_sql` lee las vistas de los esquemas 100, 200 y 300 y las columnas del esquema de información. Las vistas van a `sql/` y las columnas a `lakehouse/esquema.tsv`.
- `consultar_sql.py` solo admite sentencias que empiezan por SELECT o WITH y no contienen palabras de escritura. Códigos de salida: 0 correcto, 1 error de consulta, 2 sin sentencia, sentencia no permitida, CSV fuera de `reporting-financiero/data/`, cuenta incorrecta o fallo de Azure CLI. Con `--csv` solo escribe dentro de `reporting-financiero/data/`, que no se versiona.
- `validar_ficheros_grupo.py` usa la misma conexión, pero con dos consultas fijas escritas en el propio script, ambas SELECT de solo lectura: una sobre `200.MMS` (facturas y códigos de cliente del sistema de órdenes MMS por sociedad) y otra sobre `300.Fact_Actuals` cruzada con `300.Dim_Cuentas` y `300.Dim_Clientes` (importes de las cuentas X agrupadas en `X60000` y `X70000`, de enero a marzo de 2026). Estas consultas no pasan por el filtro de `consultar_sql.py`.
- Por qué no ODBC: el código no lo justifica. Ver preguntas abiertas.

## Ficheros locales: validación de Grupo

- `validar_ficheros_grupo.py` no escribe nada. Lee de la carpeta `3.Fuentes` del OneDrive del proyecto (dentro de Reporting financiero; `--fuentes` permite indicar otra ruta) con openpyxl: el aging de clientes a 31-03-2026 (hoja DATOS), el libro Revenue 2026 FT3 (.xlsm, que aporta el mapeo de códigos de cliente Magnitude) y los TXT de Magnitude de marzo, separados por punto y coma, de las carpetas Ageing y Revenue.
- Reproduce el fichero de Grupo desde las fuentes y lo compara con el TXT real. Por sociedad y tramo en ageing, y por sociedad en revenue, la cifra de control debe cuadrar; el código de cliente Magnitude se compara aparte y es informativo, porque el Excel de Revenue no es el maestro de Magnitude.
- Códigos de salida: 0 las cifras de control cuadran, 1 no cuadran, 2 cuenta de Azure CLI incorrecta o carpeta de ficheros no encontrada.
- Dependencia: `openpyxl` 3.1.5, fijado en `requirements.txt`.
- Reglas de negocio y estado de los ficheros de Grupo en [[domains/ficheros-de-grupo]].

## Ficheros locales: pendientes de la auditoría

- `anexo_pendientes.py` no llama a ningún servicio. Lee documentos Markdown del repositorio: la tabla de conceptos de la sección 1 de la auditoría general, el registro de reuniones (`docs/reuniones/README.md`, puntos P-nnn), la sección 13 de la documentación técnica (riesgos S, O, M, D y N, con su estado más reciente) y `docs/contexto/PREGUNTAS_PARA_TINKLE.md`.
- Escribe el anexo entre las marcas `<!-- anexo:inicio -->` y `<!-- anexo:fin -->` del documento de auditoría, o al final si no existen. Es idempotente. Si un punto del registro no está asignado a ningún concepto, aborta con error.

## Ficheros locales: Markdown a Word

- `md_a_docx.py` convierte un Markdown del proyecto en un .docx de Docenteo. No usa red ni librerías externas: toma la plantilla `docenteo-documento.dotx` de la skill docenteo-design instalada en la caché de plugins (la versión más alta, salvo que se indique `--plantilla`) y reemplaza el cuerpo, la numeración y el título del documento dentro del ZIP.
- Solo usa los estilos de la plantilla. Si no encuentra la plantilla sale con código 2.
- Convenciones de entrada: la primera línea es el título, los "##" son capítulos numerados, las tablas de conceptos se parten por bloque y las líneas "<!-- -->" se ignoran.
- Su dependencia es la instalación local del plugin docenteo-skills, no un servicio.

## Git

- `ficheros_en_git` lee un commit sin hacer checkout: `git archive` de `reporting-financiero/fabric` en la referencia indicada, con `core.autocrlf=false` para que no haya conversión de finales de línea. Así los bytes del commit se comparan tal cual con los de Fabric.
- Los ficheros se leen del tar en memoria; no se escriben en el árbol de trabajo.
- `comparar` clasifica las diferencias en nuevos, cambiados y borrados.
- Si `git archive` falla (referencia inexistente), el script sale con código 2.

## Señales para el grafo

- Infraestructura: workspace de Fabric; SQL endpoint del lakehouse; carpeta 3.Fuentes del OneDrive del proyecto.
- Tecnologías: Fabric REST API; Azure CLI; mssql-python; openpyxl.

## Open questions

- TBD: motivo de usar mssql-python con token de Entra en lugar de ODBC; no está documentado en el código.

## Evidence

- `fabric_comun.py#peticion`, `#esperar_operacion`, `#items`, `#descargar_definicion`, `#partes_para_publicar`, `#publicar_definicion` - API REST de Fabric y operaciones asíncronas.
- `fabric_comun.py#es_exportable`, `exportar_fabric.py#descargar_todo` - exclusión de items de sistema en la exportación.
- `fabric_comun.py#_az`, `#comprobar_cuenta`, `#token` - Azure CLI, tenant y tokens.
- `fabric_comun.py#conectar_sql`, `#ficheros_sql`, `#descargar_sql` - SQL endpoint y driver.
- `fabric_comun.py#es_consulta_de_lectura`, `consultar_sql.py#main` - filtro de solo lectura y códigos de salida.
- `validar_ficheros_grupo.py#main`, `#validar_ageing`, `#validar_revenue`, `#mapeo_magnitude`, `#consultar` - lectura de Excel y TXT, consultas SQL y comparación con los ficheros de Grupo.
- `anexo_pendientes.py#generar`, `#leer_registro`, `#leer_tecnica` - documentos Markdown del repositorio y anexo de la auditoría.
- `md_a_docx.py#plantilla_por_defecto`, `#convertir` - plantilla Word y generación del .docx.
- `fabric_comun.py#ficheros_en_git`, `#comparar` - lectura de commits con git archive.
- `reporting-financiero/requirements.txt` - versiones fijadas de mssql-python y openpyxl.
