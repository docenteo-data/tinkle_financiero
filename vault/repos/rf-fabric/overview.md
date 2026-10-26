---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*/.platform"]
tags: [rf-fabric, overview]
---

# rf-fabric - Overview

> Cuándo cargar: necesitas saber qué items de Fabric hay en el workspace "Tinkle - Financiero", de qué tipo son, qué hay fuera de los items o cómo se regenera la copia en texto.

## Qué es

`fabric/` es la copia en texto del workspace "Tinkle - Financiero" de Microsoft Fabric, del cliente Tinkle. Las definiciones se exportan por API y se guardan en el repositorio `reporting-financiero`. La rama `main` refleja lo publicado en el workspace y esta carpeta es su espejo versionado.

El objetivo del proyecto es sustituir el reporting financiero basado en Excel (Oracle, Portugal, HAPA, MMS y auxiliares) por un modelo central en Fabric con informes en Power BI. Por fases:

- Fase 1: P&L, balance, P&L por centro de coste y por directora, y ficheros de Grupo.
- Fase 2: presupuesto y desviaciones.
- Fase 3: rentabilidad, aging y periodo medio de pago.

## Inventario de items (21 en la raíz)

Cada carpeta `<Nombre>.<Tipo>/` contiene un fichero `.platform` con el tipo y el nombre visible del item.

- Modelos semánticos (2): Agings, Financial Model. Exportados en TMDL.
- Informes (6): Agings, Checklist (Oracle), HAPA, MMS, Presupuesto, Rentabilidad. Exportados en PBIR.
- Dataflows (10):
  - Ingesta: INGESTA_Carga_Datos, INGESTA_Maestros.
  - Cargas iniciales: INICIAL_Carga_Agings, INICIAL_Carga_Oracle, INICIAL_Carga_Rentabilidades, INICIAL_Carga_Revenues, INICIAL_Carga_budget_fct.
  - Transformación: TRANS_Silver, TRANS_Gold.
  - Seguridad: Seguridad_CDC.
- Pipelines de datos (2): Generar Reporting, Grabar salidas.
- Notebook (1): Generar_txt_Balance_Saldos.

El detalle funcional de cada item no se deduce de su nombre ni del `.platform`.

## Fuera de los items

- `sql/`: tres vistas del SQL endpoint del lakehouse, con nombre `<esquema>.<vista>.sql`. Son `200.vw_Export_Grupo`, `200.vw_Export_Saldos_4_7` y `300.vw_Reporting_Actuals`. El prefijo numérico indica la capa.
- `lakehouse/`: `esquema.tsv`, el esquema de columnas de las capas 100, 200 y 300.
- `temas/`: dos temas de Power BI, `TemaPBI.json` y `TemaTinkle.json`. Se mantienen a mano, no se exportan.

## Cómo se regenera

- Exportación: `reporting-financiero/scripts/exportar_fabric.py` trae las definiciones a `fabric/`. Con `--comprobar main` compara la copia con `main` sin escribir en Fabric.
- Flujo de cambio, validación de cuenta y rollback: `reporting-financiero/docs/flujo-fabric.md`.

## Open questions

- Función de cada pipeline, dataflow y notebook: ver [[architecture]].
- Significado de las capas 100, 200 y 300: ver [[architecture]] y [[data-model]].
- TBD: no verificado que la copia siga alineada con `main` en el commit fb5c2b5.

## Evidence

- `*/.platform` (21 carpetas de item): tipo y nombre visible de cada item.
- `sql/200.vw_Export_Grupo.sql`, `sql/200.vw_Export_Saldos_4_7.sql`, `sql/300.vw_Reporting_Actuals.sql`: nombres de las vistas. No se resume su contenido.
- `lakehouse/esquema.tsv`: existencia y alcance del esquema de columnas.
- `temas/TemaPBI.json`, `temas/TemaTinkle.json`: nombres de los temas.
- `reporting-financiero/README.md` (sección "Fabric" y tabla de carpetas): estructura de `fabric/`, formatos TMDL y PBIR, script de exportación y contexto de fases.
