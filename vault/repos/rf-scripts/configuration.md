---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 0ad7fdb
last_sync: 2026-11-03T15:00:00Z
stack: python
source_globs: ["fabric_comun.py", "validar_ficheros_grupo.py", "anexo_pendientes.py", "md_a_docx.py"]
tags: [rf-scripts, configuration]
---

# rf-scripts - Configuration

> Cuándo cargar: necesitas preparar el entorno Python o la sesión de Azure CLI, saber qué representa cada constante de `fabric_comun.py`, o conocer las rutas y opciones por defecto de los scripts de validación, anexo y Word.

## Constantes de conexión

`reporting-financiero/scripts/fabric_comun.py` agrupa en un único bloque las constantes comunes a los scripts de Fabric. Sus valores no se documentan aquí; se leen del fichero.

- `WORKSPACE_ID`: workspace de Fabric "Tinkle - Financiero".
- `TENANT_ID`: tenant de Microsoft Entra de Tinkle.
- `CUENTA`: cuenta de Azure CLI esperada; es solo informativa, ningún script la usa.
- `API`: URL base de la API REST de Fabric.
- `SQL_SERVIDOR`: servidor del punto de conexión SQL del workspace.
- `SQL_BASE_DATOS`: base de datos SQL (lakehouse) de las consultas.
- `RAIZ_REPO`: raíz del repositorio, calculada a partir de la ubicación del fichero.
- `CARPETA_FABRIC`: carpeta relativa a la raíz donde vive la copia exportada de Fabric.
- `ITEMS_DE_SISTEMA`: nombres de los items que Power BI crea solo al abrir las métricas de uso de un informe. No son parte de la solución y la API no permite exportarlos, así que `es_exportable` los descarta.

## Entorno Python

