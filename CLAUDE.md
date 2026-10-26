# CLAUDE.md

Punto de entrada para la sesión principal de cualquier agente (Claude Code u
otro) que abra el repositorio del cliente Tinkle. Lee esto y para de leer
hasta necesitar más.

## Qué es este repo

Repositorio del cliente Tinkle en la organización Docenteo de GitHub.
Contiene uno o varios proyectos, cada uno en su subdirectorio con su propio
entorno virtual y sus dependencias:

- `reporting-financiero/` - Reporting financiero. Activo.

## Ramas y commits

- Una rama permanente por proyecto, con el nombre exacto de su carpeta. Todo el
  trabajo del proyecto va ahí: no abras ramas por tarea. Antes de tocar nada,
  comprueba la rama con `git branch --show-current`.
- Lo transversal (vault, CLAUDE.md, AGENTS.md, convenciones) va directo a `main`.
- El trabajo se distingue por el commit: conventional en español con prefijo de
  trabajo (`feat(<trabajo>): ...`, `fix(...)`, `docs(...)`). Un commit no toca
  dos proyectos a la vez.
- Commit en la misma sesión tras cada cambio no trivial; el push, tras
  confirmarlo con el usuario. Etiqueta al cerrar un trabajo.
- `main` solo recibe ciclos cerrados, con merge `--no-ff`, y nunca por iniciativa
  propia: pregunta antes de integrar.
- Worktree solo si otra sesión trabaja a la vez en el mismo proyecto.

## Modo de trabajo

- Divide en tareas pequeñas e independientes y delega en subagentes con prompt
  cerrado y contexto mínimo: di qué leer por ruta exacta, qué producir y en qué
  formato corto.
- Un plan por fases se escribe con `superpowers:writing-plans` en
  `<proyecto>/docs/planes/AAAAMMDD-nombre.md` y el usuario lo aprueba antes de
  ejecutarlo.
- El plan aprobado no lo ejecuta la sesión principal: sus tareas van a
  subagentes Haiku, uno por fichero y entregable (skill
  `superpowers:subagent-driven-development`). La sesión principal reparte y
  valida cada fase ejecutando sus checks antes de pasar a la siguiente y de
  commitear, porque el autoinforme del subagente no es prueba. Si una fase no
  sale en Haiku, se parte, no se sube de modelo.
- Persiste solo conocimiento reutilizable: el del proyecto va al vault; los
  hechos durables meta (decisiones, preferencias, punteros) van a memoria. El
  código es la fuente de verdad; no lo dupliques en vault ni en memoria.

## Reglas de código y tests

@AGENTS.md

## Primero el vault, no el código

Existe un vault de conocimiento en `vault/` (skill `ralph-vault`). Orden de
carga ante cualquier duda:

1. `vault/README.md` (tier 0, punto de entrada).
2. `vault/index/README.md` (índice cruzado).
3. `vault/agent-context/repo-cards/<proyecto>.md` (tier 1, tarjeta resumen).
4. Solo si hace falta más: `vault/repos/<proyecto>/*.md` o `vault/domains/*.md`.

No leas código, notebooks o docs salvo que la tarea lo pida o el vault no lo
cubra. El código y `docs/` son canónicos si el vault está desactualizado.

## Mantenimiento del vault

Tras un cambio no trivial en un proyecto documentado, corre el check desde la
raíz del repo y resincroniza si sale STALE (`gv.py plan --stale` y el bucle).
La skill ralph-vault llega por plugin: su ruta la da la propia skill al cargarse.

    "<proyecto>/.venv/Scripts/python.exe" "<skill ralph-vault>/scripts/gv.py" --vault vault check

## Convenciones

- Un entorno virtual por proyecto (`<proyecto>/.venv`), nunca uno compartido.
- Los datos NO se versionan (ver `.gitignore`): se regeneran con scripts.
- `docs/` es para el equipo: planteamiento, planes, guías, reuniones. `vault/`
  es la fuente de conocimiento del agente. No mezcles una cosa con la otra.
- Glosario del dominio en `<proyecto>/CONTEXT.md`, poblado con la skill
  grill-with-docs antes de escribir código.
- Idioma español con ortografía completa: la ñ, las tildes y la ü son
  obligatorias en documentos, comentarios, commits y mensajes. Sin emojis, sin
  comillas tipográficas, sin guiones largos ni flechas. La única excepción es
  la salida por consola (`print`), que va en ASCII (ver AGENTS.md).
- Commits sin línea `Co-Authored-By` ni ninguna atribución a Claude.
- Todo lo visual (HTML, CSS, componentes, cuadros de mando, gráficos, Word,
  PowerPoint, Excel) se hace con la skill `docenteo-design` y sigue el design
  system de Docenteo al pie de la letra, también en piezas para el cliente.

## Definition of Done

Antes de dar por cerrado un hito: `gv.py validate` y `gv.py check` verdes,
`CONTEXT.md` y el plan al día, y los datos regenerables (script de extract más
la nota de cómo regenerarlos).

## Reglas del cliente

- Microsoft Fabric (capacidad F4, lakehouse `lh_tinkle_financiero`) y Power BI
  del cliente: solo lectura por API. Ejecutar pipelines, refrescar o publicar
  modelos e informes lo hace una persona del equipo.
- Oracle, SAGE y Magnitude: no hay acceso directo; los datos llegan como
  extractos en OneDrive (ver `reporting-financiero/README.md`).
- Las UDF de Fabric tienen un secreto incrustado pendiente de rotar (ver
  `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`):
  nunca se copia su valor a ningún archivo ni mensaje.
