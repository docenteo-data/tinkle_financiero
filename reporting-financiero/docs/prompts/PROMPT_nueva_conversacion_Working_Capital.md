# Prompt para nueva conversación: construir Generar_txt_Working_Capital (Tinkle Financiero)

Pega esto tal cual al abrir la nueva conversación.

---

Voy a construir en Microsoft Fabric el proceso de generación del TXT de **Working_Capital** para el proyecto de Reporting Financiero de Tinkle, replicando un patrón ya existente (Balance) que funciona en producción. Tengo acceso al MCP de Fabric (`fabric-local`) y a Asana. Te doy solo hechos verificados; lo que no está verificado lo marco explícitamente como pregunta abierta. No asumas ni inventes nada de lo marcado como abierto: pregúntamelo antes de escribir la lógica definitiva. **Esta es el área con menos información recopilada de las cinco pendientes: no aparece mencionada en ninguna de las 5 transcripciones de reunión con Tinkle que tengo disponibles.**

## 1. Patrón técnico ya confirmado (funciona para Balance, replicable tal cual)

- Workspace Fabric: **"Tinkle - Financiero"**. Lakehouse: **lh_tinkle_financiero**. SQL Analytics Endpoint, esquema **200** para datos consolidados/intermedios.
- El pipeline **"Grabar salidas"** tiene, para Balance: actividad **Notebook** (ejecuta `Generar_txt_Balance_Saldos`) → actividad **Copy data** ("Grabar balance").
- Configuración exacta de esa actividad Copy data (verificada en el portal):
  - **Source**: conexión "Lakehouse reporting (Preview)", Lakehouse `lh_tinkle_financiero`, Root folder = Files, Wildcard file path = `Exportaciones/Balance` / `*.txt`, Recursively = true, formato Binary.
  - **Destination**: conexión "SharePoint reporting" (SharePoint Online File), File path = `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, formato Binary.
- Para replicar en Working_Capital: el notebook debe escribir en `Files/Exportaciones/Working_Capital/...` dentro del Lakehouse, y hay que añadir una segunda actividad Notebook + Copy data al pipeline con Source `Exportaciones/Working_Capital` y Destination `.../2. Salida de ficheros/Working_Capital`.
- Mecánica de escritura de fichero ya validada y reutilizable tal cual (viene del notebook de Balance): `coalesce(1)`, `header=True`, `delimiter=";"`, `encoding=UTF-8`, `quote`/`escape` deshabilitados (`\u0000`), `lineSep="\n"`, luego mover el `part-*` generado por Spark a la ruta final con `notebookutils.fs`.

## 2. Mapeo de sociedades (confirmado, viene del notebook de Balance)

```
ESP066 -> TINKLE_COMM
ESP067 -> TINKLE_EU
ESP068 -> TINKLE_JAZZ
ESP069 -> TINKLE_ONION
ESP070 -> TINKLE_CONS
```

## 3. Layout REAL del fichero de Working_Capital (verificado contra ficheros TXT reales de marzo 2026, no supuesto)

Ruta de los ficheros de ejemplo reales, ya en el proyecto:
`otros/2026 03 - 0001 Magnitude Marzo/Working_Capital/03 MAR-26/*.txt` (uno por sociedad, 5 ficheros, **muy pocas filas**: 4 filas de datos en el fichero de ejemplo revisado, 18 filas de datos en total entre los 5 ficheros).

Nombre de fichero real observado: `TINKLE_COMM_Working_Capital_MAR-26_20260401_105012.txt` → patrón `{SOCIEDAD}_Working_Capital_{MES-AA}_{timestamp:%Y%m%d_%H%M%S}.txt`.

Formato: CSV separado por `;`, cabecera en mayúsculas, ASCII/UTF-8, fin de línea `\n`. **Importante: el layout es distinto al de Ageing/Revenue/Pendiente_Facturar** — es el mismo orden de columnas que usa Balance (con `D_RU` justo después de `D_PE`, no después de `D_DP`), más dos columnas extra al final antes del importe: `D_MU` y `D_PMU`. Total: 29 columnas.

Columnas exactas observadas (18 filas de datos en total entre los 5 ficheros de la muestra):

| # | Columna    | Contenido observado |
|---|------------|----------------------|
| 0 | D_CA       | Fijo: `C` |
| 1 | D_DP       | Periodo, formato `AAAA.MM` (ej. `2026.03`, **con cero a la izquierda**, a diferencia de Ageing/Revenue/Pendiente_Facturar que usan `2026.3`) |
| 2 | D_DEVTR    | Siempre vacío |
| 3 | D_SAJOB    | Siempre vacío |
| 4 | D_DIM2     | Siempre vacío |
| 5 | D_DIM3     | Siempre vacío |
| 6 | D_ACTY     | Siempre vacío |
| 7 | D_CLIENT   | Siempre vacío en la muestra (a diferencia de Ageing/Revenue/Pendiente_Facturar, aquí no hay cliente) |
| 8 | D_PE       | Igual que D_DP (`2026.03`) |
| 9 | D_RU       | Código de sociedad (`ESP066`...`ESP070`) |
| 10| D_ORU      | Igual que D_RU (aquí SÍ coincide con D_RU, a diferencia de Ageing donde D_ORU iba siempre vacío) |
| 11| D_AC       | Variable: `MBFR010`, `MBFR011`, `MBFR020`, `MBFR021` (4 valores en la muestra, parecen pares relacionados: 010/011 y 020/021) |
| 12| D_FL       | Fijo: `F99` |
| 13| D_AU       | Fijo: `0LIA01` |
| 14| D_T1       | Siempre vacío |
| 15| D_T2       | Siempre vacío |
| 16| D_CU       | Fijo: `EUR` |
| 17| D_TO       | Fijo: `ORIG07-01` |
| 18| D_GO       | Fijo: `0000.PACKAGE` |
| 19| D_LE       | Siempre vacío |
| 20| D_NU       | Siempre vacío |
| 21| D_DIM4     | Siempre vacío |
| 22| D_DEST     | Siempre vacío |
| 23| D_AREA     | Siempre vacío |
| 24| D_TFTR     | Siempre vacío |
| 25| D_MU       | Siempre vacío en la muestra |
| 26| D_PMU      | Siempre vacío en la muestra |
| 27| P_AMOUNT   | Importe numérico entero en la muestra (ej. `63`, `162`, `3450`, `4378`) — sin decimales visibles, sin coma ni punto |
| 28| P_COMMENT  | Siempre vacío |

## 4. Reglas de negocio: NINGUNA CONFIRMADA

A diferencia de las otras 4 áreas, **no he encontrado ninguna mención a "Working Capital" ni "capital circulante" en las 5 transcripciones de reunión con Tinkle disponibles** (documentos "Reporting Tinkle - Documentación & Requerimientos I a V"). No sé:
- Si esto se calcula a partir de datos operativos (facturación, aging, tesorería) o si son **líneas de ajuste manuales** que alguien introduce directamente en Magnitude a nivel de Grupo (los valores fijos `D_GO=0000.PACKAGE` y `D_TO=ORIG07-01`, junto con el número tan bajo de filas — solo 4 por sociedad — apuntan más a esto último que a un cálculo derivado de tablas operativas).
- Qué significan exactamente las cuentas `MBFR010/011/020/021`.
- Por qué solo hay 4 filas por sociedad y qué representa cada una (posiblemente 2 conceptos con su contrapartida: 010↔011 y 020↔011, o similar).

## 5. Datos disponibles en el Lakehouse (esquema 200) para construir esto

- No se ha identificado ninguna tabla ni vista candidata clara para esta área. **No existe ninguna vista `vw_Export_Working_Capital`** en el SQL Analytics Endpoint (verificado: solo existen `vw_Export_Grupo`, `vw_Export_Saldos_4_7` y `vw_Reporting_Actuals`).
- **Verificado por consulta SQL que `vw_Export_Grupo` NO contiene** filas con `D_AC IN ('MBFR010','MBFR011','MBFR020','MBFR021')`. Working_Capital no está oculto dentro de esa vista, a pesar de compartir su mismo layout de columnas.
- **Búsqueda exhaustiva en vivo (2026-09-30), todo negativo**: se comprobaron las 4 tablas de mapeo/presupuesto candidatas razonables del esquema 200 y ninguna tiene rastro de estas cuentas ni del concepto "Working Capital"/"Package":
  - `Dim_Mapeo_Cuentas` (300): sin filas con `Cuenta_magnitude` tipo `MB%`/`MP%`/`MBFR%` (confirmado antes).
  - `Presupuestos`: todas las cuentas empiezan por `R` (son presupuesto de P&L/Revenue, nada de balance ni working capital).
  - `COA_Oracle`: columna `TIPO` solo tiene valores `Null`, `PYG`, `Balance` — nada específico de working capital.
  - `Budget_historico`: sin nada relacionado (y recordemos que la auditoría del proyecto ya señalaba esta tabla como "sin consumidor conocido").
  - **Con esto se agotan las tablas candidatas razonables del Lakehouse.** Refuerza la hipótesis de la sección 4: esto es muy probablemente una entrada manual directa en Magnitude a nivel de Grupo, no algo derivable de los datos operativos de Tinkle en Fabric.

## 6. Preguntas abiertas que hay que resolver ANTES de dar la lógica por buena (no las asumas) — aquí prácticamente todo está abierto

1. ¿Este fichero se genera a partir de datos que ya existen en Fabric, o son líneas que Tinkle introduce manualmente hoy en Magnitude (y por tanto "replicar" significaría dar de alta un formulario/proceso de captura manual, no una consulta automática)?
2. ¿Qué representan las cuentas `MBFR010`, `MBFR011`, `MBFR020`, `MBFR021`?
3. ¿Por qué solo hay 4 filas por sociedad cada mes? ¿Es un patrón fijo (siempre esas 4 cuentas) o varía?
4. Si hay una fuente de datos real detrás, ¿cuál es (aging, tesorería, algún cálculo de capital circulante estándar: activo corriente menos pasivo corriente)?

## 7. Qué quiero que hagas

Antes de construir nada, ayúdame a averiguar si este fichero tiene siquiera una fuente de datos automatizable (sección 6, pregunta 1) — pregúntale directamente a quien gestiona el reporting de Grupo en Tinkle. Si resulta que son líneas manuales, dilo claramente: puede que "replicar" este proceso no sea un notebook de Fabric, sino simplemente documentar cómo se introducen esas 4 líneas a mano. No inventes una fuente de datos ni un cálculo de capital circulante genérico solo por rellenar el hueco.
