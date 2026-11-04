# Prompt para nueva conversación: rehacer los diagramas de arquitectura con la marca Docenteo

Pega esto tal cual al abrir la nueva conversación, desde `C:\dev\tinkle_financiero`.

---

Quiero rehacer los diagramas de `reporting-financiero/docs/diagramas/` del proyecto Tinkle Financiero con el design system de Docenteo, corrigiendo los errores que tienen, y añadir uno nuevo de la arquitectura de Balance. El usuario ya ha decidido rehacerlos (no corregir los SVG actuales) y aplicar la marca de Docenteo.

## 0. Antes de empezar

1. Lee `CLAUDE.md` y `AGENTS.md` de la raíz del repo y `reporting-financiero/docs/flujo-fabric.md`. Trabaja en la rama `reporting-financiero`.
2. Comprueba que Azure CLI está en la cuenta `reporting@likuit.com` (`az account show`). Si no, cámbiala con `az account set --subscription 74ab7d37-cd81-40fd-82e4-cd9c35f4345a` (el usuario lo tiene autorizado) y avisa.
3. Comprueba que la copia del repo coincide con Fabric: `reporting-financiero/.venv/Scripts/python.exe reporting-financiero/scripts/exportar_fabric.py --comprobar main` debe decir "Fabric coincide con main". Si no coincide, para y avisa: los hechos de la sección 3 se verificaron contra esa copia el 2026-11-04.
4. **Fuente de verdad: la copia de Fabric en `reporting-financiero/fabric/`**, no los diagramas antiguos ni la documentación. Antes de dibujar cada hecho, compruébalo en el fichero que se cita.

## 1. Marca y herramientas

- Carga la skill `docenteo-skills:docenteo-design` y sigue sus pasos: colores y fuentes solo de `tokens/docenteo-tokens.css`. La documentación técnica (arquitectura) es un tipo de informe de datos.
- Carga la skill `diagram-design:diagram-design` para la gramática de diagramas (tipos, reglas de conectores, presupuesto de complejidad, accesibilidad). Su guía de estilo está con los valores por defecto y no hay perfil guardado: haz su incorporación con la opción "installed skill" (`references/onboarding.md`, sección Skill) usando la skill `docenteo-design` como fuente. Asigna los roles (`paper`, `ink`, `muted`, `accent`, `link`, `rule`) a tokens de Docenteo y sustituye las fuentes de la skill (Instrument Serif, Geist) por las de Docenteo. Enseña el diff de tokens antes de aplicarlo, guárdalo como perfil `docenteo` en `~/.diagram-design/profiles/` y, con confirmación del usuario, escribe el marcador `.diagram-design` con `profile: docenteo` en la raíz del repo.
- Si la marca de Docenteo y la skill de diagramas chocan, manda Docenteo.
- Antes de cada diagrama, di el tipo elegido, el tamaño y lo que el presupuesto de complejidad obliga a dejar fuera (máximo 9 nodos y 12 flechas por diagrama; si se supera, divide en vista general y detalle).

## 2. Entregables

HTML autocontenidos en `reporting-financiero/docs/diagramas/`, que sustituyen a los SVG actuales (bórralos al final; quedan en el historial de Git):

1. **Arquitectura general**: de los extractos de entrada a los consumidores (informes, Planning y ficheros de Grupo), con la orquestación.
2. **Flujo de datos por capas**: qué dataflow escribe cada tabla de las capas 100, 200 y 300. Supera el presupuesto, así que divídelo (por ejemplo, una vista general y un detalle por capa, o un formato de tabla si comunica mejor).
3. **Orquestación**: los dos pipelines y las dos funciones de usuario. El actual es correcto; solo hay que rehacerlo con la marca.
4. **Arquitectura de Balance** (nuevo): de las tablas de la capa 300 a la carpeta de SharePoint donde Finanzas recoge los TXT para subirlos a Magnitude. Opcional: marcar con trazo discontinuo dónde se enchufarían los otros ficheros de Grupo (ver `reporting-financiero/docs/contexto/20261103-estado-ficheros-grupo.md`).

## 3. Hechos verificados (y dónde comprobarlos)

**Entrada**
- No hay conexión directa a Oracle ni a MMS. Todo llega como extractos Excel o CSV que Finanzas deja en una carpeta de OneDrive (`1. Entrada de Datos`, subcarpetas `Arranque` y `Dinamicos`, más `Maestros`), y el lakehouse la lee con un acceso directo (`/Files/Reporting Financiero`). Ver `docs/contexto/Documentacion_Tinkle_Financiero.md` §3 y los `mashup.pq` de los dataflows.

