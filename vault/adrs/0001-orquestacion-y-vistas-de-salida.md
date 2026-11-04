---
type: adr
load_tier: 3
schema_version: 1
status: propuesta
date: 2026-11-04
tags: [rf-fabric, orquestacion, adr]
---

# ADR 0001 - Orquestación del cierre y vistas de salida

> Cuándo cargar: vas a cambiar los pipelines, las UDF o las vistas de exportación de rf-fabric, o a dibujar la orquestación "propuesta".

## Contexto

Hechos de partida en [[repos/rf-fabric/architecture]] y [[repos/rf-fabric/lineage]]:

- Las vistas de los ficheros de Grupo (`vw_Export_Grupo` y `vw_Export_Saldos_4_7`) están en el esquema 200 y leen solo tablas del 300. La vista de reporting (`vw_Reporting_Actuals`) está en el 300.
- "Generar Reporting" actualiza los datos (ingesta, silver, gold, endpoint SQL y modelos) y "Grabar salidas" genera y copia los TXT. Nada los encadena (riesgo O2): cada uno lo lanza una UDF que solo comprueba que el job se ha encolado.
- Los dos refrescos de modelos se ejecutan con la condición Completed, también si falla la capa gold.
- INGESTA_Maestros no está en ningún pipeline.
- Las UDF llevan un secreto incrustado (riesgo S1) y por eso no se versionan.

## Decisión

1. Las vistas de salida van al esquema 300, junto a `vw_Reporting_Actuals`. Las del 200 se borran cuando las nuevas devuelvan lo mismo.
2. "Generar Reporting" sigue siendo el pipeline de datos, con el mismo nombre (renombrar complica el rollback): INGESTA_Maestros entra al principio, en paralelo con Carga, y los refrescos de modelos pasan a Succeeded.
3. "Grabar salidas" sigue siendo el pipeline de ficheros y se puede lanzar solo, para regenerar los TXT sin recargar.
4. Un pipeline padre nuevo, "Cierre mensual", ejecuta "Generar Reporting" y, solo si termina bien, "Grabar salidas", esperando a que cada uno termine. Cuando existan los controles de veracidad (concepto 7 de la auditoría general), irán entre los dos.
5. Las dos UDF son los botones con que Finanzas lanza los procesos. Hoy `Ejecución Reporting` lanza "Generar Reporting" (actualizar datos) y `Generar_txt` lanza "Grabar salidas" (solo ficheros, con los datos que haya). Con la decisión, `Generar_txt` lanza "Cierre mensual": quien pide los ficheros obtiene antes los datos actualizados, y los ficheros solo salen si la actualización termina bien. `Ejecución Reporting` no cambia: sirve para actualizar los informes sin generar ficheros. Regenerar solo los ficheros sin recargar se sigue pudiendo hacer lanzando "Grabar salidas" desde Fabric. Las dos UDF esperan a que el job termine y devuelven su estado final.
6. El secreto sale de las UDF (conexión gestionada o Key Vault, a decidir con IT de Tinkle) y se rota. Después, las UDF se versionan en el repo como el resto de items.

## Alternativas descartadas

- Un esquema propio para las salidas: más ordenado, pero añade un esquema solo para dos vistas.
- Un único pipeline que lo haga todo: obliga a recargar los datos para regenerar un fichero.
- Dejar los pipelines sin padre y documentar el orden: es la situación actual y el origen de O2.

## Consecuencias

- Rollback: las definiciones vuelven con `publicar_fabric.py --ref`; el pipeline padre, al ser un item nuevo, se borra a mano; las vistas se recrean con los `CREATE VIEW` de `fabric/sql/`. Los datos de 200.Oracle_historico, 200.HAPA y 200.MMS no se regeneran relanzando: versiones Delta de partida anotadas en el plan.
- Al cambiar las vistas y los pipelines, `lineage.md` y `architecture.md` del vault quedan STALE y hay que resincronizarlos.
- El plan de ejecución está en `reporting-financiero/docs/planes/20261104-orquestacion-y-vistas.md`.
