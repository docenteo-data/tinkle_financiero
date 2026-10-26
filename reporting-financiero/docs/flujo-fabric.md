# Flujo de trabajo con Fabric

Cómo se lee, se cambia y se versiona el workspace de Fabric "Tinkle - Financiero" desde este repositorio. Vale para personas y agentes. Los scripts están en `reporting-financiero/scripts/` y se ejecutan desde la raíz del repositorio con `reporting-financiero/.venv/Scripts/python.exe`.

El workspace es el único entorno del cliente: no hay desarrollo ni pruebas separados. Todo lo que se publica lo ven los usuarios de la app "Tinkle - Financiero".

## 1. Qué representa cada rama

- `main` refleja lo publicado en Fabric. Solo recibe definiciones que ya están publicadas y validadas en Fabric, por merge `--no-ff` desde la rama del proyecto.
- `reporting-financiero` es la rama de trabajo: cambios preparados en el repositorio que aún no están en Fabric, y exportaciones pendientes de integrar en `main`.
- Cada commit de `main` es un punto al que se puede volver con un rollback (sección 6).

## 2. Qué vía usar para cada cosa

| Necesidad | Vía | Escribe en Fabric |
|---|---|---|
| Inventario de items, esquema de tablas del lakehouse, shortcuts, ficheros de OneLake, documentación de la API | MCP `fabric-local` | No |
| Lógica: consultas M de los dataflows, medidas DAX y relaciones, pipelines, notebook, páginas de informes, vistas SQL y columnas de las tablas | Ficheros de `reporting-financiero/fabric/` en el repositorio (`fabric/sql/` y `fabric/lakehouse/esquema.tsv` para el lakehouse) | No |
| Saber si el repositorio está al día con Fabric | `exportar_fabric.py --comprobar` | No |
| Datos: filas, recuentos, cuadres de cifras | `consultar_sql.py` (solo SELECT y WITH) | No |
| Traer al repositorio lo publicado en Fabric | `exportar_fabric.py` | No |
| Publicar un cambio preparado en el repositorio, o volver a una versión anterior | `publicar_fabric.py` (simulación por defecto, `--confirmar` para publicar) | Sí |
| Ejecutar pipelines, refrescar modelos, publicar la app, cambiar permisos | Una persona del equipo, en el portal | Sí |
| Código de las User Data Functions | Ninguna: llevan un secreto incrustado | |

Reglas:

- La lógica se lee primero en `fabric/`, no en Fabric. Si hay que asegurarse de que está vigente, `exportar_fabric.py --comprobar main`.
- Las herramientas del MCP que escriben (crear, actualizar o borrar items, workspaces, shortcuts o ficheros, ejecutar pipelines) están bloqueadas en `.claude/settings.json`. Para escribir solo se usa `publicar_fabric.py`.
- `fabric-local` no devuelve definiciones de items ni ejecuta SQL: para eso están los ficheros de `fabric/` y `consultar_sql.py`.
- El MCP remoto `fabric` y GitHub Copilot no forman parte del flujo.

## 3. Cuenta

Fabric, el MCP `fabric-local` y los scripts usan la cuenta por defecto de Azure CLI, que debe ser `reporting@likuit.com` (tenant `74ab7d37-cd81-40fd-82e4-cd9c35f4345a`).

- Comprobar: `az account show --query "[user.name, tenantId]" -o tsv`.
- Cambiar: `az account set --subscription 74ab7d37-cd81-40fd-82e4-cd9c35f4345a`. La sesión se inicia una vez con `az login` (si caduca, otra vez).
- Los scripts lo comprueban solos y paran con código 2 si la cuenta no es la de Tinkle. Antes de usar el MCP, el agente lo comprueba con el comando de arriba; si la cuenta es otra, para y avisa en vez de cambiarla, porque la persona puede estar usándola en otro proyecto.

## 4. Al empezar a trabajar

1. `git fetch` y `git log HEAD..origin/main --oneline`. Si hay commits nuevos, se dice a la persona y se le sugiere integrarlos. Nunca `git pull` ni `git push` sin su confirmación.
2. `git branch --show-current`: se trabaja en `reporting-financiero`.
3. Comprobar la cuenta (sección 3).
4. `exportar_fabric.py --comprobar main`. Código 0: Fabric coincide con `main`. Código 1: alguien ha cambiado Fabric sin pasarlo al repositorio; antes de nada, flujo A desde el paso 3.

