# Orquestación del cierre y vistas de salida - plan de implementación

> **Para agentes:** se ejecuta con `superpowers:subagent-driven-development`. Según `CLAUDE.md`, cada tarea marcada **[repo]** va a un subagente Haiku, uno por fichero y entregable; la sesión principal valida cada fase con sus checks antes de commitear. Los pasos **[Fabric]** los hace una persona del equipo (AGENTS.md: los agentes no ejecutan, publican ni refrescan en Fabric salvo que la tarea lo pida); los pasos **[publicar]** los lanza la sesión principal con `publicar_fabric.py ... --confirmar` solo tras aprobación explícita del usuario en ese momento.

**Objetivo:** que los ficheros de Grupo salgan de vistas del esquema 300 y solo después de una actualización de datos correcta, con un pipeline padre que encadene datos y ficheros.

**Decisión:** `vault/adrs/0001-orquestacion-y-vistas-de-salida.md` (estado: propuesta hasta que el usuario apruebe este plan).

**Tecnología:** Fabric (pipelines, notebook, SQL endpoint), scripts de `reporting-financiero/scripts/`, pytest.

## Restricciones globales

- Rama `feature/orquestacion-y-vistas` (creada desde `main` en `4e67d7f`). El ADR viaja con la rama; el resto del vault no se toca aquí: se refresca en `main` tras integrar. Sin push sin aprobación justo antes.
- `main` = lo publicado en Fabric. Se publica desde la rama (`--ref feature/orquestacion-y-vistas`); tras cada publicación: `exportar_fabric.py` en la rama, revisar `git diff`, commit, merge `--no-ff` en `main` preguntando antes, y `exportar_fabric.py --comprobar main` con código 0.
- No se renombra ningún item existente.
- Identificadores (de `docs/contexto/Documentacion_Tinkle_Financiero.md`, sección 1): Generar Reporting `147b24eb-352f-4f88-9d64-b4a7fc1d67f6`, Grabar salidas `56a37cd5-3664-47b4-b28f-ec7f26d23075`, INGESTA_Maestros `60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6`, workspace `b31820dc-4b4f-4696-9a96-bbee438e9306`.
- El código de las UDF no se lee ni se imprime mientras lleve el secreto. Respaldo local en `.secretos/udf/2026-11-04/` (ignorado por Git).

## Punto de partida (04/11/2026)

- `exportar_fabric.py --comprobar main`: código 0.
- Versiones Delta (sin propiedades de retención propias; el log se conserva desde la versión 0): `200.Oracle_historico` v25, `200.HAPA` v24, `200.MMS` v42. Última escritura de las tres: 15/09/2026.

## Revisión (riesgos que ningún test cubre)

1. Las vistas nuevas devuelven distinto que las viejas (orden de columnas, tipos o filtro del último periodo): el notebook genera TXT diferentes. Se cubre con la comparación EXCEPT de la tarea 1.
2. INGESTA_Maestros falla por un `Maestros.xlsx` mal subido y ahora para todo el pipeline de datos. Es lo buscado, pero hay que avisar al equipo de Tinkle.
3. El pipeline padre lanza los hijos sin esperar a que terminen. Se cubre con el test de la tarea 3 (`waitOnCompletion`).
4. Una UDF devuelve "OK" antes de que acabe el job. Se cubre en la tarea 4.
5. Rollback del pipeline padre: `publicar_fabric.py` no borra items; se borra a mano.

---

### Tarea 1: vistas de salida en el esquema 300

**Ficheros:**
- Crear: `reporting-financiero/fabric/sql/300.vw_Export_Grupo.sql`, `reporting-financiero/fabric/sql/300.vw_Export_Saldos_4_7.sql` (mismo cuerpo que las de 200, cambiando solo el esquema de la vista).
- Modificar: `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` (las dos lecturas `200.vw_Export_*` pasan a `300.vw_Export_*`).
- Test: `reporting-financiero/tests/test_orquestacion_fabric.py`.

- [ ] **Paso 1 [repo]: test que falla.**
  - `test_ficheros_leen_vistas_de_300`: el notebook contiene `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` y no contiene `200.vw_Export`.
  - `test_vistas_de_salida_en_300`: existen `fabric/sql/300.vw_Export_Grupo.sql` y `fabric/sql/300.vw_Export_Saldos_4_7.sql` y no existen las `200.vw_Export_*.sql`.
- [ ] **Paso 2:** `pytest reporting-financiero/tests/test_orquestacion_fabric.py -k vistas_o_ficheros` falla en los dos.
- [ ] **Paso 3 [Fabric]:** crear las dos vistas en `[300]` en el SQL endpoint con el SQL de los ficheros nuevos.
- [ ] **Paso 4 [sesión]:** comparar viejas y nuevas con `consultar_sql.py`: `SELECT COUNT(*) FROM (SELECT * FROM [200].vw_Export_Grupo EXCEPT SELECT * FROM [300].vw_Export_Grupo) x`, en los dos sentidos y para las dos vistas. Esperado: 0 en los cuatro.
- [ ] **Paso 5 [repo] y [publicar]:** cambiar el notebook y publicarlo (`publicar_fabric.py "Generar_txt_Balance_Saldos.Notebook" --ref feature/orquestacion-y-vistas`, simulación y luego `--confirmar`).
- [ ] **Paso 6 [Fabric]:** ejecutar "Grabar salidas" y comparar los TXT nuevos con los de la ejecución anterior (mismo contenido salvo la marca de tiempo del nombre). Si coinciden, borrar las vistas de `[200]`.
- [ ] **Paso 7:** exportar, borrar `fabric/sql/200.vw_Export_*.sql` si la exportación no lo ha hecho, pasar los tests y commit `feat(orquestacion): vistas de salida en el esquema 300`.

