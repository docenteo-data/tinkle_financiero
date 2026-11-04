# Pipelines modulares, flujos y vistas de salida - plan de implementación

> **Para agentes:** se ejecuta con `superpowers:subagent-driven-development`. Según `CLAUDE.md`, cada paso **[repo]** va a un subagente Haiku, uno por fichero y entregable; la sesión principal valida cada fase con sus checks antes de commitear. Los pasos **[Fabric]** los hace una persona del equipo (AGENTS.md: los agentes no ejecutan, publican ni refrescan en Fabric salvo que la tarea lo pida). Los pasos **[publicar]** los lanza la sesión principal con `publicar_fabric.py ... --confirmar`, solo tras la aprobación explícita del usuario en ese momento.

**Objetivo:** pipelines modulares que se prueban por separado, flujos que los encadenan, botones coherentes en los informes y vistas de salida en el esquema 300.

**Decisión:** `vault/adrs/0001-orquestacion-y-vistas-de-salida.md` (propuesta hasta que el usuario apruebe este plan).

**Tecnología:** Fabric (pipelines, notebook, SQL endpoint, informes PBIR, UDF), scripts de `reporting-financiero/scripts/`, pytest.

## Restricciones globales

- Rama `feature/orquestacion-y-vistas` (creada desde `main` en `4e67d7f`). El ADR viaja con la rama; el resto del vault se refresca en `main` tras integrar. Sin push sin aprobación justo antes.
- Se publica desde la rama: `publicar_fabric.py "<Item>" --ref feature/orquestacion-y-vistas` (simulación) y, con aprobación, `--confirmar`. Tras validar en Fabric: `exportar_fabric.py` en la rama, revisar `git diff`, commit.
- `publicar_fabric.py` no crea ni borra items: los items nuevos los crea vacíos una persona en Fabric, se exportan y después se rellenan desde el repo.
- Nombres de items exactos: `Ingesta_datos`, `Transformacion_datos`, `Refresco_modelos`, `Generar_salidas`, `Flujo_actualizar_datos`, `Flujo_total_reporting`, `Flujo_total_txt`. No se renombra ningún item existente.
- Identificadores (sección 1 de `docs/contexto/Documentacion_Tinkle_Financiero.md` y definiciones actuales): workspace `b31820dc-4b4f-4696-9a96-bbee438e9306`; dataflows INGESTA_Carga_Datos `c8d12168-9a15-4df6-8632-eb647c58a861`, INGESTA_Maestros `60412b6d-8169-49a4-b6b9-0a5b8ec6e0f6`, TRANS_Silver `e34a567e-3986-467e-ac59-9c89b8014b87`, TRANS_Gold `2ddb6bc7-1a91-490f-9a6b-60ade6940b4e`; modelos Financial Model `847ce270-06ab-408b-85c9-cb8f390fad1c`, Agings `e19def87-fdf3-4b44-bd60-d22e5d79ce88`; notebook `c649ae24-2b54-4fce-bd5c-d23a9516ec37`.
- Actividades: las mismas `type`, `typeProperties` y `policy` que las de "Generar Reporting" y "Grabar salidas" (se copian de esos JSON); todas las dependencias con `["Succeeded"]`.
- El código de las UDF no se lee ni se imprime mientras lleve el secreto. Respaldo en `.secretos/udf/2026-11-04/` (ignorado por Git).
- Pruebas: cada pipeline modular se prueba solo en Fabric (`ejecutar_fabric.py --confirmar`, con aprobación) antes de montar flujos encima.
- Antes de ejecutar cualquier pipeline que escriba datos: apuntar aquí las filas y la versión Delta de las tablas que escribe, y una cifra de control si aplica. Después, compararlas.

## Punto de partida (04/11/2026)

- `exportar_fabric.py --comprobar main`: código 0.
- Versiones Delta, para recuperar con time travel (`RESTORE TABLE`): `200.Oracle_historico` v25, `200.HAPA` v24, `200.MMS` v42. Última escritura de las tres: 15/09/2026.

### Ingesta_datos (04/11/2026, Completed)

