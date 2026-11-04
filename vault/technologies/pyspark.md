---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, pyspark]
---

# PySpark (notebooks Spark en Fabric)

**Responsabilidad:** runtime Spark de Fabric para notebooks en PySpark. El único notebook, Generar_txt_Balance_Saldos, lee dos vistas de exportación del esquema 300 del lakehouse y escribe ficheros TXT en Files.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - notebook en `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb`, ejecutado como actividad de `reporting-financiero/fabric/Generar_salidas.DataPipeline/pipeline-content.json` (con los parámetros `ficheros` y `periodo_esperado`) y, en el pipeline anterior, como actividad 1 de `reporting-financiero/fabric/Grabar salidas.DataPipeline/pipeline-content.json` (sin parámetros). `Flujo_total_txt` lanza `Generar_salidas` sin parámetros (`reporting-financiero/fabric/Flujo_total_txt.DataPipeline/pipeline-content.json`)
- [[repos/rf-scripts/README|rf-scripts]] - descarga y publica la definición del notebook en formato ipynb (`reporting-financiero/scripts/fabric_comun.py#descargar_definicion`)

## Integration surface

- **Access**: notebook PySpark ejecutado por pipeline dentro del workspace; lee las vistas del lakehouse y escribe en su zona Files.
- **Auth**: identidad del propio item dentro de Fabric. No se documenta en el repositorio (TBD).

## Notes

- Parámetros de la celda inicial: `ficheros` (vacío significa Balance y Saldos_4_7) y `periodo_esperado` (AAAA.MM; vacío significa no comprobar). Antes de escribir, el notebook comprueba que el periodo cargado en las vistas coincide con `periodo_esperado`; si no coincide, falla sin generar ficheros.
- Vistas que lee: `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` (`ESQUEMA = "300"` en el código). Antes leía las del esquema 200.
- En Saldos 4_7 redondea el saldo a 2 decimales antes de decidir si va a debe o a haber, para que el mismo dato dé siempre el mismo TXT.
- El mapeo de sociedades está fijo en el código del notebook; una sociedad nueva quedaría fuera sin aviso explícito.
- Salida: un fichero TXT por sociedad y periodo en la carpeta de exportaciones de balance (`Exportaciones/Balance`), con separador punto y coma en el balance.
- TBD: versión del runtime Spark de Fabric.