**Dataflows** (`fabric/<nombre>.Dataflow/mashup.pq` y `queryMetadata.json`)
- `INGESTA_Carga_Datos`: carga recurrente a la capa 100. **No carga `New_HAPA`**: su consulta `Carga_New_HAPA_asientos` tiene `loadEnabled = False`.
- `TRANS_Silver`: de la 100 a la 200. `TRANS_Gold`: de la 200 a `Fact_Actuals`, `Dim_Cuentas` y `Dim_Mapeo_Cuentas` (300).
- `INGESTA_Maestros`: `COA_Oracle`, `Mapping Portugal` y `Mapping_HAPA` (200) y casi todas las dimensiones de la 300.
- `INICIAL_*`: cargas iniciales que escriben directamente en la 200 o la 300, sin pasar por la 100. `Oracle_historico`, `Aging_Clientes` y `Aging_Proveedores` tienen dos productores (carga inicial y `TRANS_Silver`). `Dim_CDC` también tiene dos (`INGESTA_Maestros` e `INICIAL_Carga_Rentabilidades`).
- `Seguridad_CDC`: **no escribe nada** (su consulta `RLS` tiene `loadEnabled = False`). La tabla `100.RLS` no tiene productor activo.
- Sin productor: `200.Budget_historico`, `100.RLS` y, en la práctica, `100.New_HAPA`. Aviso aparte: `200.Revenues` está vacía (comprobado con SQL el 2026-09-30).

**Lakehouse `lh_tinkle_financiero`** (`fabric/lakehouse/esquema.tsv` y `fabric/sql/`)
- 100: 7 tablas. 200: 12 tablas, más las vistas `vw_Export_Grupo` y `vw_Export_Saldos_4_7`. 300: 13 tablas, más la vista `vw_Reporting_Actuals`.

**Modelos semánticos** (TMDL en `fabric/*.SemanticModel/definition/tables/`)
- `Financial Model`: Direct Lake sobre tablas de la 200 (`MMS`, `Presupuestos`) y de la 300. `Unidades` y `_Medidas` van en Import.
- `Agings`: **modo Import, no Direct Lake**, sobre `200.Aging_Clientes` y `200.Aging_Proveedores`.
- Informes: `Agings` usa el modelo `Agings`; el resto, `Financial Model`. Todos se publican en la App `Tinkle - Financiero`.
- `Planning` (Revenue FT3, Revenue FT8 y Dedicaciones) usa `Financial Model` y escribe en la base `CPM` (`dbo.FT3_Revenue`, `dbo.FT8_Revenue`). Nada lee de `CPM`.

**Orquestación** (`fabric/*.DataPipeline/pipeline-content.json`)
- La función de usuario `Ejecución Reporting` lanza el pipeline `Generar Reporting`: Carga, refresco del SQL endpoint, Silver, refresco del SQL endpoint, Gold (todas con `Succeeded`), y después los refrescos de `Financial Model` y `Agings`, con `Completed`.
- La función de usuario `Generar_txt` lanza el pipeline `Grabar salidas`: `Notebook1` (notebook `Generar_txt_Balance_Saldos`) y, si termina con `Succeeded`, la copia `Grabar balance`.
- No hay dependencia declarada entre los dos pipelines. No leas ni copies el código de las funciones de usuario: llevan un secreto incrustado.

**Balance** (`fabric/sql/200.vw_Export_*.sql` y `fabric/Generar_txt_Balance_Saldos.Notebook/`)
- `vw_Export_Grupo` lee `300.Fact_Actuals`, `300.Dim_Mapeo_Cuentas` y `300.Dim_Sociedades`. `vw_Export_Saldos_4_7` lee `300.Fact_Actuals` y `300.Dim_Sociedades`. **Ninguna lee `Dim_Cuentas`.**
- El notebook lee esas dos vistas por el SQL endpoint (`spark.read.synapsesql`), no por Direct Lake. Escribe dos ficheros por sociedad en `Files/Exportaciones/Balance/{periodo}/`: Balance (CSV con `;`) y Saldos 4_7 (informe de ancho fijo con CRLF).
- La copia `Grabar balance` lleva `Exportaciones/Balance/*.txt` (recursivo) a `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance` en SharePoint, conservando las carpetas. Después, Finanzas sube los TXT a Magnitude a mano.

## 4. Errores de los diagramas antiguos que no hay que repetir

- 01: la rama del notebook sale de `Dim_Cuentas`; faltan las vistas; Notebook, Copy y pipeline aparecen en secuencia cuando el pipeline contiene a los otros dos; `New_HAPA` y `RLS` aparecen con productor; `Dim_CDC` con un solo productor; "Direct Lake" sale solo de la capa 300.
- 02: Oracle y MMS como fuentes conectadas; "todos los dataflows escriben en el lakehouse"; "300 Gold (12 tablas)" en vez de 13; la flecha "dispara" va del lakehouse a la orquestación (al revés); "Direct Lake" sale del bloque de orquestación y se aplica también a `Agings`; falta la salida de ficheros de Grupo.

## 5. Comprobaciones antes de dar nada por terminado

- `bash "<skill docenteo-design>/scripts/comprobar-tokens.sh" "<archivo>"` sin salida, y `node "<skill docenteo-design>/scripts/comprobar-render.mjs" "<archivo>"` con `OK`.
- `python scripts/self_check.py <archivo>` de la skill de diagramas, y la lista de comprobación de su sección 9 (conectores ortogonales, etiquetas con máscara, sin solapes, accesibilidad).
- Cada nodo y cada flecha se puede justificar con un fichero de la sección 3.
- Texto en español con ortografía completa; sin rayas largas, flechas tipográficas ni comillas tipográficas.
- Enlaza los diagramas nuevos donde se citaban los antiguos (busca `diagramas/` en `reporting-financiero/docs/`).
- Commit en `reporting-financiero` con mensaje `docs(diagramas): ...`. Haz push solo con confirmación del usuario.
