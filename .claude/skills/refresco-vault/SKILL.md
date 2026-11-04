---
name: refresco-vault
description: >-
  Refresca el vault de agentes (vault/) con subagentes en paralelo cuando gv.py check
  marca unidades desfasadas: un subagente Haiku por unidad, un juez Opus por unidad,
  corrección de hallazgos y cierre con gv.py mark-synced en serie. Usar después de
  integrar en main una rama que deja el vault desfasado (paso obligatorio, CLAUDE.md
  "Mantenimiento del vault"), o cuando la persona pida actualizar, refrescar o
  sincronizar el vault.
---

# Refresco del vault con subagentes

Runner por defecto del plan de `gv.py plan` (CLAUDE.md, "Roles y modelos" y "Mantenimiento del vault"). Usa el mismo plan y los mismos prompts fijos de la skill `ralph-vault` (`assets/prompts/sync.md`, `bootstrap.md`, `reconcile.md`, `judge.md`); solo cambia quién los ejecuta. Alternativa en serie: el bucle ralph sobre `plan/plan.md`. Adaptada de la skill del mismo nombre del repositorio de Next Maritime (`inext`).

Antes de empezar, carga la skill `docenteo-skills:ralph-vault`: su ruta base (`<ralph-vault>`) es la que se pone, en absoluto, en los comandos y en las plantillas.

`<gv>` es `"reporting-financiero/.venv/Scripts/python.exe" "<ralph-vault>/scripts/gv.py" --vault vault`, siempre desde la raíz del repositorio.

## Precondiciones (si alguna falla, parar y decírselo a la persona)

1. Rama `main`, al día con `origin/main` (`git fetch`; `git log HEAD..origin/main` vacío).
2. Árbol limpio: `git status --porcelain` vacío salvo `plan/` (ignorado). En particular `git status --porcelain -- vault` vacío: restos de otro refresco o ediciones a mano en `vault/` se sellarían como sincronizados sin pasar por el juez. Si hay restos, se preguntan a la persona; no se borran por iniciativa propia.
3. `<gv> check` marca alguna unidad (hoy, `rf-fabric` o `rf-scripts`). Si no, no hay nada que hacer.

## Pasos

1. Plan: `<gv> plan --stale --no-graph` (o `--needs-work` si `check` pide `reconcile`, o sin `--no-graph` si cambiaron las integraciones entre unidades). Anotar la hora de inicio y, por unidad, el `head` que figura en la cabecera de `plan/task/NN.md` (es el commit que leerán los subagentes).
2. Generación: un subagente Haiku por tarea, todos a la vez (plantilla G). Si una unidad tiene más de 8 secciones afectadas, partirla: un subagente por sección y otro para la tarjeta; en ese caso solo la sesión principal marca las casillas de `plan/task/NN.md`.
3. Comprobación de alcance (sesión principal), con todos los subagentes ya terminados:
   - `git status --porcelain` completo. Fuera de `vault/repos/<unidades del plan>/`, sus tarjetas y `plan/` no puede haber nada. Ficheros modificados fuera de alcance: `git checkout -- <fichero>`. Ficheros nuevos fuera de alcance: `git clean -n -- <ruta>` para listarlos y borrar solo esos.
   - Por unidad, solo en tareas `sync` con lista "Diff scope": lo cambiado en `vault/repos/<unidad>/` debe estar en esa lista, ser un documento nuevo que la tarea pida o recoger elementos añadidos por la subtarea de escaneo. Lo demás se revierte y se anota. En tareas `reconcile`, `bootstrap` o `sync` sin `source_globs`, todo `vault/repos/<unidad>/` es alcance válido.
   - La tarea tiene `[x]` en todas sus subtareas de contenido.
4. Jueces: un subagente Opus por unidad, todos a la vez (plantilla J). Instancia distinta de la que generó.
5. Correcciones: para cada unidad con hallazgos de hechos erróneos o ausentes, un subagente Haiku con el informe del juez (plantilla C). Repetir la comprobación de alcance del paso 3. Las unidades que tenían un hecho erróneo o un `fail` vuelven a pasar por el juez (paso 4).
6. Cierre, en serie, solo de las unidades con todas sus subtareas `[x]` y veredicto `pass` o `warn`: `<gv> mark-synced --repo <unidad> --commit <head del paso 1>` (o `mark-reconciled`; en `bootstrap`, que no muestra `head`, sin `--commit`), una detrás de otra. `mark-synced` sella `commit` y `last_sync` en los documentos modificados; los subagentes no los tocan.
   - Unidad que no cierra (subagente fallido, `fail` tras la segunda revisión): revertir sus documentos (`git checkout -- vault/repos/<unidad> vault/agent-context/repo-cards/<unidad>.md` si ya existían, y borrar sus ficheros nuevos; en una unidad nueva, solo borrar) y no marcarla. Queda desfasada para el próximo refresco; se le dice a la persona.
   - Si una misma unidad sigue sin cerrar tras varios refrescos seguidos, recomendar repetirlo en una sesión nueva, sin el contexto del desarrollo.
