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
tags: [rf-scripts, overview]
---

# rf-scripts - Overview

> Cuándo cargar: necesitas saber qué script usar para exportar, comprobar, publicar, ejecutar un pipeline o consultar el workspace de Fabric del cliente Tinkle, validar los ficheros de Grupo, generar el anexo de la auditoría o convertir un Markdown a Word, y qué puede escribir cada uno.

## Propósito

Unidad de scripts Python para trabajar con el workspace de Fabric "Tinkle - Financiero" y con los entregables documentales del proyecto. El repositorio `main` refleja lo publicado en Fabric y `reporting-financiero/fabric/` es su copia en texto. Los scripts leen definiciones de Fabric, las comparan con el repo y, solo cuando se les pide, publican definiciones desde un commit. Otros scripts validan ficheros de reporting o generan documentos a partir de fuentes del propio repositorio.

El procedimiento completo (cómo leer, consultar, publicar, validar la cuenta, flujos de cambio y rollback) está en `reporting-financiero/docs/flujo-fabric.md`. Este overview no lo repite.

## Scripts

- `fabric_comun.py`: utilidades compartidas. Define el workspace, la cuenta esperada y el endpoint SQL, los tipos de item exportables y sus formatos, y las comprobaciones de cuenta. Decide qué items son exportables: excluye los items de sistema que Power BI crea al abrir las métricas de uso de un informe, porque la API no permite exportarlos. Obtiene los tokens de Azure CLI en cada ejecución y no los guarda. Contiene también la validación de que una consulta SQL sea de solo lectura. No es un punto de entrada.
- `exportar_fabric.py`: exporta las definiciones de los items a `fabric/` (modelos semánticos, informes, dataflows, pipelines y notebooks), las vistas del SQL endpoint y el esquema de columnas del lakehouse. Con `--comprobar [REF]` no escribe nada y dice si Fabric coincide con un commit (por defecto `main`). Con `--solo ITEM [ITEM ...]` exporta o compara solo esos items (`lakehouse` para las vistas y el esquema), sin tocar el resto de `fabric/`.
- `publicar_fabric.py`: publica en Fabric la definición de uno o varios items tal como está en un commit, y las vistas SQL de `sql/` (se crean si son nuevas y se actualizan si existen). Con `--crear` crea también los items que no existen en Fabric. Sirve para el flujo de cambio preparado en el repo y para el rollback. Sin `--confirmar` solo simula. Antes de publicar comprueba que Fabric coincide con la referencia base (por defecto main) y se detiene si no coincide, salvo `--forzar`.
- `ejecutar_fabric.py`: lanza un pipeline de Fabric con parámetros opcionales, espera a que termine y devuelve si ha sido `Completed` u otro estado final. Sin `--confirmar` solo simula.
- `consultar_sql.py`: consulta de solo lectura al SQL endpoint del lakehouse `lh_tinkle_financiero`. Acepta solo sentencias SELECT o WITH sin palabras de escritura. Imprime un máximo de filas o escribe el resultado completo en un CSV dentro de `reporting-financiero/data/`, que no se versiona.
- `validar_ficheros_grupo.py`: valida los ficheros de Grupo de Ageing y Revenue contra los TXT de Magnitude de marzo de 2026. Reproduce cada fichero desde las fuentes y compara sus cifras de control por sociedad y tramo (Ageing) o por sociedad (Revenue), y aparte el código de cliente Magnitude. Lee la carpeta `3.Fuentes` de OneDrive y consulta Fabric en solo lectura con la cuenta de Tinkle. Con `ageing --vista` no reproduce el aging desde el Excel: valida la vista `300.vw_Export_Ageing` de Fabric contra los TXT. Solo escribe en la salida estándar. Dominio asociado: [[domains/ficheros-de-grupo]].
- `anexo_pendientes.py`: genera el anexo de la auditoría general con todos los pendientes de cada concepto de su tabla de conceptos. Toma la descripción completa de cada concepto de tres fuentes del proyecto: los puntos del registro de reuniones, los riesgos técnicos de la documentación de contexto y las preguntas para Tinkle. Solo lee esas fuentes y escribe en el fichero de auditoría que recibe como argumento, entre las marcas del anexo.
- `md_a_docx.py`: convierte un documento Markdown del proyecto a Word con la plantilla de Docenteo. Solo usa los estilos de la plantilla (portada, títulos, listas, tablas y notas) y numera los apartados de forma automática. Busca la plantilla en la versión más alta instalada de la skill de diseño de Docenteo, salvo que se indique otra con `--plantilla`.

## Cuándo usar cada uno

- Comprobar sincronía o traer cambios de Fabric al repo: `exportar_fabric.py --comprobar main`, y después `exportar_fabric.py` si hay que regenerar `fabric/`. Para un solo item o para las vistas: `exportar_fabric.py --solo "<Item>" lakehouse --comprobar`.
- Publicar un cambio ya commiteado, o hacer rollback de un item o de una vista a un commit anterior: `publicar_fabric.py`, primero en simulación y después con `--confirmar`. Lo ejecuta una persona del equipo, o el agente solo con confirmación explícita en ese momento, porque el workspace del cliente no tiene entorno de pruebas.
- Crear un item que está en el repo pero no en Fabric: `publicar_fabric.py "<Item>" --crear`, con la misma simulación y confirmación.
- Ejecutar un pipeline para validar un cambio o cargar datos, y esperar a su resultado: `ejecutar_fabric.py "<Pipeline>"`, primero en simulación y después con `--confirmar`, con la confirmación explícita de la persona en ese momento.
- Leer datos del lakehouse para validar o analizar: `consultar_sql.py`.
- Validar los ficheros de Grupo de Ageing o Revenue antes de darlos por buenos: `validar_ficheros_grupo.py ageing` o `validar_ficheros_grupo.py revenue`. Para contrastar la vista de Fabric con los TXT de marzo: `validar_ficheros_grupo.py ageing --vista`. El código de salida indica si las cifras de control cuadran.
- Actualizar el anexo de pendientes de la auditoría tras cambiar el registro de reuniones, la documentación de riesgos o las preguntas: `anexo_pendientes.py` sobre el fichero de auditoría. Volver a ejecutarlo deja el mismo resultado.
- Entregar un documento del proyecto en Word con el formato de Docenteo: `md_a_docx.py ENTRADA.md SALIDA.docx`, con título y, si procede, subtítulo y antetítulo. Después conviene revisar el resultado con el verificador de la skill de diseño.

