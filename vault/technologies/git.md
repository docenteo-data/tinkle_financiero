---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, git]
---

# Git

**Responsabilidad:** sistema de control de versiones del repositorio. Guarda la copia en texto del workspace de Fabric, permite compararla con commits concretos y restaurar versiones anteriores.

## Repos that use it

- [[repos/rf-fabric/README|rf-fabric]] - versiona `fabric/` con la rama main (lo publicado en Fabric) y la rama reporting-financiero (trabajo); los merges a main usan `--no-ff`; el atributo `-text` evita conversiones de finales de línea (`.gitattributes` de la raíz; `reporting-financiero/docs/flujo-fabric.md`)
- [[repos/rf-scripts/README|rf-scripts]] - lee commits sin hacer checkout con `git archive` y compara con Fabric (`reporting-financiero/scripts/fabric_comun.py#ficheros_en_git`, `reporting-financiero/scripts/fabric_comun.py#comparar`; `reporting-financiero/scripts/exportar_fabric.py` con `--comprobar`)

## Integration surface

- **Access**: CLI local de git. Los scripts leen el archivo del commit en memoria y no escriben en el árbol de trabajo.
- **Auth**: no aplica a la lectura local. El acceso al remoto no se documenta en el repositorio (TBD).

## Notes

- Al leer commits se fija `core.autocrlf=false`, de modo que los bytes del commit se comparan tal cual con Fabric.
- Si la referencia no existe, `rf-scripts` termina con código 2.
- Solo se versionan las definiciones de Fabric como texto; las User Data Functions quedan fuera.
- TBD: versión mínima de git requerida.
