---
type: infrastructure
load_tier: 2
schema_version: 1
tags: [infrastructure, sharepoint-online]
---

# SharePoint Online (y OneDrive de origen)

**Responsabilidad:** almacenamiento documental de Microsoft 365 que actúa como almacén de objetos externo: origen de los ficheros Excel y CSV de entrada (a través de un shortcut desde el lakehouse) y destino de los TXT de balance y saldos.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - origen: la carpeta Reporting Financiero de Files del lakehouse es un shortcut a OneDrive o SharePoint, con las subcarpetas Arranque, Dinamicos y Maestros (`reporting-financiero/fabric/INGESTA_Carga_Datos.Dataflow/mashup.pq`, `reporting-financiero/fabric/INICIAL_Carga_Agings.Dataflow/mashup.pq`); destino: la actividad Copy del pipeline copia los TXT a la biblioteca Shared Documents (`reporting-financiero/fabric/Grabar salidas.DataPipeline/pipeline-content.json`)
- [[repos/rf-scripts/README|rf-scripts]] - lectura local, sin API: `validar_ficheros_grupo.py` lee la carpeta `3.Fuentes` del proyecto en el SharePoint de Docenteo (biblioteca DOCENTEO - General, sincronizada en el equipo por OneDrive), con los TXT de Magnitude de marzo de 2026, el aging de clientes y el libro Revenue 2026 FT3 (`reporting-financiero/scripts/validar_ficheros_grupo.py#FUENTES`). Es un sitio distinto del de entrada y salida de Fabric.

## Configuration & deployment

- **How it is deployed**: servicio gestionado de Microsoft 365; el repositorio no define su configuración.
- **Key settings**: biblioteca Shared Documents, con la carpeta de salida de balance dentro de Reporting Financiero. El filtro de la copia es *.txt bajo la carpeta de exportaciones de balance, preservando la jerarquía. No se documentan aquí URLs ni identificadores de sitio.
- **Auth**: TBD. La cuenta y el mecanismo de la conexión del shortcut y de la actividad Copy no están en el repositorio.

## Notes

- TBD: sitio, biblioteca y cuenta exactos del shortcut de entrada (OneDrive personal o SharePoint).
- El filtro *.txt de la copia recoge también los saldos 4_7, aunque la carpeta de destino se llame Balance.
- Los ficheros de entrada son datos del cliente y no forman parte del repositorio.
