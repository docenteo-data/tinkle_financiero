---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
source_globs: ["fabric_comun.py"]
tags: [rf-scripts, configuration]
---

# rf-scripts - Configuration

> Cuándo cargar: necesitas preparar el entorno Python o la sesión de Azure CLI, o saber qué representa cada constante de `fabric_comun.py`.

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

## Entorno Python

- Versión: Python 3.14.7, la del `.venv` (`pyvenv.cfg`).
- Crear el entorno desde la raíz del repositorio con `python -m venv reporting-financiero/.venv`.
- Instalar dependencias con `reporting-financiero/.venv/Scripts/python.exe -m pip install -r reporting-financiero/requirements.txt`.
- Dependencias fijadas: `mssql-python` 1.16.0 (SQL) y `pytest` 9.1.1 (tests).
- Ejecutar siempre desde la raíz con `reporting-financiero/.venv/Scripts/python.exe`.
- Tests: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests`. Con `FABRIC_E2E=1` se ejecutan también los de solo lectura contra Fabric.

## Azure CLI

- Requisito: la cuenta por defecto de Azure CLI debe ser la de Tinkle (`CUENTA`, en el tenant de `TENANT_ID`). Si el tenant de la cuenta activa no es `TENANT_ID`, el script para con código 2 y sugiere `az account set`. Solo se compara el tenant, no el usuario.
- Los scripts no guardan ni imprimen tokens: los piden a Azure CLI en cada ejecución.
- Comprobar la cuenta activa con `az account show`.

## Datos locales

- Los CSV de datos del cliente van en `reporting-financiero/data/`, excluida de git por la regla `*/data/` de `.gitignore` de la raíz.

## Atributos de git

- `.gitattributes` de la raíz fija `reporting-financiero/fabric/**` con `-text`: los bytes se guardan sin conversión de finales de línea, para que la comparación con Fabric y la publicación (rollback) sean fieles.

## Salida por consola

- La salida de los scripts va en ASCII, porque la consola de Windows es cp1252.

## Evidence

- `reporting-financiero/scripts/fabric_comun.py#WORKSPACE_ID`, `#TENANT_ID`, `#CUENTA`, `#API`, `#SQL_SERVIDOR`, `#SQL_BASE_DATOS`, `#RAIZ_REPO`, `#CARPETA_FABRIC` - constantes de conexión.
- `reporting-financiero/scripts/fabric_comun.py` (cabecera de módulo) - tokens pedidos a Azure CLI y salida ASCII.
- `reporting-financiero/requirements.txt` - versiones fijadas.
- `reporting-financiero/.venv/pyvenv.cfg` - versión de Python del entorno.
- `reporting-financiero/docs/flujo-fabric.md` (sección "Entorno") - comandos de creación del entorno, instalación y tests.
- `.gitattributes` (raíz) - regla `reporting-financiero/fabric/**`.
- `.gitignore` (raíz) - regla `*/data/`.

## Open questions

- TBD: versión mínima de Azure CLI requerida; no aparece en las fuentes de esta sección.
- La sesión se inicia una vez con `az login`, y otra vez si caduca. Después se fija la cuenta con `az account set --subscription <TENANT_ID>` y se comprueba con `az account show`.
