---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*/.platform", "*.SemanticModel/definition.pbism", "*.Report/definition.pbir", "*.DataPipeline/pipeline-content.json"]
tags: [rf-fabric, configuration]
---

# rf-fabric - Configuration

> Cuándo cargar: necesitas el formato de cada item de Fabric, los ficheros de metadatos de la copia versionada, la política de los pipelines o el flujo para publicar y volver atrás un cambio.

## Cómo se versiona

- `reporting-financiero/fabric/` guarda una copia exportada del workspace de Fabric "Tinkle - Financiero". Hay una carpeta por item, nombrada `<Nombre>.<Tipo>` (por ejemplo `Agings.Report`, `INGESTA_Carga_Datos.Dataflow`).
- Rama `main`: refleja lo publicado en Fabric. El trabajo se hace en la rama `reporting-financiero`.
- `.gitattributes` del repositorio marca `reporting-financiero/fabric/**` con `-text`. Git guarda esos ficheros byte a byte, sin conversión de finales de línea, que es lo que permite comparar con Fabric y restaurar versiones fielmente. `-text` solo desactiva la conversión de finales de línea; no los marca como binarios (eso sería `-diff` o `binary`), así que `git diff` los muestra como texto, línea a línea.

## Formato por tipo de item

| Tipo de item | Definición en el repositorio | Formato |
|---|---|---|
| SemanticModel | Modelo (tablas, relaciones, medidas) y `definition.pbism` | TMDL, con DAX en las medidas |
| Report | Páginas y visuales, y `definition.pbir` | PBIR |
| Notebook | Código del notebook | ipynb |
| Dataflow | Consultas de Power Query | M (dentro de la definición del dataflow) |
| DataPipeline | Actividades, dependencias y política | JSON (`pipeline-content.json`) |

## Ficheros .platform

Cada carpeta de item tiene un `.platform`, un JSON con el esquema de integración de Git de Fabric. Tiene dos bloques:

- `metadata`: tipo del item (`type`) y nombre visible (`displayName`); en el Notebook, además, una descripción.
- `config`: versión del esquema (2.0) y `logicalId`.

Los 21 `.platform` tienen el `logicalId` a ceros porque es lo que devuelve getDefinition al exportar. El id real de cada item está en la sección 1 de `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`.

## definition.pbism y definition.pbir

- `definition.pbism` (en cada SemanticModel): versión del formato del modelo (4.2 en `Agings`) y `settings` vacío.
- `definition.pbir` (en cada Report): versión del formato del informe (4.0 en `Agings`) y su referencia al modelo. La referencia es `byConnection`: el informe no contiene el modelo, se conecta al modelo semántico publicado en el workspace. El informe `Agings` apunta al modelo semántico `Agings`. La cadena de conexión y el identificador del modelo no se copian aquí.

## Política de los pipelines

Hay dos DataPipeline: "Generar Reporting" y "Grabar salidas". Todos los bloques `policy` de sus actividades (siete en el primero y dos en el segundo) tienen los mismos valores:

- Timeout de 12 horas (`0.12:00:00`).
- Reintentos: 0. Un fallo no se reintenta solo; hay que relanzarlo a mano.
- Intervalo entre reintentos: 30 segundos (sin efecto mientras no haya reintentos).
- `secureInput` y `secureOutput` en false.

## Flujo de trabajo

Resumen de `reporting-financiero/docs/flujo-fabric.md` (leer el original para los pasos completos):

- `main` solo recibe definiciones ya publicadas y validadas en Fabric, por merge `--no-ff`.
- Flujo A, el cambio se hace en Fabric: exportar con `exportar_fabric.py`, revisar, commit y merge en `main`. Después, `exportar_fabric.py --comprobar main` debe dar 0.
- Flujo B, el cambio se prepara en el repositorio: editar `fabric/<Item>/`, simular con `publicar_fabric.py` (sin `--confirmar`), publicar con confirmación explícita, validar en Fabric, exportar y volver a `main`.
- Rollback: localizar el commit de `main` que tiene la versión buena y publicarlo con `--ref <commit>`. `publicar_fabric.py` solo actualiza items existentes; no crea ni borra items, no publica vistas SQL ni cambia tablas. Publicar la definición no restaura datos.
- Las User Data Functions no se versionan: llevan un secreto incrustado.

## Evidence

Rutas relativas a `reporting-financiero/fabric/`, salvo las dos últimas.

- `Agings.SemanticModel/.platform` - tipo SemanticModel, esquema y `logicalId`.
- `Agings.Report/.platform` - tipo Report.
- `Generar_txt_Balance_Saldos.Notebook/.platform` - tipo Notebook y descripción.
- `INGESTA_Carga_Datos.Dataflow/.platform` - tipo Dataflow.
- `Agings.SemanticModel/definition.pbism` - versión del modelo.
- `Agings.Report/definition.pbir` - versión del informe y referencia `byConnection`.
- `Generar Reporting.DataPipeline/pipeline-content.json` - bloques `policy` de las actividades.
- `Grabar salidas.DataPipeline/pipeline-content.json` - bloques `policy` de las actividades.
- `reporting-financiero/docs/flujo-fabric.md` - flujo, ramas y rollback (fuera de la fuente).
- `.gitattributes` (raíz del repositorio) - regla `-text` sobre `reporting-financiero/fabric/**`.

## Open questions

- TBD: estructura interna de las carpetas de definición (TMDL, PBIR, ipynb y M) y la política de los dataflows no se han revisado en esta sección.
- TBD: el resto de informes y modelos (Financial Model, Presupuesto, Rentabilidad, MMS, HAPA, Checklist) no se han revisado.