## Qué escribe y qué no

- `exportar_fabric.py` y `consultar_sql.py` no escriben en Fabric. Solo listan items, piden definiciones y ejecutan SELECT.
- `publicar_fabric.py` y `ejecutar_fabric.py` son los únicos que escriben en Fabric, y solo con `--confirmar`. `publicar_fabric.py` actualiza items existentes, crea items nuevos solo con `--crear` y publica vistas SQL; nunca borra items ni vistas. `ejecutar_fabric.py` lanza un pipeline, que puede escribir datos en el lakehouse según lo que haga. No publica las User Data Functions, porque su código lleva un secreto incrustado.
- `validar_ficheros_grupo.py` consulta Fabric en solo lectura y no escribe ningún fichero. Muestra por consola las diferencias.
- `anexo_pendientes.py` solo modifica el fichero de auditoría que recibe como argumento, y solo el bloque del anexo.
- `md_a_docx.py` genera un nuevo `.docx` en la ruta de salida y no modifica el Markdown de entrada.
- Los scripts no imprimen tokens ni los escriben en ficheros.

## Por qué no hay domain-model ni data-model

Esta unidad no define entidades, esquemas ni modelos propios. Manipula definiciones ya existentes del workspace (TMDL, PBIR, dataflows, pipelines, notebooks, vistas SQL) tratándolas como texto. El modelo de datos vive en los items de Fabric y en la copia de `reporting-financiero/fabric/`, no en el código de estos scripts. Por eso no se documentan secciones `domain-model` ni `data-model` en este vault.

## Flujos de cambio

- Flujo A (cambio en el portal de Fabric): exportar, commit en `reporting-financiero`, merge `--no-ff` en `main`; `exportar_fabric.py --comprobar main` debe dar 0.
- Flujo B (cambio commiteado en el repo): commit en la rama de trabajo, simular con `publicar_fabric.py "<Item>" --ref <rama>` (con `--crear` si el item es nuevo), publicar con `--confirmar` solo con confirmación explícita de la persona, item a item; ejecutar el pipeline con `ejecutar_fabric.py` si hace falta, con la misma confirmación; validar en Fabric, exportar, commit, merge en `main` y comprobar.
- Rollback: localizar el commit con `git log` del item, simular con `--ref <commit>`, publicar con `--confirmar`, validar, exportar y commit `revert(fabric): ...`.

Procedimiento completo en `reporting-financiero/docs/flujo-fabric.md`. Tests: `test_fabric_comun.py`, `test_publicar_vistas.py`, `test_crear_items.py`, `test_ejecutar_fabric.py` y `test_exportar_fabric.py` (unitarios, sin conexión) y `test_fabric_e2e.py` (solo lectura, con `FABRIC_E2E=1`). Detalle en [[repos/rf-scripts/quality]].

## Open questions

- Ninguna en este documento. Los TBD de la unidad están en [[repos/rf-scripts/integrations]] y [[repos/rf-scripts/quality]].

## Evidence

- `fabric_comun.py` - constantes de workspace, cuenta y endpoint SQL, formatos exportables, items de sistema excluidos (`es_exportable`), exclusiones y lista de sentencias de escritura.
- `exportar_fabric.py#descargar_todo` - descarga de items exportables, vistas y esquema, sin escritura en Fabric.
- `exportar_fabric.py#carpetas_solo` - opción `--solo`: exportación o comparación de items concretos, con `lakehouse` para vistas y esquema.
- `exportar_fabric.py#exportar` - regeneración de `fabric/`, completa o solo de las carpetas indicadas.
- `publicar_fabric.py#main` - simulación por defecto, comprobación contra la base, publicación de vistas, creación con `--crear` y publicación con `--confirmar`.
- `ejecutar_fabric.py#main` - simulación por defecto, lanzamiento con `--confirmar` y espera del job.
- `consultar_sql.py#main` - validación de solo lectura y salida en CSV dentro de `data/`.
- `validar_ficheros_grupo.py#validar_ageing` y `validar_ficheros_grupo.py#validar_revenue` - reproducción de los ficheros de Grupo y comparación con los TXT de Magnitude de marzo de 2026.
- `validar_ficheros_grupo.py#validar_vista_ageing` - modo `--vista`: comparación de la vista de Fabric con los TXT de marzo.
- `validar_ficheros_grupo.py#main` - argumentos, comprobación de la carpeta de fuentes y de la cuenta, códigos de salida.
- `anexo_pendientes.py#generar` - construcción del anexo a partir de la tabla de conceptos y de sus fuentes.
- `anexo_pendientes.py#main` - escritura del anexo entre las marcas del fichero de auditoría.
- `md_a_docx.py` - conversión de Markdown a Word con los estilos de la plantilla de Docenteo, búsqueda de la plantilla y convenciones del Markdown de entrada.