Recuentos antes y después, reconstruidos del registro Delta (no se apuntaron antes de lanzar): sin cambios en ninguna tabla, así que los ficheros de entrada eran los mismos que en la última carga.

| Tabla | Versión antes | Versión después | Filas antes y después |
|---|---|---|---|
| 100.New_Oracle | v36 (15/09) | v37 | 12.850 |
| 100.New_MMS | v11 (15/09) | v12 | 16.533 |
| 100.New_HAPA | v16 (15/09) | v17 | 103 |
| 100.New_PT_extrato_contas | v33 (15/09) | v34 | 1.434 |
| 100.New_Agings_Clientes | v5 (15/09) | v6 | 815 |
| 100.New_Agings_Proveedores | v6 (15/09) | v7 | 708 |
| 200.Mapping_HAPA, 200.Mapping Portugal, 200.COA_Oracle | 21/08 | +1 | 374, 83, 657 |
| 300.Dim_CDC, Aux_CDC, Dim_Clientes, Dim_RRHH, Dim_Sociedades, Dim_Report_Line, Map_Report_Line_Account, Dim_Calendar | 21/08 | +1 | 15, 40, 675, 289, 7, 480, 1.580, 4.018 |

### Antes de Transformacion_datos (04/11/2026)

| Tabla | Filas |
|---|---|
| 200.Oracle_historico (v25) | 32.868 |
| 200.HAPA (v24) | 103 |
| 200.MMS (v42) | 37.898 |
| 200.Portugal | 1.434 |
| 200.Aging_Clientes | 815 |
| 200.Aging_Proveedores | 708 |
| 300.Fact_Actuals | 34.405 |
| 300.Dim_Cuentas | 657 |
| 300.Dim_Mapeo_Cuentas | 1.114 |

Control de `300.Fact_Actuals`: suma de `Saldo` 72.423.595.604,55; último periodo 2026-03-01.

### Transformacion_datos (04/11/2026, Completed)

Mismas filas en las 9 tablas y la misma cifra de control de `300.Fact_Actuals` (72.423.595.604,55; 2026-03-01). Versiones nuevas: `200.Oracle_historico` v26, `200.HAPA` v25, `200.MMS` v43, `300.Fact_Actuals` v24. Para volver al estado anterior: v25, v24, v42 y v23.

### Antes de Refresco_modelos (04/11/2026)

- Financial Model (Direct Lake): último refresco `DirectLakeFraming` Completed el 24/09/2026 11:07 UTC; `COUNTROWS(Fact_Actuals)` = 34.405.
- Agings (import): sin historial de refrescos en la API; `200 Aging_Clientes` = 815 filas y `200 Aging_Proveedores` = 708.

## Revisión (riesgos que ningún test cubre)

1. Las vistas nuevas devuelven distinto que las viejas: se cubre con la comparación EXCEPT de la tarea 1.
2. "Generar txt" lanzado sobre datos viejos: se cubre con la comprobación de periodo de la tarea 3.
3. Un flujo lanza el siguiente pipeline sin esperar a que termine el anterior: test de `waitOnCompletion` en la tarea 4.
4. INGESTA_Maestros falla por un `Maestros.xlsx` mal subido y ahora para la ingesta: es lo buscado, pero hay que avisar a Finanzas.
5. Dos personas pulsan botones a la vez (por ejemplo, "Actualizar datos" y "Generar txt"): Fabric no lo impide. Se documenta en la guía de uso de la tarea 5.

---

### Tarea 1: vistas de salida en el esquema 300

**Ficheros:** crear `fabric/sql/300.vw_Export_Grupo.sql` y `fabric/sql/300.vw_Export_Saldos_4_7.sql` (cuerpo de las de 200, cambiando solo el esquema de la vista); modificar el notebook `Generar_txt_Balance_Saldos` (sus dos lecturas `200.vw_Export_*` pasan a `300.vw_Export_*`). Test: `reporting-financiero/tests/test_orquestacion_fabric.py`.

