# Prompt para nueva conversación: construir Generar_txt_Pendiente_Facturar (Tinkle Financiero)

Pega esto tal cual al abrir la nueva conversación.

---

Voy a construir en Microsoft Fabric el proceso de generación del TXT de **Pendiente_Facturar** para el proyecto de Reporting Financiero de Tinkle, replicando un patrón ya existente (Balance) que funciona en producción. Tengo acceso al MCP de Fabric (`fabric-local`) y a Asana. Te doy solo hechos verificados; lo que no está verificado lo marco explícitamente como pregunta abierta. No asumas ni inventes nada de lo marcado como abierto: pregúntamelo antes de escribir la lógica definitiva.

## 1. Patrón técnico ya confirmado (funciona para Balance, replicable tal cual)

- Workspace Fabric: **"Tinkle - Financiero"**. Lakehouse: **lh_tinkle_financiero**. SQL Analytics Endpoint, esquema **200** para datos consolidados/intermedios.
- El pipeline **"Grabar salidas"** tiene, para Balance: actividad **Notebook** (ejecuta `Generar_txt_Balance_Saldos`) → actividad **Copy data** ("Grabar balance").
- Configuración exacta de esa actividad Copy data (verificada en el portal):
  - **Source**: conexión "Lakehouse reporting (Preview)", Lakehouse `lh_tinkle_financiero`, Root folder = Files, Wildcard file path = `Exportaciones/Balance` / `*.txt`, Recursively = true, formato Binary.
  - **Destination**: conexión "SharePoint reporting" (SharePoint Online File), File path = `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, formato Binary.
- Para replicar en Pendiente_Facturar: el notebook debe escribir en `Files/Exportaciones/Pendiente_Facturar/...` dentro del Lakehouse, y hay que añadir una segunda actividad Notebook + Copy data al pipeline con Source `Exportaciones/Pendiente_Facturar` y Destination `.../2. Salida de ficheros/Pendiente_Facturar`.
- Mecánica de escritura de fichero ya validada y reutilizable tal cual (viene del notebook de Balance): `coalesce(1)`, `header=True`, `delimiter=";"`, `encoding=UTF-8`, `quote`/`escape` deshabilitados (`\u0000`), `lineSep="\n"`, luego mover el `part-*` generado por Spark a la ruta final con `notebookutils.fs`.

## 2. Mapeo de sociedades (confirmado, viene del notebook de Balance)

```
ESP066 -> TINKLE_COMM
ESP067 -> TINKLE_EU
ESP068 -> TINKLE_JAZZ
ESP069 -> TINKLE_ONION
ESP070 -> TINKLE_CONS
```

## 3. Layout REAL del fichero de Pendiente_Facturar (verificado contra ficheros TXT reales de marzo 2026, no supuesto)

Ruta de los ficheros de ejemplo reales, ya en el proyecto:
`otros/2026 03 - 0001 Magnitude Marzo/Pendiente_Facturar/03 MAR-26/*.txt` (uno por sociedad, 5 ficheros, muy pocas filas — entre 16 y 17 líneas de datos en la sociedad de ejemplo revisada).

Nombre de fichero real observado: `TINKLE_COMM_Pendiente_Facturar_MAR-26_20260401_105108.txt` → patrón `{SOCIEDAD}_Pendiente_Facturar_{MES-AA}_{timestamp:%Y%m%d_%H%M%S}.txt`.

Formato: CSV separado por `;`, cabecera **en minúsculas** (igual que Ageing), codificación ASCII/UTF-8, fin de línea `\n`. Mismo layout de 26 columnas + 1 residual que Ageing/Revenue, mismo orden de campos.

Columnas exactas observadas (48 filas de datos en total entre los 5 ficheros de la muestra):

| # | Columna    | Contenido observado |
|---|------------|----------------------|
| 0 | D_CA       | Fijo: `C` |
| 1 | D_DP       | Periodo, formato `AAAA.M` (ej. `2026.3`) |
| 2 | D_RU       | Código de sociedad (`ESP066`...`ESP070`) |
| 3 | D_DEVTR    | Siempre vacío |
| 4 | D_SAJOB    | Siempre vacío |
| 5 | D_DIM2     | Siempre vacío |
| 6 | D_DIM3     | Siempre vacío |
| 7 | D_ACTY     | Siempre vacío |
| 8 | D_CLIENT   | Código corto de cliente tipo MMS/Oracle (45 valores distintos en la muestra) — mismo tipo de código que en Ageing/Revenue |
| 9 | D_PE       | Igual que D_DP |
| 10| D_ORU      | Siempre vacío |
| 11| D_AC       | Fijo: `MB4000` (misma cuenta que Ageing) |
| 12| D_FL       | Fijo: `GRWIP` en el 100% de las filas de la muestra (WIP = Work In Progress, no facturado) |
| 13| D_AU       | Fijo: `0LIA01` |
| 14| D_T1       | Siempre vacío |
| 15| D_T2       | Siempre vacío |
| 16| D_CU       | Fijo: `EUR` |
| 17| D_TO       | Siempre vacío |
| 18| D_GO       | Siempre vacío |
| 19| D_LE       | Siempre vacío |
| 20| D_NU       | Siempre vacío |
| 21| D_DIM4     | Siempre vacío |
| 22| D_DEST     | Siempre vacío |
| 23| D_AREA     | Siempre vacío |
| 24| P_COMMENT  | Siempre vacío |
| 25| P_AMOUNT   | Importe numérico, aquí con **coma** decimal en la muestra (ej. `7,30`, `0,42`) — a diferencia de Ageing/Revenue, que usan punto. Verificar si es un error puntual del fichero de marzo o el formato real esperado. |
| 26| (vacío)    | Columna residual |

## 4. Reglas de negocio confirmadas por transcripción de reunión (Josep Zoppetti — testimonio verbal, no verificado contra datos)

- Esto **no sale de contabilidad ni del módulo de Aging**: Josep lo explica con detalle usando **MMS**. Cita textual (resumida): "para ver en realidad que tengo pendiente de facturar... la información que uso son los filtros: en la fecha de factura, si pongo un espacio en blanco, si no tiene fecha de factura es que no está facturado". También usa el campo de **estado de la orden** en MMS (valores tipo `F`=facturado, `C`, "emitido", "iniciado"...) para filtrar qué está pendiente de facturar.
- Es una partida delicada a nivel de auditoría: hay importes "pendientes de facturar" de años anteriores (2024, 2025) que los auditores cuestionan si no se resuelven ("cómo puede ser que tú tuvieras una previsión cuando cerraste 2024 y todavía la tienes pendiente de facturar"). Esto sugiere que el fichero probablemente deba incluir partidas de **cualquier periodo/año con trabajo no facturado**, no solo del mes en curso — no confirmado si el TXT de Grupo hace ese corte histórico o solo el acumulado del cierre actual.

## 5. Datos disponibles en el Lakehouse (esquema 200) para construir esto

- **Confirmado contra el esquema real** (`documentacion/esquema_lh_tinkle_financiero_100_200.tsv`): la tabla `MMS` (esquema 200, 192 columnas — la más ancha del lakehouse) tiene, entre otras, estas columnas relevantes:
  - `Compañia` (relacionada en el modelo semántico con `Dim_Sociedades.Sociedad_MMS`, según la documentación del proyecto)
  - `Cod. Cliente`, `Cliente`, `ClienteKey_MMS`
  - `Estado Orden` (el campo que menciona Josep: valores tipo F/C/emitido/iniciado)
  - `Nº Factura Cli.`, `Fecha Factura Cli.` (el campo clave: en blanco = no facturado, tal como describe Josep), `Fecha Envio Factura Cli.`, `Fecha Cobro Factura Cli.`, `Fecha Vto. Factura Cli.`
  - `IMPORTE`, `PERIODO`
  - Hay también campos equivalentes del lado proveedor (`Factura Proveedor`, `Fecha Factura Prov.`, `Fecha Pago Factura Prov.`, `Imp. Total Factura Proveedor`) por si Pendiente_Facturar tuviera también una vertiente de proveedores (no confirmado que la tenga, en la muestra de marzo solo vimos sociedad/cliente, no un tipo Proveedores).
  - Esto confirma con bastante seguridad la regla de negocio de la sección 4: filtrar por `Fecha Factura Cli.` nulo (o `Estado Orden` distinto de facturado) y sumar `IMPORTE` agrupado por `Compañia` + `Cliente`.
- **No existe ninguna vista `vw_Export_Pendiente_Facturar`** en el SQL Analytics Endpoint (verificado: solo existen `vw_Export_Grupo`, `vw_Export_Saldos_4_7` y `vw_Reporting_Actuals`).
- **Verificado por consulta SQL que `vw_Export_Grupo` NO contiene** filas con `D_AC = 'MB4000'` (la misma cuenta que usa Ageing). Pendiente_Facturar no está oculto dentro de esa vista.

## 5bis. Comprobación en vivo (2026-09-30): la hipótesis simple NO reproduce el fichero real

Se probó `SELECT ... FROM [200].[MMS] WHERE [Fecha Factura Cli.] IS NULL AND [PERIODO]=202603 AND [Compañia] LIKE '%COMMUNICATIONS%'` y el resultado **no se parece** al fichero de ejemplo de marzo:
- Salen importes grandes y variados (`3686`, `8447.42`, `9000`, `-11000`, `-178`...) con signos mezclados, varias líneas por cliente — el fichero real tenía una única línea pequeña y siempre positiva por cliente (ej. `REPSOL01 = 45.12`, no varias líneas con miles de euros).
- `Estado Orden` tiene 9 valores distintos entre las filas con factura en blanco: `P` (12.967 filas), `C` (3.887), `I` (1.680), `FP` (499), `E` (169), `pfP` (105), `pf` (45), `P#` (5), `p` (3). No sabemos el significado de negocio de ninguno de estos códigos, ni cuáles (si alguno) corresponden a "pendiente de facturar" en el sentido que describía Josep.

**Conclusión: la hipótesis "factura en blanco + periodo actual" está descartada tal cual.** El cálculo real debe ser distinto (probablemente una agregación o comparación distinta, no una simple suma de líneas de `MMS` del mes), y no se puede seguir adivinando por SQL — hace falta que alguien de Tinkle (Josep) explique en detalle, con un ejemplo real delante, cómo se llega exactamente a esas 16-17 líneas pequeñas por sociedad.

**Segunda comprobación (2026-09-30), desagregando por `Estado Orden`**: se sumó `IMPORTE` agrupado por `Estado Orden` para el mismo filtro (TINKLE_COMM, `PERIODO`=202603, factura en blanco):

| Estado Orden | Total | Filas |
|---|---|---|
| I | 246.053,14 | 33 |
| FP | 112,44 | 5 |
| E | -55.982,63 | 16 |
| P | -158.746,60 | 135 |
| C | -213.127,50 | 88 |

El objetivo era reproducir **257,13** (suma de las 16 líneas reales de TINKLE_COMM en el fichero de marzo). **Ningún estado, ni combinación evidente de ellos, se acerca ni en orden de magnitud ni en signo.** Esto confirma que el problema no es "qué `Estado Orden` incluir": la aproximación entera de "sumar `IMPORTE` de `MMS`" está mal planteada. Hay que abandonar esta vía por SQL y pedir la explicación directa a Tinkle.

## 6. Preguntas abiertas que hay que resolver ANTES de dar la lógica por buena (no las asumas)

1. **La más importante, y ya no es una simple verificación SQL**: pedirle a Josep/Álvaro que reproduzca en vivo, con el fichero de marzo delante, de dónde sale cada una de esas 16-17 líneas para TINKLE_COMM (ej. por qué `REPSOL01` da exactamente `45.12` y no otro importe). Sin eso, seguir probando filtros por SQL es adivinar a ciegas — ya se descartó la hipótesis obvia (sección 5bis).
2. Qué significa cada valor de `Estado Orden` (`P`, `C`, `I`, `FP`, `E`, `pfP`, `pf`, `P#`, `p`) y cuáles cuentan como "pendiente de facturar".
3. ¿El importe usa coma o punto decimal? El fichero de ejemplo de marzo usa coma, distinto de Ageing/Revenue que usan punto — confirmar si es así siempre o es una particularidad de ese fichero.
4. ¿El fichero incluye partidas de periodos/años anteriores (2024, 2025 pendientes) o solo del cierre del mes en curso?
5. ¿Cómo se traduce `Cod. Cliente`/`ClienteKey_MMS` al código corto `D_CLIENT` del fichero (`01500400`, `16300001`, `AMAZO594`...)? (Puede que sea directamente `Cod. Cliente`, o que haga falta pasar por `Dim_Clientes.ClienteKey_MMS`/`Cliente MMS` — verificar; recordar que `Dim_Clientes` para IKEA dio `18956`, no `IKEA`, así que probablemente tampoco sea la fuente directa de este código).

## 7. Qué quiero que hagas

Ayúdame a: (a) conseguir las respuestas a la sección 6 (dime qué consulta SQL o revisión en el portal de Fabric hace falta para cada una), y (b) una vez resueltas, construir el notebook `Generar_txt_Pendiente_Facturar` que genere exactamente el layout de la sección 3, validado línea a línea contra los ficheros reales de `otros/2026 03 - 0001 Magnitude Marzo/Pendiente_Facturar/03 MAR-26/`.
