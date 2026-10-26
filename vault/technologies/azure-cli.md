---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, azure-cli]
---

# Azure CLI

**Responsabilidad:** herramienta de línea de comandos de Azure instalada en el equipo que ejecuta los scripts. Es el proveedor de tokens y de la cuenta activa; los scripts no tienen credenciales propias.

## Repos that use it

- [[repos/rf-scripts/README|rf-scripts]] - invocada como proceso local para obtener tokens, leer la cuenta activa y validar el tenant (`reporting-financiero/scripts/fabric_comun.py#_az`, `reporting-financiero/scripts/fabric_comun.py#comprobar_cuenta`, `reporting-financiero/scripts/fabric_comun.py#token`); `reporting-financiero/scripts/consultar_sql.py#main` termina con código 2 si falla

## Integration surface

- **Access**: proceso local invocado desde Python. No se usa ningún SDK.
- **Auth**: sesión de usuario creada con `az login`. La cuenta por defecto debe pertenecer al tenant de Tinkle; si no, se corrige con `az account set`.

## Notes

- Si `az` falla, el script termina con código 2 e indica que hay que ejecutar `az login`.
- Los tokens no se guardan en disco ni se imprimen; cada ejecución pide uno nuevo.
- TBD: versión mínima de Azure CLI requerida.
