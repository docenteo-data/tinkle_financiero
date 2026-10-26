---
type: repo-card
load_tier: 1
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
tags: [rf-scripts, repo-card]
---

# rf-scripts - Repo Card

> Resumen tier 1. Cárgalo primero para cualquier tarea sobre los scripts de Fabric de Tinkle.

- **Propósito**: scripts Python para exportar, comprobar, publicar y consultar el workspace de Fabric de Tinkle. El repo `main` refleja lo publicado en Fabric, y su copia en texto está en `reporting-financiero/fabric/`. No define entidades propias: manipula definiciones de items (TMDL, PBIR, dataflows, pipelines, notebooks, vistas SQL). Solo publica cuando se le pide.
- **Stack**: Python en el entorno `.venv` de `reporting-financiero`. Biblioteca estándar, más mssql-python para el SQL endpoint.
- **Puntos de entrada y cuándo usar cada uno**:
  - `exportar_fabric.py`: sin argumentos, regenera `fabric/` desde Fabric. Con `--comprobar [REF]` (por defecto `main`) solo compara y dice si Fabric coincide con ese commit. Úsalo para comprobar sincronía o traer cambios al repo.
  - `publicar_fabric.py`: publica en Fabric la definición de uno o más items tal como está en un commit. Úsalo para publicar un cambio ya commiteado o hacer rollback. Sin `--confirmar` solo simula.
  - `consultar_sql.py`: consulta de solo lectura al SQL endpoint del lakehouse, para validar o analizar datos. Acepta solo sentencias SELECT o WITH. Con `--csv` escribe en `reporting-financiero/data/`, que no se versiona.
  - `fabric_comun.py`: módulo compartido. No es punto de entrada.
- **Qué escribe en Fabric**: solo `publicar_fabric.py`, y solo con `--confirmar`. Actualiza items que ya existen; no crea ni borra items. No publica User Data Functions, porque su código lleva un secreto incrustado. `exportar_fabric.py` y `consultar_sql.py` no escriben en Fabric. Ningún script imprime ni guarda tokens.
- **Escrituras locales**: `exportar_fabric.py` sin argumentos borra y reescribe `fabric/` entera, salvo `temas/`.
- **Integraciones**: API REST de Fabric (listar, leer y actualizar definiciones, con operaciones asíncronas); Azure CLI (pide un token en cada ejecución); SQL endpoint del lakehouse con mssql-python; git local con `git archive`, sin checkout.
- **Códigos de salida**:
  - exportar: 0 exportado o coincide; 1 solo con `--comprobar`, hay diferencias; 2 cuenta incorrecta o item o vistas no leídos.
  - publicar: 0 publicado o simulación correcta; 1 Fabric no coincide con `--base` (salvo `--forzar`); 2 tipo no publicable, item inexistente o ausente en `--ref`, error de lectura o publicación, o cuenta incorrecta.
  - consultar: 0 correcta; 1 error de la consulta en el servidor; 2 sentencia no permitida, CSV fuera de `data/`, sin sentencia o cuenta incorrecta.
  - Un fallo de Azure CLI o de git sale con código 2.
- **Requisitos**:
  - Cuenta por defecto de Azure CLI la de Tinkle. Compruébala con la cuenta activa; si no coincide, el script sale con código 2.
  - Entorno `.venv` de `reporting-financiero` con Python 3.14 y las dependencias de `reporting-financiero/requirements.txt`: mssql-python 1.16.0 y pytest 9.1.1.
  - Ejecutar desde la raíz del repo con el Python del `.venv`.
  - La salida va en ASCII, porque la consola de Windows es cp1252.
- **Procedimiento completo**: `reporting-financiero/docs/flujo-fabric.md` (lectura, consulta, publicación, validación de cuenta, flujos de cambio y rollback). Detalle del repo: [[repos/rf-scripts/README]].

## Common pitfalls

- Publicar con `--forzar` descarta los cambios que haya en Fabric y no están en `--base`.
- La publicación real no se prueba: el workspace del cliente no tiene entorno de pruebas. Los tests cubren funciones puras y la salida con código 2 ante fallos de Azure CLI o git; la simulación de `publicar_fabric.py` no tiene test.
- El filtro de `consultar_sql.py` es por palabras clave, no un analizador SQL. TBD: confirmar que los permisos de la conexión son de solo lectura.
- No hay workspace de pruebas: es el único entorno del cliente. Una publicación se valida así: una persona refresca o ejecuta en Fabric y comprueba las cifras de control; después se exporta, se revisa `git diff` y `exportar_fabric.py --comprobar main` debe dar 0.
- La sesión se inicia una vez con `az login`, y otra vez si caduca. Después se fija la cuenta con `az account set --subscription <TENANT_ID>` y se comprueba con `az account show`.
- TBD: versión mínima de Azure CLI.
- El E2E (`FABRIC_E2E=1`) solo lee de Fabric, pero necesita sesión de Azure CLI en la cuenta de Tinkle.
