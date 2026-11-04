# Prompt para nueva conversación: generar los diagramas de arquitectura con la marca Docenteo

Pega esto tal cual al abrir la nueva conversación, desde `C:\dev\tinkle_financiero`. Es reutilizable: sirve para generar los diagramas por primera vez y para regenerarlos después de cualquier cambio en Fabric. No contiene hechos de la arquitectura a propósito: salen del vault, que se genera a partir de la copia de Fabric del repositorio.

---

Quiero generar (o regenerar) los diagramas de arquitectura de `reporting-financiero/docs/diagramas/` del proyecto Tinkle Financiero con el design system de Docenteo, a partir del estado actual de Fabric.

## 0. El repositorio refleja Fabric

1. Lee `CLAUDE.md` y `AGENTS.md` de la raíz del repo y `reporting-financiero/docs/flujo-fabric.md`, y haz los pasos de su sección 4 (rama `reporting-financiero`, cuenta de Azure CLI). Si `main` tiene commits que la rama no tiene (por ejemplo, del vault), propón integrarlos en la rama antes de seguir.
2. Pregúntame: "¿Sabes si la copia de Fabric del repositorio está al día con el workspace?". Según la respuesta:
   - "Sí" o "no lo sé": ejecuta `reporting-financiero/.venv/Scripts/python.exe reporting-financiero/scripts/exportar_fabric.py --comprobar main`. Código 0: sigue. Código 1: pasa al caso siguiente.
   - "No", o la comprobación da código 1: trae Fabric al repositorio con el flujo A de `flujo-fabric.md` desde el paso 3 (`exportar_fabric.py`, revisar `git diff`, commit, merge `--no-ff` en `main` preguntando antes). Al terminar, `--comprobar main` debe dar 0.
3. La fuente de los hechos es la copia de Fabric en `reporting-financiero/fabric/`, a través del vault. Ni los diagramas antiguos ni la documentación de `docs/` cuentan como fuente.

## 1. El vault refleja el repositorio

1. Ejecuta el check del vault (ver `CLAUDE.md`, sección "Mantenimiento del vault") y `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests/test_linaje_vault.py`; si el test falla, lleva a `vault/repos/rf-fabric/lineage.md` lo que señale antes de seguir. Si sale STALE para `rf-fabric` o `rf-scripts`, `gv.py plan --stale` y resincroniza esos documentos antes de dibujar nada; después, `gv.py validate` sin errores y commit en `main` (lo transversal va ahí).
2. Lee los hechos del vault en este orden: `vault/README.md`, `vault/index/README.md`, `vault/agent-context/repo-cards/rf-fabric.md` y `rf-scripts.md`, y luego `vault/repos/rf-fabric/` (`overview`, `architecture`, `lineage`, `data-model`, `domain-model`, `integrations`, `apis`), `vault/domains/ficheros-de-grupo.md` y `vault/infrastructure/`.
3. Cada nodo y cada flecha de un diagrama tiene que poder citarse con un documento del vault. No deduzcas relaciones por cercanía ni por nombre, ni a partir de indicadores sueltos de un fichero (por ejemplo, `loadEnabled = False` en un dataflow no significa que la consulta no escriba). Si falta un hecho que el diagrama necesita, compruébalo en `reporting-financiero/fabric/`, llévalo al documento del vault que le corresponde (con su Evidence) y valida el vault; nunca lo apuntes en este prompt.
4. Antes de dibujar, enséñame una lista corta de los hechos que vas a usar con el documento del vault de cada uno, y lo que el vault deja como TBD.

## 2. Marca y herramientas

- Carga la skill `docenteo-skills:docenteo-design` y sigue sus pasos: colores y fuentes solo de sus tokens.
- Carga la skill `diagram-design:diagram-design` para la gramática (tipos, reglas de conectores, presupuesto de complejidad, accesibilidad). Si existe el marcador `.diagram-design` en la raíz del repo con un perfil `docenteo`, úsalo. Si no, haz su incorporación con la opción "installed skill" usando `docenteo-design` como fuente: roles (`paper`, `ink`, `muted`, `accent`, `link`, `rule`) asignados a tokens de Docenteo y fuentes de Docenteo. Enséñame el diff de tokens, guárdalo como perfil `docenteo` y, si lo confirmo, escribe el marcador.
- Si la marca de Docenteo y la skill de diagramas chocan, manda Docenteo.
- Antes de cada diagrama, di el tipo elegido, el tamaño y lo que el presupuesto de complejidad obliga a dejar fuera; si se supera, divide en vista general y detalle.

## 3. Entregables

HTML autocontenidos en `reporting-financiero/docs/diagramas/`. Si ya existen, se sustituyen; los formatos antiguos que queden (SVG hechos a mano) se borran al final, porque quedan en el historial de Git.

1. Arquitectura general: de los extractos de entrada a los consumidores (informes, aplicaciones y ficheros de Grupo), con la orquestación.
2. Flujo de datos por capas: qué produce cada tabla de cada capa del lakehouse y qué la lee. Si supera el presupuesto, divídelo (vista general y un detalle por capa, o tabla si comunica mejor).
3. Orquestación: pipelines, funciones de usuario y sus dependencias.
4. Un diagrama por cada fichero de Grupo que tenga cadena implantada según `vault/domains/ficheros-de-grupo.md`: de las tablas de origen a la carpeta donde Finanzas recoge el fichero. Los que estén sin implantar, como mucho con trazo discontinuo en el diagrama general.

Si en Fabric aparece algo que no encaja en estos cuatro, dímelo y propón dónde va.

## 4. Comprobaciones antes de dar nada por terminado

- Las comprobaciones de tokens y de render de la skill `docenteo-design` sobre cada archivo, sin errores.
- `self_check.py` de la skill de diagramas y su lista de comprobación previa (conectores ortogonales, etiquetas con máscara, sin solapes, accesibilidad).
- Una tabla final con cada nodo y flecha y el documento del vault que lo respalda. Lo que no tenga respaldo se quita.
- Texto en español con ortografía completa; sin rayas largas, flechas tipográficas ni comillas tipográficas.
- Enlaza los diagramas donde se citen (busca `diagramas/` en `reporting-financiero/docs/` y en el vault).
- Commit en `reporting-financiero` con mensaje `docs(diagramas): ...`. Push nunca sin pedirme aprobación justo antes, diciendo qué ramas y qué commits se suben.
