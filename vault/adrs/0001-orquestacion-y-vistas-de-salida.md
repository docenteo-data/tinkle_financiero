---
type: adr
load_tier: 3
schema_version: 1
status: propuesta
date: 2026-11-04
tags: [rf-fabric, orquestacion, adr]
---

# ADR 0001 - Pipelines modulares, flujos y vistas de salida

> Cuándo cargar: vas a cambiar los pipelines, las UDF, los botones de los informes o las vistas de exportación de rf-fabric, o a dibujar la orquestación "propuesta".

## Contexto

Hechos de partida en [[repos/rf-fabric/architecture]] y [[repos/rf-fabric/lineage]]:

- Las vistas de los ficheros de Grupo (`vw_Export_Grupo` y `vw_Export_Saldos_4_7`) están en el esquema 200 y leen solo tablas del 300. La vista de reporting (`vw_Reporting_Actuals`) está en el 300.
- "Generar Reporting" hace en un solo pipeline la ingesta, la transformación (silver y gold), el endpoint SQL y el refresco de los modelos. "Grabar salidas" genera y copia los TXT. Nada los encadena (riesgo O2) y no se puede probar ni relanzar un paso suelto.
- Los dos refrescos de modelos se ejecutan con la condición Completed, también si falla la capa gold. INGESTA_Maestros no está en ningún pipeline.
- Botones en la página Home de los informes Agings, Checklist (Oracle), HAPA, MMS y Presupuesto: "Cargar datos" o "Actualizar datos" llaman a la UDF `Ejecución Reporting` (lanza "Generar Reporting"); "Generar txt" llama a la UDF `Generar_txt` (lanza "Grabar salidas"). Las UDF solo comprueban que el job se ha encolado.
- Las UDF llevan un secreto incrustado (riesgo S1) y por eso no se versionan.
- El notebook de ficheros lee vistas sobre tablas del 300, no los modelos semánticos: los ficheros no dependen del refresco de modelos.

## Decisión

1. Vistas de salida en el esquema 300, junto a `vw_Reporting_Actuals`. Las del 200 se borran cuando las nuevas devuelvan lo mismo.
2. Cuatro pipelines modulares, que se prueban y se relanzan por separado. Cada uno que escribe tablas termina refrescando el endpoint SQL.

   | Pipeline | Hace |
   |---|---|
   | `Ingesta_datos` | INGESTA_Maestros y INGESTA_Carga_Datos en paralelo; endpoint SQL si los dos terminan bien |
   | `Transformacion_datos` | TRANS_Silver, endpoint SQL, TRANS_Gold, endpoint SQL, cada paso solo si el anterior termina bien |
   | `Refresco_modelos` | Financial Model y Agings |
   | `Generar_salidas` | El notebook de ficheros y la copia a SharePoint. Parámetro `ficheros` (por defecto, todos): el notebook genera solo los pedidos (hoy Balance y Saldos_4_7; después Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow) |

   No se hace un pipeline por fichero de Grupo: la ingesta y la transformación son comunes y un dataflow se refresca entero; la elección de ficheros va en el parámetro de `Generar_salidas`.
3. Tres flujos que encadenan los modulares, cada paso solo si el anterior termina bien y esperando a que termine:

   | Flujo | Encadena |
   |---|---|
   | `Flujo_actualizar_datos` | `Ingesta_datos` y `Transformacion_datos` |
   | `Flujo_total_reporting` | `Flujo_actualizar_datos` y `Refresco_modelos` |
   | `Flujo_total_txt` | `Flujo_actualizar_datos` y `Generar_salidas` |

   Si Fabric no permite que un flujo invoque a otro flujo, `Flujo_total_*` invocan directamente los modulares. Cuando existan los controles de veracidad (concepto 7 de la auditoría general), irán antes de `Generar_salidas`.
4. Tres botones, iguales en la página Home de los informes que hoy los tienen: "Actualizar datos" (lanza `Flujo_actualizar_datos`), "Actualizar informes" (lanza `Refresco_modelos`) y "Generar txt" (lanza `Generar_salidas`). Cada botón llama a su UDF; hace falta una UDF nueva para el tercero. Los flujos totales se lanzan desde Fabric (y, si se decide, con programación).
5. Las UDF esperan a que el job termine y devuelven su estado final. El secreto sale de las UDF (conexión gestionada o Key Vault, a decidir con IT de Tinkle) y se rota; después, las UDF se versionan en el repo como el resto de items.
6. "Generar Reporting" y "Grabar salidas" se mantienen hasta que los nuevos estén probados; después se borran (son items que se pueden recuperar desde `main`, pero no con `publicar_fabric.py`, que no crea items).

## Alternativas descartadas

- Mantener los dos pipelines actuales con un padre encima: no permite probar ni relanzar un paso suelto.
- Un pipeline por fichero de Grupo: multiplica los pipelines sin separar nada de verdad, porque la ingesta y la transformación son comunes.
- Un esquema propio para las salidas: más ordenado, pero añade un esquema solo para dos vistas.

## Consecuencias

- Riesgo: con botones separados, "Generar txt" puede lanzarse sobre datos viejos. `Generar_salidas` comprueba que el último periodo cargado en `300.Fact_Actuals` es el del cierre que se pide y, si no, falla sin generar nada.
- Rollback: las definiciones vuelven con `publicar_fabric.py --ref`; los items nuevos se borran a mano; las vistas se recrean con los `CREATE VIEW` de `fabric/sql/`. Los datos de 200.Oracle_historico, 200.HAPA y 200.MMS no se regeneran relanzando: versiones Delta de partida anotadas en el plan.
- Al cambiar vistas, pipelines e informes, `lineage.md`, `architecture.md`, `apis.md` y `configuration.md` del vault quedan STALE y se refrescan en `main` tras integrar.
- Plan de ejecución: `reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`.
