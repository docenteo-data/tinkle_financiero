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

Dependencia sobre ficheros versionados, no una llamada de red ni una librería. `rf-scripts` lee, compara y, con confirmación explícita, publica las definiciones de items que están guardadas como texto en la carpeta `fabric/` de `rf-fabric`. Se usa `other` porque ninguna categoría fija describe este acoplamiento: no hay `code` (no se importa código de `rf-fabric`) ni `http` (la API de Fabric no es un repo registrado).

## Detail

| Touchpoint | Mechanism | Configuration |
|---|---|---|
| Carpeta `reporting-financiero/fabric` en un commit | Lectura con git archive, sin checkout, para comparar y para publicar | Constante de carpeta en `fabric_comun.py`; referencia por argumento `--ref` o `--base` |
| Carpeta `fabric/` de la copia de trabajo | Escritura completa al exportar, salvo `temas/` | Modo normal de `exportar_fabric.py` |
| Definiciones de items (dataflows, pipelines, modelos, informes, notebook) | Publicación de la definición leída del commit hacia el item existente | `publicar_fabric.py` con `--ref`, solo con `--confirmar` |

## Direction & contract

- **Caller / producer**: [[repos/rf-scripts/README|rf-scripts]]. Produce la copia de `fabric/` al exportar y consume los ficheros de `fabric/` al comparar o publicar.
- **Callee / consumer**: [[repos/rf-fabric/README|rf-fabric]]. Es la copia en texto de las definiciones del workspace, y la fuente de lo que se publica.
- **Contract**: estructura de carpetas `<Item>.<Tipo>/` y formatos de definición (TMDL, PBIR, ipynb, JSON de dataflows y pipelines) fijados en `FORMATOS` de `fabric_comun.py`. Sin versión formal.

## Evidence

En `rf-scripts` (origen de la lectura y escritura):
- `scripts/fabric_comun.py` - constante `CARPETA_FABRIC` con la ruta `reporting-financiero/fabric` y función `ficheros_en_git` que lee esa carpeta de un commit.
- `scripts/publicar_fabric.py` - lee las definiciones de `--ref` (por defecto HEAD) y da error si el item no está en esa referencia.
- `scripts/exportar_fabric.py` - regenera `fabric/` desde Fabric y lo compara con `main` en modo `--comprobar`.
- Documentación del repo: `vault/repos/rf-scripts/architecture.md` (flujos Exportar y Publicar) e `integrations.md` (lectura de commits con git archive).

En `rf-fabric` (destino de la lectura y origen de lo publicado):
- `fabric/` - carpetas `<Item>.<Tipo>/` con las definiciones de los items del workspace.
- Documentación del repo: `vault/repos/rf-fabric/overview.md` (exportación con `exportar_fabric.py`) y `configuration.md` (flujo B: editar `fabric/<Item>/`, simular y publicar con `publicar_fabric.py`).
