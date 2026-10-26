# Prompt para nueva conversación: construir Generar_txt_Revenue (Tinkle Financiero)

Pega esto tal cual al abrir la nueva conversación.

---

Voy a construir en Microsoft Fabric el proceso de generación del TXT de **Revenue** para el proyecto de Reporting Financiero de Tinkle, replicando un patrón ya existente (Balance) que funciona en producción. Tengo acceso al MCP de Fabric (`fabric-local`) y a Asana. Te doy solo hechos verificados; lo que no está verificado lo marco explícitamente como pregunta abierta. No asumas ni inventes nada de lo marcado como abierto: pregúntamelo antes de escribir la lógica definitiva.

## 1. Patrón técnico ya confirmado (funciona para Balance, replicable tal cual)

- Workspace Fabric: **"Tinkle - Financiero"**. Lakehouse: **lh_tinkle_financiero**. SQL Analytics Endpoint, esquema **200** para datos consolidados/intermedios.
- El pipeline **"Grabar salidas"** tiene, para Balance: actividad **Notebook** (ejecuta `Generar_txt_Balance_Saldos`) → actividad **Copy data** ("Grabar balance").
- Configuración exacta de esa actividad Copy data (verificada en el portal):
  - **Source**: conexión "Lakehouse reporting (Preview)", Lakehouse `lh_tinkle_financiero`, Root folder = Files, Wildcard file path = `Exportaciones/Balance` / `*.txt`, Recursively = true, formato Binary.
  - **Destination**: conexión "SharePoint reporting" (SharePoint Online File), File path = `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, formato Binary.
- Para replicar en Revenue: el notebook debe escribir en `Files/Exportaciones/Revenue/...` dentro del Lakehouse, y hay que añadir una segunda actividad Notebook + Copy data al pipeline con Source `Exportaciones/Revenue` y Destination `.../2. Salida de ficheros/Revenue`.
- Mecánica de escritura de fichero ya validada y reutilizable tal cual (viene del notebook de Balance): `coalesce(1)`, `header=True`, `delimiter=";"`, `encoding=UTF-8`, `quote`/`escape` deshabilitados (`\u0000`), `lineSep="\n"`, luego mover el `part-*` generado por Spark a la ruta final con `notebookutils.fs`.

## 2. Mapeo de sociedades (confirmado, viene del notebook de Balance)

```
ESP066 -> TINKLE_COMM
ESP067 -> TINKLE_EU
ESP068 -> TINKLE_JAZZ
ESP069 -> TINKLE_ONION
ESP070 -> TINKLE_CONS
```

## 3. Layout REAL del fichero de Revenue (verificado contra ficheros TXT reales de marzo 2026, no supuesto)

Ruta de los ficheros de ejemplo reales, ya en el proyecto:
`otros/2026 03 - 0001 Magnitude Marzo/Revenue/03 MAR-26/*.txt` (uno por sociedad, 5 ficheros, entre 5 y 72 líneas de datos según la sociedad).

Nombre de fichero real observado: `TINKLE_COMM_Revenue_MAR-26_20260401_105250.txt` → patrón `{SOCIEDAD}_Revenue_{MES-AA}_{timestamp:%Y%m%d_%H%M%S}.txt`.

Formato: CSV separado por `;`, con cabecera **en mayúsculas** (a diferencia de Ageing, que la lleva en minúsculas), codificación ASCII/UTF-8, fin de línea `\n` (no CRLF). Cada fila (incluida probablemente la cabecera) termina en `;` con un campo vacío residual al final (27 posiciones en total, igual que Ageing).

Columnas exactas, mismo orden que Ageing (26 nombres + 1 residual), con lo observado en los 5 ficheros de ejemplo (172 filas de datos en total):

| # | Columna    | Contenido observado |
|---|------------|----------------------|
| 0 | D_CA       | Fijo: `R` (a diferencia de Ageing/Pendiente_Facturar, que usan `C`) |
| 1 | D_DP       | Periodo, formato `AAAA.M` (ej. `2026.3`) |
| 2 | D_RU       | Código de sociedad (`ESP066`...`ESP070`) |
| 3 | D_DEVTR    | Siempre vacío |
| 4 | D_SAJOB    | Siempre vacío |
| 5 | D_DIM2     | Siempre vacío |
| 6 | D_DIM3     | Siempre vacío |
| 7 | D_ACTY     | Fijo: `GADV` |
| 8 | D_CLIENT   | Código corto de cliente tipo MMS/Oracle (149 valores distintos en la muestra, ej. `AMAZO594`, `ESP036IBE147`) — mismo tipo de código que en Ageing, no el nombre completo |
| 9 | D_PE       | Igual que D_DP |
| 10| D_ORU      | Siempre vacío |
| 11| D_AC       | Fijo: `MP2010` |
| 12| D_FL       | Fijo: `MFYPL` (a diferencia de Ageing, aquí no varía) |
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
| 25| P_AMOUNT   | Importe numérico con **punto** decimal, puede ser negativo (ej. `12.97`, `-506.81`, `0.40`) |
| 26| (vacío)    | Columna residual |

## 4. Reglas de negocio confirmadas por transcripción de reunión (Josep Zoppetti — testimonio verbal, no verificado contra datos)

- En el plan contable, las cuentas de ingresos son la **700** (ventas) y la **705** (servicios de agencia / honorarios). El propio Josep dice: "en reporting de magnitud solo hemos de dar esta información" (honorarios + producción, en una sola cifra agregada), aunque internamente ellos desglosan honorarios vs producción para análisis propio (eso NO va al TXT de Grupo).
- MMS es la fuente que usan internamente para el seguimiento de honorarios/producción por cliente, pero **no está confirmado** que el TXT de Revenue salga de MMS en vez de la contabilidad real — dado que `D_ACTY=GADV` y `D_AC=MP2010` parecen códigos de un extracto contable (similar a Balance), es más probable (no confirmado) que salga de un extracto de cuentas 700/705 de `Fact_Actuals` o equivalente, agregado por cliente.

## 5. Datos disponibles en el Lakehouse (esquema 200) para construir esto

- **Hallazgo importante, verificado contra el esquema real (`documentacion/esquema_lh_tinkle_financiero_100_200.tsv`)**: la tabla `Revenues` (esquema 200, 13 columnas) tiene exactamente estas columnas: `Origen, Compañía, Nombre Cliente, Cliente, Compañía Magnitude, Codigo MMS, Code Magnitude, Empresa, Nombre MMS, Codigo cliente Magnitude, Año, Mes, Valor`.
  - Las columnas **`Codigo cliente Magnitude`** y **`Code Magnitude`** encajan casi con toda seguridad con el tipo de código corto que aparece en `D_CLIENT` (`IKEA`, `01500400`...) — resolvería la pregunta 3 de abajo.
  - `Compañía Magnitude` podría ser directamente el código de sociedad a usar en `D_RU`, o una pieza para deducirlo.
  - `Año` + `Mes` + `Valor` encajan con `D_PE`/`D_DP` + `P_AMOUNT`.
  - Según la documentación de auditoría del proyecto (`documentacion/Documentacion_Tinkle_Financiero.md`, hallazgo M7/N8), **esta tabla no tiene ningún consumidor conocido actualmente** (ningún dataflow, notebook ni modelo semántico la lee) — es decir, nadie ha construido todavía nada sobre ella. Es la candidata más fuerte para ser la fuente de este TXT, pero no está confirmado.
  - **ALERTA verificada en vivo (2026-09-30): la tabla `[200].[Revenues]` está completamente VACÍA (0 filas) en este momento.** `SELECT * FROM [200].[Revenues]` no devuelve nada. Antes de construir nada sobre ella, hay que averiguar por qué: ¿la carga inicial (`INICIAL_Carga_Revenues`) nunca llegó a poblarla correctamente, se vació después, o el fichero origen `Revenue 2026 FT3.xlsx` ya no está donde el dataflow lo espera? Sin datos, esta tabla no sirve de nada tal cual está hoy — sería necesario re-ejecutar o arreglar su ingesta antes de poder usarla como fuente.
- **No existe ninguna vista `vw_Export_Revenue`** en el SQL Analytics Endpoint (verificado: solo existen `vw_Export_Grupo`, `vw_Export_Saldos_4_7` y `vw_Reporting_Actuals`).
- **Verificado por consulta SQL que `vw_Export_Grupo` NO contiene** filas con `D_AC = 'MP2010'`. Revenue no está oculto dentro de esa vista.

## 6. Preguntas abiertas que hay que resolver ANTES de dar la lógica por buena (no las asumas)

1. Confirmar con una consulta `SELECT TOP 20 * FROM [200].[Revenues]` que el contenido real de `Codigo cliente Magnitude` / `Compañía Magnitude` coincide con los valores de `D_CLIENT`/`D_RU` de los ficheros de ejemplo (`IKEA`, `01500400`, `ESP066`...).
2. ¿El importe (`P_AMOUNT`) es el ingreso total (honorarios + producción sumados), o solo una de las dos partidas? Josep menciona que internamente separan ambas pero que a Magnitude solo va una cifra. ¿`Valor` en `Revenues` ya viene agregado así, o hay que sumar varias filas (`Origen` distintos) por cliente/mes?
3. ¿Por qué el número de filas por sociedad varía tanto (de 5 a 72 en la muestra de marzo)? ¿Es simplemente el número de clientes activos ese mes en cada sociedad, o hay algún filtro adicional (ej. solo clientes con importe distinto de cero, o solo ciertas líneas de negocio)?
4. `Revenues` se carga una sola vez desde Excel (`INICIAL_Carga_Revenues`, sin proceso recurrente documentado, según la auditoría) — confirmar si sigue actualizándose mes a mes o si haría falta arreglar/crear su ingesta recurrente antes de poder usarla en producción.

## 7. Qué quiero que hagas

Ayúdame a: (a) conseguir las respuestas a la sección 6 (dime qué consulta SQL o revisión en el portal de Fabric hace falta para cada una), y (b) una vez resueltas, construir el notebook `Generar_txt_Revenue` que genere exactamente el layout de la sección 3, validado línea a línea contra los ficheros reales de `otros/2026 03 - 0001 Magnitude Marzo/Revenue/03 MAR-26/`.
