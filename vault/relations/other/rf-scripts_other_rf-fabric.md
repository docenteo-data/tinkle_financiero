---
type: relation
load_tier: 2
schema_version: 1
from: "[[repos/rf-scripts/README|rf-scripts]]"
to: "[[repos/rf-fabric/README|rf-fabric]]"
relation_type: other
tags: [relation, other]
---

# rf-scripts - other - rf-fabric

> One typed edge of the system graph. File path: `relations/other/rf-scripts_other_rf-fabric.md`.

## Type

Dependencia sobre ficheros versionados, no una llamada de red ni una librería. `rf-scripts` lee, compara y, con confirmación explícita, publica las definiciones de items que están guardadas como texto en la carpeta `fabric/` de `rf-fabric`. Además, con confirmación explícita, crea los items que faltan en Fabric y lanza pipelines por su nombre en el workspace. Las vistas SQL se describen en la arista db. Se usa `other` porque ninguna categoría fija describe este acoplamiento: no hay `code` (no se importa código de `rf-fabric`) ni `http` (la API de Fabric no es un repo registrado). El efecto de las vistas en la base de datos se documenta aparte en la arista `db` ([[relations/db/rf-scripts_db_rf-fabric|rf-scripts - db - rf-fabric]]).

## Detail

| Touchpoint | Mechanism | Configuration |
|---|---|---|
| Carpeta `reporting-financiero/fabric` en un commit | Lectura con git archive, sin checkout, para comparar y para publicar | Constante de carpeta en `fabric_comun.py`; referencia por argumento `--ref` o `--base` |
| Carpeta `fabric/` de la copia de trabajo | Escritura completa al exportar, salvo `temas/` | Modo normal de `exportar_fabric.py` |
| Definiciones de items (dataflows, pipelines, modelos, informes, notebook) | Publicación de la definición leída del commit hacia el item existente | `publicar_fabric.py` con `--ref`, solo con `--confirmar` |
| Items que están en el commit y no en Fabric | Creación del item con la definición leída del commit (nunca borrado) | `publicar_fabric.py` con `--crear`, solo con `--confirmar` |
| Pipelines de Fabric (`*.DataPipeline`) | Lanzamiento por `displayName` en el workspace con la API de jobs y espera hasta estado final; no lee `fabric/`, así que editar `fabric/<X>.DataPipeline/` sin publicar no cambia lo que se ejecuta. Lo que escriben se documenta en la arista db | `ejecutar_fabric.py` con `--parametro CLAVE=VALOR` (repetible) y `--max-minutos` (180 por defecto), solo con `--confirmar` |

## Direction & contract

- **Caller / producer**: [[repos/rf-scripts/README|rf-scripts]]. Produce la copia de `fabric/` al exportar, consume los ficheros de `fabric/` (items) al comparar o publicar, y lanza pipelines por su nombre en el workspace.
- **Callee / consumer**: [[repos/rf-fabric/README|rf-fabric]]. Es la copia en texto de las definiciones del workspace y la fuente de lo que se publica (items). Los pipelines que se ejecutan son los publicados en Fabric con ese nombre.
- **Contract**: estructura de carpetas `<Item>.<Tipo>/` y formatos de definición (TMDL, PBIR, ipynb, JSON de dataflows y pipelines) fijados en `FORMATOS` y `CARPETAS_LAKEHOUSE` de `fabric_comun.py`. Sin versión formal.

## Evidence

En `rf-scripts` (origen de la lectura, escritura y ejecución):
- `scripts/fabric_comun.py` - constante `CARPETA_FABRIC` con la ruta `reporting-financiero/fabric`; `ficheros_en_git` lee esa carpeta de un commit; `crear_item`, `lanzar_pipeline` y `esperar_job` crean items y siguen los jobs.
- `scripts/publicar_fabric.py` - lee definiciones de `--ref` (por defecto HEAD); `--crear` crea los items ausentes.
- `scripts/ejecutar_fabric.py` - `main` busca el pipeline por `displayName` en el workspace, lo lanza con `--parametro` y espera a su estado final; no lee `fabric/`.
- `scripts/exportar_fabric.py` - regenera `fabric/` desde Fabric y lo compara con `main` en modo `--comprobar`.
- Documentación del repo: `vault/repos/rf-scripts/architecture.md` (flujos Publicar y Ejecutar pipeline) y `apis.md` (`publicar_fabric.py` con `--crear`; `ejecutar_fabric.py`).

En `rf-fabric` (destino de la lectura, origen de lo publicado y de los pipelines ejecutados):
- `fabric/` - carpetas `<Item>.<Tipo>/` con las definiciones de los items del workspace.
- `fabric/Generar_salidas.DataPipeline/pipeline-content.json` y `fabric/Flujo_total_txt.DataPipeline/pipeline-content.json` - definiciones de pipelines; `ejecutar_fabric.py` no las lee, sino el pipeline publicado con ese nombre en el workspace.
- Documentación del repo: `vault/repos/rf-fabric/overview.md` (exportación con `exportar_fabric.py`) y `configuration.md` (flujo B: editar `fabric/<Item>/`, simular y publicar con `publicar_fabric.py`; rollback con `--ref`).
