---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, power-bi]
---

# Power BI (modelos semánticos e informes en Fabric)

**Responsabilidad:** plataforma de modelos semánticos e informes de Power BI dentro de Fabric. Contiene el modelo Financial Model (Direct Lake), el modelo Agings (import), seis informes y dos temas de color mantenidos a mano.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - modelos en TMDL (`reporting-financiero/fabric/Financial Model.SemanticModel/definition/expressions.tmdl`, `reporting-financiero/fabric/Agings.SemanticModel/definition.pbism`); informes en PBIR conectados al modelo publicado por referencia `byConnection` (`reporting-financiero/fabric/Agings.Report/definition.pbir`); temas (`reporting-financiero/fabric/temas/TemaPBI.json`); refresco de modelos en los pipelines `Refresco_modelos` (`reporting-financiero/fabric/Refresco_modelos.DataPipeline/pipeline-content.json`) y `Generar Reporting` (`reporting-financiero/fabric/Generar Reporting.DataPipeline/pipeline-content.json`)
- [[repos/rf-scripts/README|rf-scripts]] - descarga y publica definiciones de modelos en TMDL e informes en PBIR a través de la API de Fabric (`reporting-financiero/scripts/fabric_comun.py#descargar_definicion`, `reporting-financiero/scripts/fabric_comun.py#partes_para_publicar`; `reporting-financiero/scripts/exportar_fabric.py`)

## Integration surface

- **Access**: modelos definidos en TMDL con medidas DAX; informes en PBIR. Financial Model usa Direct Lake sobre el lakehouse; Agings usa import desde el SQL endpoint.
- **Auth**: permisos del workspace de Fabric. El repositorio no contiene configuración de credenciales (TBD).

## Notes

- Financial Model no tiene roles RLS ni OLS; hay que revisar esto antes de ampliar la audiencia de sus informes.
- `Refresco_modelos` refresca los dos modelos sin dependencia previa; `Generar Reporting` los refresca al final con condición Completed, de modo que el refresco puede ejecutarse aunque falle la carga previa.
- Agings necesita una conexión explícita en la nube para refrescarse: sin ella, el refresco falla (Premium_ASWL_Error). Arreglado el 04/11/2026 (`reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`).
- El calendario de Agings cubre 2026 y 2027 de forma fija; al terminar esos años, sus tablas snapshot dejan de tener fechas de corte.