- [ ] **[repo] Test que falla:** `test_ficheros_leen_vistas_de_300` (el notebook contiene `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` y no `200.vw_Export`) y `test_vistas_de_salida_en_300` (existen los dos `.sql` de 300 y no los de 200).
- [ ] **[Fabric]** Crear las dos vistas en `[300]` con el SQL de los ficheros nuevos.
- [ ] **[sesión]** Comparar viejas y nuevas con `consultar_sql.py`: `SELECT COUNT(*) FROM (SELECT * FROM [200].vw_Export_Grupo EXCEPT SELECT * FROM [300].vw_Export_Grupo) x`, en los dos sentidos y para las dos vistas. Esperado: 0 en los cuatro.
- [ ] **[repo] y [publicar]** Cambiar el notebook y publicarlo.
- [ ] **[Fabric]** Ejecutar "Grabar salidas" y comparar los TXT con los de la ejecución anterior (igual salvo la marca de tiempo). Si coinciden, borrar las vistas de `[200]`.
- [ ] Exportar, tests en verde, commit `feat(orquestacion): vistas de salida en el esquema 300`.

### Tarea 2: pipelines de datos y modelos (`Ingesta_datos`, `Transformacion_datos`, `Refresco_modelos`)

Un subagente por pipeline. Test: `test_orquestacion_fabric.py`.

- [ ] **[Fabric]** Crear los tres pipelines vacíos y exportar (aparecen sus carpetas en `fabric/`).
- [ ] **[repo] Tests que fallan:**
  - `test_ingesta_datos`: dos `RefreshDataflow` (INGESTA_Maestros e INGESTA_Carga_Datos) sin dependencias y un `RefreshSqlEndpoint` que depende de los dos con `["Succeeded"]`.
  - `test_transformacion_datos`: TRANS_Silver, endpoint SQL, TRANS_Gold y endpoint SQL, en ese orden, cada uno dependiente del anterior con `["Succeeded"]`.
  - `test_refresco_modelos`: dos `PBISemanticModelRefresh` (Financial Model y Agings) sin dependencias entre sí.
  - Los tests identifican dataflows y modelos por su id, no por el nombre de la actividad.
- [ ] **[repo]** Rellenar los tres `pipeline-content.json` copiando actividades de "Generar Reporting".
- [ ] **[publicar]** Los tres pipelines.
- [ ] **[Fabric]** Ejecutar cada uno por separado, en orden, y comprobar que termina bien. Anotar las versiones Delta nuevas de las tres tablas históricas.
- [ ] Exportar, commit `feat(orquestacion): pipelines de ingesta, transformación y refresco de modelos`.

### Tarea 3: `Generar_salidas` con parámetro de ficheros y control de periodo

**Ficheros:** el notebook `Generar_txt_Balance_Saldos` y la carpeta nueva `Generar_salidas.DataPipeline/`. Test: `test_orquestacion_fabric.py`.

**Produce:** parámetros del notebook `ficheros` (texto, lista separada por comas; vacío = todos los que sabe generar) y `periodo_esperado` (texto `AAAA.MM`; vacío = sin comprobación). Parámetros del pipeline con los mismos nombres, pasados al notebook.

- [ ] **[Fabric]** Crear `Generar_salidas` vacío y exportar.
- [ ] **[repo] Tests que fallan:**
  - `test_generar_salidas`: una actividad `TridentNotebook` con el id del notebook, que recibe `ficheros` y `periodo_esperado` desde los parámetros del pipeline, y una `Copy` a SharePoint que depende de ella con `["Succeeded"]`.
  - `test_notebook_parametros`: la celda de parámetros del notebook define `ficheros` y `periodo_esperado`.
- [ ] **[repo]** Notebook: genera solo lo pedido en `ficheros`; si `periodo_esperado` no está vacío y no es el último periodo de `300.Fact_Actuals`, lanza un error sin escribir ningún fichero. Pipeline: copiar las actividades de "Grabar salidas" y añadir los parámetros.
- [ ] **[publicar]** Notebook y pipeline.
- [ ] **[Fabric]** Probar tres casos: sin parámetros (salen Balance y Saldos_4_7), `ficheros=Balance` (sale solo Balance) y `periodo_esperado` distinto del cargado (falla sin ficheros nuevos).
- [ ] Exportar, commit `feat(orquestacion): Generar_salidas con elección de ficheros y control de periodo`.

