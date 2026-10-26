# AGENTS.md

Reglas para cualquier agente o subagente que escriba código en este repo
(Claude Code, Codex u otro). Si eres un subagente, esto manda sobre lo que diga
CLAUDE.md para la sesión principal.

## Alcance y git

- Toca solo los ficheros que nombra la tarea. No explores más allá de las rutas
  que te dan; si falta contexto, dilo en el informe en vez de buscarlo.
- Un subagente no hace commit, push, ni crea ramas o worktrees: el commit lo
  hace la sesión principal después de validar.
- Rutas siempre entre comillas: pueden llevar espacios.

## Cifras y verificación

- Reporta solo valores leídos o calculados literalmente. Si un campo no existe,
  escribe "no existe"; nunca rellenes un hueco con un valor plausible.
- Si una cifra de control no cuadra, para y repórtalo. No ajustes el código
  para que cuadre.
- No edites guards, checks, tests de aceptación ni ficheros de referencia: son
  el criterio con que se juzga tu trabajo.
- Si un arreglo aplica a N casos, aplícalo a los N y di cuáles son.

## Edición de ficheros

- Nada de reemplazo global (sed, replace_all, buscar y reemplazar) sobre
  cadenas: nombres de columna e identificadores no se tocan.
- UTF-8 sin BOM al escribir.
- Texto en español con ortografía completa: la ñ, las tildes y la ü son
  obligatorias en documentos, comentarios, docstrings y commits.
- Única excepción: en Windows la consola es cp1252, así que lo que se imprime
  por consola (`print`, logs a terminal) va en ASCII o el proceso muere. Esto
  no aplica a ningún fichero.
- Todo lo visual (HTML, CSS, gráficos, Word, PowerPoint, Excel) se hace con la
  skill `docenteo-design`: cárgala antes de escribir el primer archivo.
- Python: el `.venv` del proyecto (`<proyecto>/.venv/Scripts/python.exe`),
  nunca el del sistema.

## Sistemas del cliente

- Leer por API, sí. Ejecutar, publicar o refrescar pipelines, modelos o
  informes, no: eso lo hace una persona del equipo. Subir una definición solo si
  la tarea lo pide.

## Tests

- Código nuevo: el test va antes que la implementación y tiene que fallar
  antes de implementarla. Código existente sin tests: antes de cambiarlo, un
  test que fije el comportamiento actual.
- Capa por defecto: E2E, es decir, ejecutar el pipeline completo y pasar sus
  checks, con un artefacto que se pueda regenerar y verificar aparte. Un test
  que solo detecta que el código cambió no vale.
- Tests aislados solo donde el E2E no llega: primero se enumeran los modos de
  fallo concretos y se escribe un test por cada uno.
- Nada de tests tautológicos ni de detalles de implementación.
- La aceptación la ejecuta la sesión principal, no el subagente que escribió
  el código.

## Reglas por proyecto

### reporting-financiero

- (Contratos del proyecto: idioma de los informes, scripts que no se
  ejecutan, checks que deben salir a cero. La paleta y el estilo no son del
  proyecto: los fija el design system de Docenteo.)
- `reporting-financiero/fabric/` es la copia del workspace de Fabric. Solo se
  editan sus ficheros cuando la tarea es preparar un cambio para publicar
  (flujo B de `reporting-financiero/docs/flujo-fabric.md`); conserva sus
  finales de línea. Un subagente nunca ejecuta `exportar_fabric.py` sin
  `--comprobar` ni `publicar_fabric.py`: eso lo hace la sesión principal.
- Datos: solo con `reporting-financiero/scripts/consultar_sql.py` (SELECT o
  WITH, consultas acotadas). Salarios (`Dim_RRHH`, `Fact_Asignacion_RRHH`),
  solo agregados.
- Nunca se lee ni se exporta el código de las User Data Functions.
- Las cifras de control (P&L, balance, saldos 4 y 7) se cuadran contra los
  extractos de Magnitude del mes; si no cuadran, se para y se reporta.

## Informe final

Devuelve solo: ficheros tocados, checks ejecutados con su salida, cifras de
control obtenidas, y lo que no has podido verificar.