## 5. Flujos de cambio

### Flujo A: el cambio se hace en Fabric (portal o Power BI Desktop)

1. Lo hace una persona del equipo.
2. Se valida en Fabric (informe, refresco, cifras de control).
3. `exportar_fabric.py` en `reporting-financiero`.
4. Revisar `git status` y `git diff`: solo deben aparecer los items tocados. Commit: `feat(fabric): ...` o `fix(fabric): ...`, con qué cambia y por qué.
5. Merge `--no-ff` en `main`, preguntando antes. Push con confirmación.
6. `exportar_fabric.py --comprobar main` debe dar 0.

### Flujo B: el cambio se prepara en el repositorio (con IA)

1. En `reporting-financiero`, editar los ficheros de `fabric/<Item>/` (TMDL, M, JSON del pipeline o del informe) y hacer commit. Es reversible con git y no toca Fabric.
2. `publicar_fabric.py "<Item>" --ref reporting-financiero` (simulación). Comprueba la cuenta y que Fabric coincide con `main` en esos items, y dice qué cambiaría. Código 1: Fabric ha cambiado desde `main`; hacer antes el flujo A e integrar esos cambios en la rama.
3. Publicar: `publicar_fabric.py "<Item>" --ref reporting-financiero --confirmar`. Requiere la confirmación explícita de la persona en ese momento, item a item, y que no haya nadie cambiando esos items en Fabric.
4. Refrescar o ejecutar en Fabric lo que haga falta para validar (lo hace una persona) y comprobar las cifras de control.
5. `exportar_fabric.py` y `git diff`: lo que devuelve Fabric puede diferir en detalles de formato de lo editado. Commit de esos ajustes.
6. Merge `--no-ff` en `main`, preguntando antes. Push con confirmación.
7. `exportar_fabric.py --comprobar main` debe dar 0.

## 6. Rollback

Para volver un item a como estaba en un commit anterior de `main`:

1. Localizar el commit: `git log --oneline main -- "reporting-financiero/fabric/<Item>"`.
2. Simulación: `publicar_fabric.py "<Item>" --ref <commit>`.
3. Con confirmación de la persona: `publicar_fabric.py "<Item>" --ref <commit> --confirmar`.
4. Validar en Fabric, exportar y commit (`revert(fabric): <Item> a <commit> porque ...`). Merge en `main`.

`publicar_fabric.py` solo actualiza items que ya existen: no crea ni borra items. Tampoco publica las vistas SQL de `fabric/sql/` ni cambia tablas: eso se hace en el portal (flujo A) y la exportación lo trae al repositorio. Un item nuevo se crea en el portal (flujo A) y desde ese momento se versiona como los demás. Publicar la definición no restaura datos: si el cambio afectó a tablas del lakehouse, hay que volver a ejecutar las cargas.

## 7. Consultas SQL

`consultar_sql.py` conecta al SQL endpoint de `lh_tinkle_financiero` (esquemas `100`, `200` y `300`) con el token de Azure CLI.

    reporting-financiero/.venv/Scripts/python.exe reporting-financiero/scripts/consultar_sql.py "SELECT TOP 20 * FROM [300].Dim_Sociedades"
    reporting-financiero/.venv/Scripts/python.exe reporting-financiero/scripts/consultar_sql.py --fichero consulta.sql --csv reporting-financiero/data/resultado.csv

- Solo SELECT y WITH; el script rechaza cualquier escritura (código 2).
- Por consola imprime como mucho 50 filas en ASCII. El resultado completo, con tildes, va a CSV dentro de `reporting-financiero/data/`, que no se versiona.
- Consultas acotadas (`TOP`, filtros por periodo o sociedad). No volcar tablas enteras.
- Los datos obtenidos no se copian a ficheros versionados. `Dim_RRHH` y `Fact_Asignacion_RRHH` contienen salarios: solo agregados, nunca filas por persona en respuestas o documentos.

## 8. Entorno

    python -m venv reporting-financiero/.venv
    reporting-financiero/.venv/Scripts/python.exe -m pip install -r reporting-financiero/requirements.txt

Tests: `reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests`. Con `FABRIC_E2E=1` se ejecutan también los de solo lectura contra Fabric (sincronía de `main` y consultas SQL).