7. Grafo, solo si el plan lo incluye: después de las unidades, un subagente Haiku por tier (`relations`, `components`, `dependencies`), uno detrás de otro, con su juez.
8. Comprobaciones: `<gv> validate` (0 errores), `<gv> check` (las unidades cerradas, al día) y `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests/test_linaje_vault.py`. Si el test falla, `lineage.md` no recoge alguna consulta, tabla o tipo de item: corrección con la plantilla C, con el fallo del test como hallazgo. Revisar `git diff --stat -- vault`.
9. Commit en `main` (`docs(vault): refresco de <unidades> tras <cambio>`, sin atribución a Claude) y push solo con la aprobación de la persona justo antes. Si el push se rechaza porque `main` avanzó: `git pull --rebase` con su confirmación, repetir `<gv> check` y, si vuelve a salir alguna unidad, refrescarla en un ciclo nuevo. Borrar `plan/`. Anotar la duración.

## Plantillas

Sustituir `<raíz>`, `<ralph-vault>`, `<unidad>` y `NN`. Rutas siempre entre comillas. Lanzar G y C con `model: haiku` y J con `model: opus`.

### G (generación, Haiku)

```text
You refresh one unit of the agent knowledge vault of the repository "<raíz>" (unit: <unidad>, task file plan/task/NN.md). Work from the repository root. Quote paths.
Read first: "plan/task/NN.md" (mode, diff scope and subtasks) and the FIXED prompt the task file names under "<ralph-vault>/assets/prompts/" (sync.md, bootstrap.md or reconcile.md). Use the exact git diff command the task file shows; read only the vault docs and source files the task needs.
Do ONLY the content subtasks of the task file, in order, and mark each [x] in "plan/task/NN.md", including every affected-doc checkbox and "Run gv.py validate"; a doc with no statement to change is marked [x] too, followed by " (NOOP)". Do NOT do "[juez]" nor the "Close" subtask (gv.py mark-synced / mark-reconciled).
Hard limits: write only inside "vault/repos/<unidad>/", "vault/agent-context/repo-cards/<unidad>.md" and the checkboxes of "plan/task/NN.md". Never touch vault/.ralphvault/config.json, vault/meta/, vault/adrs/, plan/plan.md, other units or any source file. Do not edit the commit or last_sync frontmatter fields (gv.py stamps them). Keep each doc's existing language (Spanish with full spelling: ñ and accents). Never copy source code. Never read anything under ".secretos/".
In unit rf-fabric, "vault/repos/rf-fabric/lineage.md" must keep every dataflow query, every lakehouse table and the item types section (see its "Reglas" section).
When you run gv.py validate, fix only errors in files of your unit and ignore every other error (other units are being written at the same time).
Shell only: "reporting-financiero/.venv/Scripts/python.exe" "<ralph-vault>/scripts/gv.py" --vault vault <subcommand>, "git diff ...", "git log ...", "git show ...", "git rev-parse ...". No commits. No subagents.
Reply in under 8 lines: subtasks done, files written, validate result for your files, concerns.
```

### J (juez, Opus)

```text
You are the Vault Judge for one unit of the agent knowledge vault of "<raíz>" (unit: <unidad>; source: its path in vault/.ralphvault/config.json; task file plan/task/NN.md lists the diff scope just refreshed by another agent). Work from the repository root.
Follow "<ralph-vault>/assets/prompts/judge.md" exactly. Target: "vault/repos/<unidad>/" and "vault/agent-context/repo-cards/<unidad>.md". Focus on the docs in the diff scope; compare their claims with the source (the git diff command the task file shows, and the current files). A doc mixing languages in the touched sections is a warn. Coverage findings that need docs outside this unit (technologies/, infrastructure/) go in the report as warn, flagged "outside unit".
Read-only, except: write your report to "vault/.ralphvault/reports/judge-<unidad>.md" (overwrite) and mark the "[juez]" checkbox [x] in "plan/task/NN.md". Shell only: gv.py validate, git diff/log/show/rev-parse. No subagents. Ignore commit/last_sync values (gv.py stamps them after judging). Never read anything under ".secretos/".
Reply with the verdict line (JUDGE pass|warn|fail · <unidad> · E errors · W warnings) and at most 6 lines with findings that would mislead an agent (wrong or missing facts), each with file and reason.
```

### C (corrección, Haiku)

```text
Fix the vault docs of unit <unidad> in "<raíz>" using the judge findings. Work from the repository root; quote paths.
Read "vault/.ralphvault/reports/judge-<unidad>.md" and the docs and source files it cites. Fix every finding inside this unit in place; keep each doc's existing language and style; do not rewrite unrelated text; never copy source code; do not edit commit/last_sync. Findings flagged "outside unit" are not yours: list them in your reply.
Write only inside "vault/repos/<unidad>/" and "vault/agent-context/repo-cards/<unidad>.md". Then run gv.py validate and fix only errors in your unit's files. Shell only: gv.py, git diff/log/show/rev-parse. No commits. No subagents.
Reply in under 6 lines: findings fixed (one line each), files changed, validate result, findings left outside the unit.
```
