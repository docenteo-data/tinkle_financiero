---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, microsoft-entra-id]
---

# Microsoft Entra ID (tenant de Tinkle)

**Responsabilidad:** proveedor de identidad del tenant de Tinkle. Autentica la cuenta de Azure CLI con la que los scripts obtienen tokens para la API de Fabric y para el SQL endpoint del lakehouse.

## Repos that use it

- [[repos/rf-scripts/README|rf-scripts]] - comprueba que la cuenta activa pertenece al tenant de Tinkle y pide tokens para el recurso de Fabric y para el de bases de datos (`reporting-financiero/scripts/fabric_comun.py#TENANT_ID`, `reporting-financiero/scripts/fabric_comun.py#comprobar_cuenta`, `reporting-financiero/scripts/fabric_comun.py#token`)

## Configuration & deployment

- **How it is deployed**: servicio gestionado de Microsoft; el repositorio no lo despliega.
- **Key settings**: identificador del tenant en `reporting-financiero/scripts/fabric_comun.py`, no copiado aquí. La comprobación compara solo el tenant, no el usuario.
- **Auth**: sesión interactiva de Azure CLI (`az login`), con caducidad. Los scripts piden un token en cada ejecución y no lo guardan ni lo imprimen.

## Notes

- En `rf-fabric` no se evidencia consumo directo de Entra por parte de los items; la autenticación de sus conexiones (shortcut, dataflows y Copy) no figura en el repositorio (TBD).
- TBD: políticas de acceso condicional y MFA aplicables a la cuenta de reporting.
