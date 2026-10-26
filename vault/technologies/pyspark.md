---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, pyspark]
---

# PySpark (notebooks Spark en Fabric)

**Responsabilidad:** runtime Spark de Fabric para notebooks en PySpark. El único notebook, Generar_txt_Balance_Saldos, lee dos vistas del lakehouse y escribe ficheros TXT en Files.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - notebook en `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb`, ejecutado como actividad 1 de `reporting-financiero/fabric/Grabar salidas.DataPipeline/pipeline-content.json`
- [[repos/rf-scripts/README|rf-scripts]] - descarga y publica la definición del notebook en formato ipynb (`reporting-financiero/scripts/fabric_comun.py#descargar_definicion`)

## Integration surface

- **Access**: notebook PySpark ejecutado por pipeline dentro del workspace; lee vistas del lakehouse y escribe en su zona Files.
- **Auth**: identidad del propio item dentro de Fabric. No se documenta en el repositorio (TBD).

## Notes

- El mapeo de sociedades está fijo en el código del notebook; una sociedad nueva quedaría fuera sin aviso explícito.
- Salida: un fichero TXT por sociedad y periodo en la carpeta de exportaciones de balance, con separador punto y coma en el balance.
- TBD: versión del runtime Spark de Fabric.