### Tarea 2: pipeline de datos con maestros y refrescos condicionados

**Ficheros:**
- Modificar: `reporting-financiero/fabric/Generar Reporting.DataPipeline/pipeline-content.json`.
- Test: `reporting-financiero/tests/test_orquestacion_fabric.py`.

**Produce:** actividad nueva `Maestros` (tipo `RefreshDataflow`, `dataflowId` de INGESTA_Maestros, misma `policy` que `Carga`), sin dependencias.

- [ ] **Paso 1 [repo]: test que falla.**
  - `test_modelos_solo_si_gold_termina_bien`: las dos actividades `PBISemanticModelRefresh` dependen solo con `["Succeeded"]`.
  - `test_maestros_antes_de_silver`: hay una actividad `RefreshDataflow` con `dataflowId` `60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6`, y `RefreshSqlEndpoint1_copy1` depende de ella y de `Carga`, las dos con `["Succeeded"]`.
- [ ] **Paso 2:** el test falla en los dos.
- [ ] **Paso 3 [repo]:** editar el JSON (añadir `Maestros`, añadirla a `dependsOn` de `RefreshSqlEndpoint1_copy1`, cambiar `Completed` por `Succeeded` en los dos refrescos de modelos).
- [ ] **Paso 4:** el test pasa.
- [ ] **Paso 5 [publicar]:** `publicar_fabric.py "Generar Reporting.DataPipeline" --ref feature/orquestacion-y-vistas`, simulación y luego `--confirmar`.
- [ ] **Paso 6 [Fabric]:** ejecutar "Generar Reporting" y comprobar que termina bien. Anotar las versiones Delta nuevas de las tres tablas históricas.
- [ ] **Paso 7:** exportar, `--comprobar`, commit `feat(orquestacion): maestros en el pipeline de datos y modelos solo tras gold correcto`.

### Tarea 3: pipeline padre "Cierre mensual"

**Ficheros:**
- Crear (lo crea la exportación): `reporting-financiero/fabric/Cierre mensual.DataPipeline/`.
- Test: `reporting-financiero/tests/test_orquestacion_fabric.py`.

- [ ] **Paso 1 [repo]: test que falla.** `test_cierre_mensual_encadena_datos_y_ficheros`: el pipeline tiene dos actividades que invocan pipelines, la primera a Generar Reporting y la segunda a Grabar salidas; la segunda depende de la primera con `["Succeeded"]` y las dos esperan a que termine el hijo (`waitOnCompletion` verdadero). El test identifica los hijos por su id, no por el nombre de la actividad.
- [ ] **Paso 2:** el test falla (no existe la carpeta).
- [ ] **Paso 3 [Fabric]:** crear "Cierre mensual" en el workspace con esas dos actividades (`publicar_fabric.py` no crea items).
- [ ] **Paso 4:** exportar; el test pasa. Si el tipo o los campos de la actividad no coinciden con lo que comprueba el test, ajustar el test al JSON real, nunca al revés.
- [ ] **Paso 5 [Fabric]:** ejecutar "Cierre mensual" una vez y comprobar que "Grabar salidas" no arranca si "Generar Reporting" falla (forzar el fallo no es necesario: basta con ver la dependencia en la ejecución).
- [ ] **Paso 6:** commit `feat(orquestacion): pipeline padre Cierre mensual`.

### Tarea 4: UDF sin secreto y versionadas (bloqueada hasta decidir con IT de Tinkle)

- [ ] **Paso 1 [Fabric, IT de Tinkle]:** elegir conexión gestionada o Key Vault, dar de alta la credencial y rotar el secreto actual.
- [ ] **Paso 2 [Fabric]:** cambiar las UDF: `Generar_txt` lanza "Cierre mensual"; `Ejecución Reporting` sigue con "Generar Reporting"; las dos consultan el estado del job hasta que termina y devuelven el estado final.
- [ ] **Paso 3 [repo]: test que falla.** En `tests/test_fabric_comun.py`: `UserDataFunction` está en `FORMATOS`; y un test que falla si algún fichero de `fabric/*.UserDataFunction/` contiene `ClientSecretCredential` o un literal con forma de secreto de Entra ID.
- [ ] **Paso 4 [repo]:** añadir `UserDataFunction` a `FORMATOS` y quitar su exclusión en `solo_items`, `es_exportable` y `publicar_fabric.py`.
- [ ] **Paso 5:** exportar; los tests pasan. Borrar el respaldo de `.secretos/udf/`.
- [ ] **Paso 6:** commit `feat(udf): UDF sin secreto, versionadas y esperando al final del job`.

### Tarea 5: vault, diagramas y cierre

- [ ] **Paso 1:** ADR 0001 a estado "aceptada" en la rama; merge en `main` (preguntando); en `main`, refresco del vault con la skill `refresco-vault` (saldrán STALE `lineage.md`, `architecture.md`, `configuration.md` y `quality.md` de rf-fabric y lo tocado de rf-scripts), con `test_linaje_vault.py` en verde.
- [ ] **Paso 2:** diagramas con `docs/prompts/PROMPT_diagramas_docenteo.md`.
- [ ] **Paso 3:** etiqueta de cierre, push con aprobación y borrado de la rama (local y remota, con aprobación).