- Versión: Python 3.14.7, la del `.venv` (`pyvenv.cfg`).
- Crear el entorno desde la raíz del repositorio con `python -m venv reporting-financiero/.venv`.
- Instalar dependencias con `reporting-financiero/.venv/Scripts/python.exe -m pip install -r reporting-financiero/requirements.txt`.
- Dependencias fijadas en `requirements.txt`: `mssql-python` 1.16.0 (SQL), `openpyxl` 3.1.5 (lectura de los Excel de Grupo en `validar_ficheros_grupo.py`) y `pytest` 9.1.1 (tests).
- Ejecutar siempre desde la raíz con `reporting-financiero/.venv/Scripts/python.exe`.
- Tests: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests`.
- Variable de entorno `FABRIC_E2E=1`: activa los tests de solo lectura contra Fabric. Sin ella, se omiten. Afecta a `test_fabric_e2e.py` (sincronía de `main` y consultas SQL) y a `test_validar_ficheros_grupo_e2e.py`.
- `test_validar_ficheros_grupo_e2e.py` exige además Azure CLI en la cuenta de Tinkle y la carpeta `3.Fuentes` sincronizada; si esta última no existe, el test se omite.

## Azure CLI

- Requisito: la cuenta por defecto de Azure CLI debe ser la de Tinkle (`CUENTA`, en el tenant de `TENANT_ID`). Si el tenant de la cuenta activa no es `TENANT_ID`, el script para con código 2 y sugiere `az account set`. Solo se compara el tenant, no el usuario.
- Los scripts no guardan ni imprimen tokens: los piden a Azure CLI en cada ejecución.
- Comprobar la cuenta activa con `az account show`.

## Rutas y opciones por defecto

- `validar_ficheros_grupo.py`: lee la carpeta `3.Fuentes` de OneDrive, en `OneDrive - Docenteo/DOCENTEO - General/02.Clientes/04.Tinkle/Reporting financiero/3.Fuentes` dentro del perfil del usuario. Otra ruta se indica con `--fuentes`. La carpeta debe contener la subcarpeta de TXT de marzo; si no, sale con código 2.
- `validar_ficheros_grupo.py`: el argumento posicional elige el fichero a validar (`ageing` o `revenue`). Códigos de salida: 0 las cifras de control cuadran, 1 no cuadran, 2 problemas de cuenta o de ficheros.
- `validar_ficheros_grupo.py --vista` (solo `ageing`): valida la vista `300.vw_Export_Ageing` de Fabric contra los TXT de marzo. Solo necesita la carpeta de TXT de `3.Fuentes`; no usa los Excel de aging ni de Revenue FT3. El módulo importa `openpyxl` igualmente al cargarse, así que la dependencia sigue siendo necesaria.
- `validar_ficheros_grupo.py`: constantes `CORTE` (31-03-2026, fecha de corte del aging) y `TOLERANCIA_SOCIEDAD` (0.05, desviación admitida por sociedad en Revenue por el redondeo a 2 decimales de cada línea).
- `anexo_pendientes.py`: lee fuentes fijas dentro del repositorio: el registro de reuniones (`docs/reuniones/README.md`), la sección técnica (`docs/contexto/Documentacion_Tinkle_Financiero.md`) y las preguntas (`docs/contexto/PREGUNTAS_PARA_TINKLE.md`). Recibe como argumento el fichero de auditoría y escribe el anexo entre las marcas `<!-- anexo:inicio -->` y `<!-- anexo:fin -->`, que añade al final si no existen.
- `md_a_docx.py`: usa la plantilla `docenteo-documento.dotx` de la skill docenteo-design. Por defecto la busca en la versión más alta instalada del plugin docenteo-skills, bajo el perfil del usuario. Si no la encuentra, sale con código 2. La opción `--plantilla` indica otra ruta. Solo usa los estilos de la plantilla.

## Datos locales

- Los CSV de datos del cliente van en `reporting-financiero/data/`, excluida de git por la regla `*/data/` de `.gitignore` de la raíz.

## Atributos de git

- `.gitattributes` de la raíz fija `reporting-financiero/fabric/**` con `-text`: los bytes se guardan sin conversión de finales de línea, para que la comparación con Fabric y la publicación (rollback) sean fieles.

## Salida por consola

- La salida de los scripts va en ASCII, porque la consola de Windows es cp1252.

## Evidence

- `reporting-financiero/scripts/fabric_comun.py#WORKSPACE_ID`, `#TENANT_ID`, `#CUENTA`, `#API`, `#SQL_SERVIDOR`, `#SQL_BASE_DATOS`, `#RAIZ_REPO`, `#CARPETA_FABRIC` - constantes de conexión.
- `reporting-financiero/scripts/fabric_comun.py#ITEMS_DE_SISTEMA`, `#es_exportable` - exclusión de items de sistema en la exportación.
- `reporting-financiero/scripts/fabric_comun.py` (cabecera de módulo) - tokens pedidos a Azure CLI y salida ASCII.
- `reporting-financiero/scripts/validar_ficheros_grupo.py#FUENTES`, `#CORTE`, `#TOLERANCIA_SOCIEDAD`, `#main` - carpeta por defecto, constantes, opción `--fuentes`, opción `--vista` y códigos de salida.
- `reporting-financiero/scripts/validar_ficheros_grupo.py#validar_vista_ageing`, `#leer_ageing_marzo` - modo `--vista` y lectura de los TXT sin Excel.
- `reporting-financiero/scripts/anexo_pendientes.py#REGISTRO`, `#TECNICA`, `#PREGUNTAS`, `#INICIO`, `#FIN` - fuentes y marcas del anexo.
- `reporting-financiero/scripts/md_a_docx.py#plantilla_por_defecto` - búsqueda de la plantilla y opción `--plantilla`.
- `reporting-financiero/tests/test_fabric_e2e.py` y `reporting-financiero/tests/test_validar_ficheros_grupo_e2e.py` - condiciones de los tests E2E.
- `reporting-financiero/requirements.txt` - versiones fijadas.
- `reporting-financiero/.venv/pyvenv.cfg` - versión de Python del entorno.
- `reporting-financiero/docs/flujo-fabric.md` (sección "Entorno") - comandos de creación del entorno, instalación y tests.
- `.gitattributes` (raíz) - regla `reporting-financiero/fabric/**`.
- `.gitignore` (raíz) - regla `*/data/`.

## Open questions

- TBD: versión mínima de Azure CLI requerida; no aparece en las fuentes de esta sección.
- La sesión se inicia una vez con `az login`, y otra vez si caduca. Después se fija la cuenta con `az account set --subscription <TENANT_ID>` y se comprueba con `az account show`.