### Tarea 4: flujos (`Flujo_actualizar_datos`, `Flujo_total_reporting`, `Flujo_total_txt`)

- [ ] **[Fabric]** Crear `Flujo_actualizar_datos` en el portal con dos actividades de invocar pipeline (`Ingesta_datos` y después `Transformacion_datos`). Comprobar si un flujo puede invocar a otro flujo: si puede, `Flujo_total_reporting` y `Flujo_total_txt` invocan `Flujo_actualizar_datos` y después `Refresco_modelos` o `Generar_salidas`; si no, invocan los modulares directamente. Exportar.
- [ ] **[repo] Test:** `test_flujos`: en cada flujo, las actividades invocan los pipelines del ADR en ese orden (por id), cada una depende de la anterior con `["Succeeded"]` y espera a que termine (`waitOnCompletion` verdadero). Si el tipo o los campos de la actividad no son los que supone el test, se ajusta el test al JSON real, nunca al revés.
- [ ] **[Fabric]** Ejecutar `Flujo_total_reporting` y `Flujo_total_txt` una vez cada uno.
- [ ] Commit `feat(orquestacion): flujos de actualización, reporting y txt`.

### Tarea 5: UDF y botones (bloqueada hasta decidir con IT de Tinkle dónde va el secreto)

- [ ] **[Fabric, IT de Tinkle]** Elegir conexión gestionada o Key Vault, dar de alta la credencial y rotar el secreto actual.
- [ ] **[Fabric]** UDF: `Ejecución Reporting` lanza `Refresco_modelos`; `Generar_txt` lanza `Generar_salidas` (con `ficheros` y `periodo_esperado` como argumentos opcionales); UDF nueva `Actualizar_datos` lanza `Flujo_actualizar_datos`. Las tres esperan a que el job termine y devuelven el estado final.
- [ ] **[repo] Tests que fallan** en `tests/test_fabric_comun.py`: `UserDataFunction` está en `FORMATOS`; ningún fichero de `fabric/*.UserDataFunction/` contiene `ClientSecretCredential` ni un literal con forma de secreto de Entra ID.
- [ ] **[repo]** Añadir `UserDataFunction` a `FORMATOS` y quitar su exclusión en `solo_items`, `es_exportable` y `publicar_fabric.py`.
- [ ] **[repo] y [publicar]** Botones en la página Home de Agings, Checklist (Oracle), HAPA, MMS y Presupuesto: "Actualizar datos", "Actualizar informes" y "Generar txt", con su UDF. Test `test_botones`: en esas cinco páginas, los tres botones existen y cada uno llama a la UDF que le toca.
- [ ] Guía corta para Finanzas en `reporting-financiero/docs/contexto/guia-botones.md`: qué hace cada botón, orden de uso en el cierre y que no se pulsen dos a la vez.
- [ ] Exportar, tests en verde, borrar el respaldo de `.secretos/udf/`. Commit `feat(udf): UDF sin secreto, versionadas, y botones coherentes`.

### Tarea 6: retirada de los pipelines antiguos

- [ ] **[Fabric]** Con todo lo anterior probado, borrar "Generar Reporting" y "Grabar salidas" del workspace.
- [ ] Exportar (desaparecen sus carpetas), tests en verde, commit `chore(orquestacion): retirada de Generar Reporting y Grabar salidas`.

### Tarea 7: cierre

- [ ] ADR 0001 a "aceptada". Merge `--no-ff` en `main` (preguntando) y `exportar_fabric.py --comprobar main` con código 0.
- [ ] En `main`, refresco del vault con la skill `refresco-vault`; `test_linaje_vault.py` en verde.
- [ ] Diagramas con `docs/prompts/PROMPT_diagramas_docenteo.md`.
- [ ] Etiqueta, push con aprobación y borrado de la rama (local y remota, con aprobación).
