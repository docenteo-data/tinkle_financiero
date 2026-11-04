# CLAUDE.md

Punto de entrada para la sesión principal de cualquier agente (Claude Code u
otro) que abra el repositorio del cliente Tinkle. Lee esto y para de leer
hasta necesitar más.

## Qué es este repo

Repositorio del cliente Tinkle en la organización Docenteo de GitHub. Todo el
repositorio es un único proyecto, el reporting financiero de Tinkle; su código,
su entorno virtual y su documentación están en `reporting-financiero/`.

## Ramas y commits

- `main` refleja lo publicado en Fabric y el trabajo cerrado. En `main`
  directamente solo se hacen el refresco del vault y los cambios de
  convenciones (CLAUDE.md, AGENTS.md, `.claude/`).
- Cada línea de trabajo tiene su rama, creada desde `main` al día:
  `feature/<nombre-corto>` (por ejemplo `feature/orquestacion-y-vistas`). Antes
  de tocar nada, comprueba la rama con `git branch --show-current`.
- Lo que se publica en Fabric sale de la rama de trabajo
  (`publicar_fabric.py --ref <rama>`). Tras validarlo en Fabric se exporta a la
  misma rama, y la rama se integra en `main`.
- `vault/` no se toca en las ramas de trabajo: se refresca en `main` después de
  integrar (ver "Mantenimiento del vault"). Excepciones: los ADR escritos a mano
  (`vault/adrs/`), que viajan con la rama que toma la decisión, y la
  configuración del vault (`vault/.ralphvault/config.json` y los `source_globs`).
- Commits conventional en español con prefijo de trabajo
  (`feat(<trabajo>): ...`, `fix(...)`, `docs(...)`), tras cada cambio no trivial.
- `main` solo recibe líneas de trabajo cerradas, con merge `--no-ff`, y nunca
  por iniciativa propia: pregunta antes de integrar. Al cerrar: merge,
  etiqueta, refresco del vault y borrado de la rama (local y remota, con
  aprobación).
- Push: nunca sin pedir aprobación al usuario justo antes, en cada push. Di qué
  ramas y qué commits se suben y espera su sí. Una aprobación anterior, o una
  frase general como "habrá que hacer push", no cuenta para el siguiente push.
- Worktree solo si otra sesión trabaja a la vez en el mismo clon.

## Modo de trabajo

- Divide en tareas pequeñas e independientes y delega en subagentes con prompt
  cerrado y contexto mínimo: di qué leer por ruta exacta, qué producir y en qué
  formato corto.
- Un plan por fases se escribe con `superpowers:writing-plans` en
  `reporting-financiero/docs/planes/AAAAMMDD-nombre.md`, en la rama de su línea
  de trabajo, y el usuario lo aprueba antes de ejecutarlo.
- Roles y modelos:
  - Sesión principal (Opus): diseño, plan, reparto de tareas, revisión de cada
    tarea, commits, push y publicación en Fabric.
  - Implementadores (Haiku): un subagente por tarea del plan, uno por fichero y
    entregable (skill `superpowers:subagent-driven-development`). Sin commit.
  - Revisores de tarea y revisión final (Opus). Búsquedas de solo lectura
    (Haiku).
  - Vault: skill `refresco-vault` (un subagente Haiku por unidad, un juez Opus
    por unidad, correcciones con Haiku).
- La sesión principal valida cada fase ejecutando sus checks antes de pasar a
  la siguiente y de commitear, porque el autoinforme del subagente no es
  prueba. Si una tarea no sale en Haiku, se parte, no se sube de modelo.
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
3. `vault/agent-context/repo-cards/<unidad>.md` (tier 1, tarjeta resumen; unidades `rf-fabric` y `rf-scripts`).
4. Solo si hace falta más: `vault/repos/<unidad>/*.md` o `vault/domains/*.md`.

No leas código, notebooks o docs salvo que la tarea lo pida o el vault no lo
cubra. El código y `docs/` son canónicos si el vault está desactualizado.

## Mantenimiento del vault

Paso obligatorio: quien integra en `main` un cambio de
`reporting-financiero/` corre el check en `main` justo después y, si alguna
unidad sale STALE, refresca el vault en ese momento con la skill
`refresco-vault` (`.claude/skills/refresco-vault/`), antes de dar el trabajo por
terminado. Alternativa en serie: `gv.py plan --stale` y el bucle ralph. La
skill ralph-vault llega por plugin: su ruta la da la propia skill al cargarse.

    "reporting-financiero/.venv/Scripts/python.exe" "<skill ralph-vault>/scripts/gv.py" --vault vault check

## Convenciones

- Un único entorno virtual, `reporting-financiero/.venv`; nunca el de sistema.
- Los datos NO se versionan (ver `.gitignore`): se regeneran con scripts.
- `docs/` es para el equipo: planteamiento, planes, guías, reuniones. `vault/`
  es la fuente de conocimiento del agente. No mezcles una cosa con la otra.
- Glosario del dominio en `reporting-financiero/CONTEXT.md`, poblado con la skill
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

- Microsoft Fabric (workspace "Tinkle - Financiero", único entorno del
  cliente, sin pruebas separadas): el flujo completo está en
  `reporting-financiero/docs/flujo-fabric.md`. Léelo antes de tocar Fabric. Lo
  esencial:
  - `main` refleja lo publicado en Fabric; cada commit de `main` es un punto de
    rollback.
  - Cuenta: Fabric, el MCP `fabric-local` y los scripts usan la cuenta por
    defecto de Azure CLI, que debe ser `reporting@likuit.com`. Compruébala con
    `az account show` antes de usar el MCP; si es otra, para y avisa, no la
    cambies.
  - Vías: el MCP `fabric-local` para inventario, esquemas y shortcuts; los
    ficheros de `reporting-financiero/fabric/` para la lógica (M, DAX,
    pipelines, informes); `consultar_sql.py` para datos (solo lectura);
    `exportar_fabric.py` para traer Fabric al repo.
  - Escribir en Fabric solo con `publicar_fabric.py`, y `--confirmar` solo con
    la confirmación explícita de la persona en ese momento. Las herramientas
    del MCP que escriben están bloqueadas. Ejecutar pipelines y refrescar
    modelos lo hace una persona del equipo.
- Oracle, SAGE y Magnitude: no hay acceso directo; los datos llegan como
  extractos en OneDrive (ver `reporting-financiero/README.md`).
- Las UDF de Fabric tienen un secreto incrustado pendiente de rotar (ver
  `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`):
  nunca se copia su valor a ningún archivo versionado ni mensaje. La única
  copia permitida es el respaldo de su código en `.secretos/udf/` (ignorado por
  Git), hasta que el secreto salga de las UDF y estas se versionen.
