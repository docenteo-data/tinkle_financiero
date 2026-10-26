# Prompt para nueva conversación: construir Generar_txt_CashFlow (Tinkle Financiero)

Pega esto tal cual al abrir la nueva conversación.

---

Voy a construir en Microsoft Fabric el proceso de generación del TXT de **CashFlow** para el proyecto de Reporting Financiero de Tinkle, replicando un patrón ya existente (Balance) que funciona en producción. Tengo acceso al MCP de Fabric (`fabric-local`) y a Asana. Te doy solo hechos verificados; lo que no está verificado lo marco explícitamente como pregunta abierta. No asumas ni inventes nada de lo marcado como abierto: pregúntamelo antes de escribir la lógica definitiva.

## 1. Patrón técnico ya confirmado (funciona para Balance, replicable tal cual)

- Workspace Fabric: **"Tinkle - Financiero"**. Lakehouse: **lh_tinkle_financiero**. SQL Analytics Endpoint, esquema **200** para datos consolidados/intermedios.
- El pipeline **"Grabar salidas"** tiene, para Balance: actividad **Notebook** (ejecuta `Generar_txt_Balance_Saldos`) → actividad **Copy data** ("Grabar balance").
- Configuración exacta de esa actividad Copy data (verificada en el portal):
  - **Source**: conexión "Lakehouse reporting (Preview)", Lakehouse `lh_tinkle_financiero`, Root folder = Files, Wildcard file path = `Exportaciones/Balance` / `*.txt`, Recursively = true, formato Binary.
  - **Destination**: conexión "SharePoint reporting" (SharePoint Online File), File path = `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, formato Binary.
- Para replicar en CashFlow: el notebook debe escribir en `Files/Exportaciones/CashFlow/...` dentro del Lakehouse, y hay que añadir una segunda actividad Notebook + Copy data al pipeline con Source `Exportaciones/CashFlow` y Destination `.../2. Salida de ficheros/CashFlow`.
- Mecánica de escritura de fichero ya validada en Balance (reutilizable como base, aunque el formato de CashFlow es distinto — ver sección 3): `coalesce(1)`, mover el `part-*` de Spark a la ruta final con `notebookutils.fs`, borrar carpeta temporal.

## 2. Mapeo de sociedades (confirmado, viene del notebook de Balance)

```
ESP066 -> TINKLE_COMM  (nombre completo Oracle: "ES TINKLE COMMUNICATIONS")
ESP067 -> TINKLE_EU    (nombre completo Oracle: "ES TINKLE EUROPEAN")
ESP068 -> TINKLE_JAZZ  (nombre completo Oracle: "ES TINKLE JAZZ")
ESP069 -> TINKLE_ONION (nombre completo Oracle: "ES TINKLE ONION")
ESP070 -> TINKLE_CONS  (nombre completo Oracle: "ES TINKLE CONSULTANTS")
```

## 3. Layout REAL del fichero de CashFlow (verificado contra ficheros TXT reales de marzo 2026)

Ruta de los ficheros de ejemplo reales, ya en el proyecto:
`otros/2026 03 - 0001 Magnitude Marzo/CashFlow/03 MAR-26/*.txt` (uno por sociedad, 5 ficheros).

Nombre de fichero real observado: `TINKLE_COMM_CashFlow_MAR-26_20260401_105203.txt` → patrón `{SOCIEDAD}_CashFlow_{MES-AA}_{timestamp:%Y%m%d_%H%M%S}.txt`.

**Este formato es radicalmente distinto al de Balance/Ageing/Revenue.** No es un CSV plano de líneas Magnitude: es un **listado contable en bruto, estilo informe impreso**, con:

- Codificación **ISO-8859-1 / Latin-1** (no UTF-8), fin de línea **CRLF** (`\r\n`), a diferencia de los demás ficheros que son UTF-8/ASCII con `\n`.
- Cabecera del informe (líneas sueltas antes de la tabla, verificado igual en los 5 ficheros de ejemplo):
  ```
  (línea en blanco)
  (línea en blanco)
   HMES - Asientos con contrapartida fija
   Compañía:  ES TINKLE COMMUNICATIONS       <- nombre completo Oracle de la sociedad, no el código corto
   Fecha:     01-ENE-26     31-MAR-26        <- rango: inicio del ejercicio hasta fin del periodo del cierre
   Cuenta:    572                            <- fijo: 572 (cuenta de tesorería/bancos) en los 5 ficheros de ejemplo
  (línea en blanco)
  ```
- Fila de cabecera de la tabla (separada por `;`, con un espacio inicial en cada línea): el texto de cabecera tal cual aparece tiene 17 nombres, pero **las filas de datos tienen 20 campos** (falta contrastar los 3 últimos nombres de columna, ver más abajo). Cabecera observada:
  ```
  COMPAÑIA;CUENTA;CDC;CLIENTE;IMPUTACION;INTERCO;LIBRE;FECHA CONTABLE;SECUENCIA;NUMERO SECUENCIA;CURRENCY CONVERSION RATE;CURRENCY;DEBE_EUR;HABER_EUR;DEBE_DIVISA;HABER_DIVISA;THIRD...
  ```
- Columnas de datos observadas por posición (0-indexed), con ejemplo real:
  | # | Nombre (según cabecera, o inferido) | Ejemplo |
  |---|---|---|
  | 0 | COMPAÑIA (código numérico interno, no el D_RU tipo ESP066) | `53` |
  | 1 | CUENTA (cuenta contable) | `5720001`, `4300000` |
  | 2 | CDC (centro de coste) | `0000`, `ESP0` |
  | 3 | CLIENTE (código interno, no siempre poblado) | `0000000` |
  | 4 | IMPUTACION | `B`, `I` |
  | 5 | INTERCO | `000`, `EHG` |
  | 6 | LIBRE | `00` |
  | 7 | FECHA CONTABLE | `02-ENE-26` |
  | 8 | SECUENCIA (descripción textual del asiento) | `2026-02-02 Dpto. Tesoreria Bancos EUR MPG 02-ENE-26`, `TK COMMUNICATIONS Cobros 26` |
  | 9 | NUMERO SECUENCIA | `202600010` |
  | 10 | (posible correlativo de línea, a veces vacío) | `1` o vacío |
  | 11 | CURRENCY CONVERSION RATE | `EUR` (¡ojo, en la posición que "debería" ser la moneda de conversión aparece el código de moneda; puede que el índice 10 y 11 estén desplazados según la fila — no verificado con certeza total, revisar con más muestras) |
  | 12 | DEBE_EUR | `0`, `143865,79` |
  | 13 | HABER_EUR | `143865,79`, `0` |
  | 14 | DEBE_DIVISA | igual que DEBE_EUR en las filas de ejemplo (todas en EUR) |
  | 15 | HABER_DIVISA | igual que HABER_EUR en las filas de ejemplo |
  | 16 | (código de tercero, ej. cliente/proveedor) | `16803`, `19002`, vacío en algunas filas |
  | 17 | (nombre de tercero) | `ASTRAZENECA FARMACEUTICA SPAIN, S.A.`, `C.P. CENTRO COMERCIAL ARTEA` |
  | 18 | (origen del apunte) | `AR` (cuentas a cobrar), `GL` (asiento contable general) |
  | 19 | (vacío, residual por `;` final) | |
- Los importes usan **coma decimal** (`143865,79`), a diferencia de Ageing/Revenue que usan punto.
- Confirmado en los 5 ficheros de ejemplo: un único bloque `Cuenta: 572` por fichero (no hay varios bloques de cuentas distintas dentro del mismo fichero de ejemplo).

### CORRECCIÓN IMPORTANTE (2026-09-30): el filtro NO es "cuenta 572 + su pareja de asiento" — es mucho más amplio

Se analizó el fichero real completo (TINKLE_COMM, 2.948 filas de datos) contando cuentas distintas. Resultado — la mezcla es mucho más amplia de lo que se pensaba:

| Cuenta | Filas | Tipo |
|---|---|---|
| 5720001, 5720004, 5720006, 5720007 | 906+88+38+85 | Bancos (572x) |
| **4000000** | **747** | **Proveedores** |
| 4300000, 4300001, 4300003 | 541+291+9 | Clientes |
| 5523000 | 61 | Intercompany (552x) |
| 4650000, 4650002 | 5+54 | Nóminas/personal |
| 6250000, 6260000, 6293006 | 6+27+4 | Gastos |
| 6680000, 6690000 | 6+5 | Gastos financieros |
| 7680000 | 25 | Ingresos financieros |
| 4700000, 4750000/1, 4751003/4, 4760000 | varias | Hacienda Pública (IVA, retenciones) |

Esto **no encaja** con "línea de banco + su contrapartida en el mismo asiento" — es prácticamente todo tipo de cuenta que puede aparecer conciliada contra un movimiento bancario (cobros de clientes, pagos a proveedores, nóminas, impuestos, comisiones). Los nombres de lote (`Nombre Lote`) dan la pista real: "CARGO GTOS. CAIXABANK Varios EUR", "TK COMMUNICATIONS Cobros 26", "MOVIMIENTOS ZBA IMPORTACION" — son los **lotes de conciliación bancaria** que genera Oracle al importar y conciliar el extracto de banco, y cada lote arrastra tanto la línea de banco como todo lo que se ha conciliado con ella.

Además, el título completo del informe es **"HMES - Asientos con contrapartida fija"**. Tiene toda la pinta de ser un **informe con nombre propio dentro de Oracle** (HMES es probablemente un código de informe interno), no algo reconstruible con garantías adivinando cuentas por SQL. La hipótesis de "unir por `Asiento`" queda descartada por falta de evidencia — no se ha encontrado el criterio de selección real. Esto ya no es una pregunta técnica de SQL, es una pregunta directa a Tinkle: qué selecciona exactamente ese informe de Oracle (ver sección 6, pregunta añadida).

## 4. Reglas de negocio confirmadas por transcripción de reunión (Josep Zoppetti, financiero de Tinkle — testimonio verbal, no verificado contra datos)

- El CashFlow se obtenía históricamente con **macros propias, a partir de una exportación que hacen directamente de Oracle** ("una exportación que hacemos de Oracle también"). No mencionan que pase por MMS ni por el modelo `Fact_Actuals` curado.
- Las cuentas de tesorería en el plan contable son las que empiezan por **57** (mencionado explícitamente: "cuentas 57 de tesorería, dónde está el saldo de bancos").
- El rango de fechas del informe (`01-ENE-26` a `31-MAR-26` en el ejemplo de marzo) sugiere que el fichero es **acumulado desde el inicio del ejercicio hasta el cierre del periodo**, no solo el mes en curso — no confirmado explícitamente, es una inferencia de los datos de ejemplo.

## 5. Datos disponibles en el Lakehouse (esquema 200) para construir esto

- **Hallazgo importante, verificado contra el esquema real** (`documentacion/esquema_lh_tinkle_financiero_100_200.tsv`): la tabla `Oracle_historico` (esquema 200, 45 columnas) tiene prácticamente todas las columnas que necesita este fichero:
  `Origen, Org Id, Compañía, Flex Value Set Id CDC, Origen Usuario, Estado, Secuencia, Cia, Cod Compania MMS, Cuenta, Des. Cuenta, CDC, Des. CDC, Cliente, Imputación, Intercía, Libre, Fecha Contable, Mes Contable, Nombre Lote, Factura, Asiento, Divisa, Num. Tercero, Nom. Tercero, Num. Pedido, NIF, Fecha Factura, Mes Factura, Año Factura, Concepto Pedido, Descripción Linea, Porcentaje Imputación, Debe, Haber, Total, Divisa Reporting, Categoria, RevAmount, Interco, Mes, Num & Nom Tercero_, Cuenta & Descripción, Fichero Origen, ID_account`.
  - Correspondencia razonable con las columnas del fichero real: `CUENTA`→`Cuenta`, `CDC`→`CDC`, `CLIENTE`→`Cliente`, `IMPUTACION`→`Imputación`, `INTERCO`→`Intercía` (o `Interco`, hay dos campos parecidos — verificar cuál usa el fichero), `LIBRE`→`Libre`, `FECHA CONTABLE`→`Fecha Contable`, `DEBE_EUR`/`HABER_EUR`→`Debe`/`Haber`, tercero→`Num. Tercero`/`Nom. Tercero`, `CURRENCY`→`Divisa`, origen (`AR`/`GL`)→`Categoria` u `Origen`.
  - `SECUENCIA` (la descripción textual larga del asiento, ej. "TK COMMUNICATIONS Cobros 26") podría salir de `Nombre Lote`, `Asiento` o `Descripción Linea` — no está claro cuál exactamente, verificar con datos reales.
  - Esto casi con toda seguridad resuelve la pregunta de si `Fact_Actuals` (que NO tiene estos campos) es la fuente equivocada: **la fuente correcta parece ser `Oracle_historico` directamente**, no el modelo curado de la capa 300.
  - **CONFIRMADO en vivo (2026-09-30)**: se ejecutó `SELECT ... FROM [200].[Oracle_historico] WHERE [Cuenta] LIKE '572%' AND [Compañía]='ES TINKLE COMMUNICATIONS' AND [Fecha Contable] BETWEEN '2026-01-01' AND '2026-03-31'` y salió, entre otras, esta fila: `ES TINKLE COMMUNICATIONS;5720007;0000;0;B;0;VARIOS;0;2026-01-02;TK COMMUNICATIONS Cobros 26;202600003;18870;INDRA SISTEMAS, S.A.;33154.0000;0.0000;Otros;AR`. Encaja con el patrón del fichero real (`Nombre Lote`→`SECUENCIA`, `Asiento`→`NUMERO SECUENCIA`, `Num./Nom. Tercero`→tercero, `Debe/Haber`→`DEBE_EUR/HABER_EUR`, `Origen`→último campo `AR`/`GL`). **`Oracle_historico` es la fuente correcta con alta confianza.**
  - Pendiente todavía: el fichero real empieza cada fila con un código numérico interno (`53` en el ejemplo), que no salió en este SELECT — probables candidatos sin verificar: `Org Id`, `Cia`, `Cod Compania MMS`. Y ni `Intercía` (`0`) ni `Interco` (`VARIOS`) coinciden claramente con los valores que vimos en el fichero real (`000`, `EHG`) — sigue sin resolver cuál es el campo correcto o si hace falta alguna transformación.
- **No existe ninguna vista `vw_Export_CashFlow`** en el SQL Analytics Endpoint (verificado: solo existen `vw_Export_Grupo`, `vw_Export_Saldos_4_7` y `vw_Reporting_Actuals`).
- Según la auditoría del proyecto, `Oracle_historico` tiene **dos productores** (`INICIAL_Carga_Oracle` para la carga histórica inicial desde un Excel Checklist, y `TRANS_Silver` de forma recurrente desde `100.New_Oracle`), ambos en modo Replace — es decir, sustituye la tabla entera en cada ejecución, no la va acumulando; confirmar que el histórico completo necesario para el rango de fechas del CashFlow (desde enero del ejercicio) sigue estando presente tras cada recarga.

## 6. Preguntas abiertas que hay que resolver ANTES de dar la lógica por buena (no las asumas)

1. ~~Confirmar que `Oracle_historico` reproduce el fichero de marzo~~ — HECHO, confirmado (ver hallazgo arriba). Pero el filtro de selección de filas sigue sin resolver (ver punto 0).
0. **(la más importante ahora)** ¿Qué es exactamente el informe Oracle **"HMES - Asientos con contrapartida fija"** y qué selecciona? Se ha comprobado que NO es "solo cuenta 572" ni "asientos con contrapartida directa" — el fichero real mezcla bancos, proveedores, clientes, intercompany, nóminas, gastos financieros y Hacienda (ver tabla en sección 3). Sin saber el criterio real de este informe (¿es un informe estándar de Oracle con parámetros concretos? ¿selecciona por lote de conciliación bancaria?), no se puede replicar con garantías por SQL.
2. ¿Cuál de `Intercía`/`Interco` es el campo correcto para la columna `INTERCO` del fichero? Ninguno de los dos valores vistos en vivo (`0`/`VARIOS`) coincide con los valores del fichero real (`000`/`EHG`) — puede que haga falta una transformación (ej. rellenar con ceros) o que ninguno de los dos sea el campo correcto.
3. Identificar qué columna da el código numérico interno de compañía que encabeza cada fila del fichero real (`53` en el ejemplo) — candidatos sin verificar: `Org Id`, `Cia`, `Cod Compania MMS`.
4. `SECUENCIA` parece salir de `Nombre Lote` (coincide textualmente con "TK COMMUNICATIONS Cobros 26" en la fila confirmada) — verificar que se cumple siempre, incluidas las filas de tipo `GL` (ej. "CARGO GTOS. CAIXABANK Varios EUR", que también coincidió con `Nombre Lote` en la prueba).
4. ¿El rango de fechas es siempre "desde el 1 de enero del ejercicio hasta el fin del periodo del cierre", o depende de otro parámetro?
5. ¿La cuenta es siempre 572, o puede haber varias cuentas de tesorería (57xxxx) y el informe genera un bloque por cada una dentro del mismo fichero?
6. Los 3 últimos nombres de columna de la cabecera del fichero de ejemplo están cortados (aparece "THIR..."); confirmar el nombre completo, comparando contra las columnas de `Oracle_historico` de la lista de arriba (candidatos: `Num & Nom Tercero_`, `Categoria`, `Fichero Origen`).

## 7. Qué quiero que hagas

Ayúdame a: (a) conseguir las respuestas a la sección 6, y (b) una vez resueltas, construir el notebook `Generar_txt_CashFlow` que genere exactamente el layout de la sección 3 (incluyendo la codificación Latin-1, CRLF y el bloque de cabecera de informe), validado línea a línea contra los ficheros reales de `otros/2026 03 - 0001 Magnitude Marzo/CashFlow/03 MAR-26/`. Este es el área con más incertidumbre de las cinco pendientes (Ageing, CashFlow, Pendiente_Facturar, Revenue, Working_Capital) — no fuerces una solución si la fuente de datos no existe todavía en el Lakehouse con el detalle necesario; en ese caso, dilo claramente y no inventes una aproximación.
