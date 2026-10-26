---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, power-query-m]
---

# Power Query (lenguaje M en dataflows Gen2)

**Responsabilidad:** lenguaje M de Power Query, con el que se escriben las consultas de los 10 dataflows Gen2: ingesta de Excel y CSV, cargas iniciales, transformación entre capas y la tabla de seguridad.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - consultas en `reporting-financiero/fabric/INGESTA_Carga_Datos.Dataflow/mashup.pq`, `reporting-financiero/fabric/INGESTA_Maestros.Dataflow/mashup.pq`, `reporting-financiero/fabric/INICIAL_Carga_Agings.Dataflow/mashup.pq`, `reporting-financiero/fabric/TRANS_Silver.Dataflow/mashup.pq` y `reporting-financiero/fabric/Seguridad_CDC.Dataflow/mashup.pq`
- [[repos/rf-scripts/README|rf-scripts]] - descarga la definición de los dataflows sin pedir formato explícito en la consulta (`reporting-financiero/scripts/fabric_comun.py#descargar_definicion`)

## Integration surface

- **Access**: consultas M dentro de la definición de cada dataflow. No hay SDK externo.
- **Auth**: credenciales de las conexiones de origen y destino. No se documentan en el repositorio (TBD).

## Notes

- Las fuentes son Excel, CSV y tablas del lakehouse. Algunos ficheros se localizan por texto de su nombre en lugar de por nombre fijo.
- Seguridad_CDC no tiene origen: la tabla de seguridad es un valor literal que se escribe en el esquema 100.
- Ningún dataflow tiene programación en la definición exportada.
