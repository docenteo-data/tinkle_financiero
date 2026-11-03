# Prompt para nueva conversación: construir Generar_txt_Ageing (Tinkle Financiero)

Pega esto tal cual al abrir la nueva conversación.

---

Voy a construir en Microsoft Fabric el proceso de generación del TXT de **Ageing** para el proyecto de Reporting Financiero de Tinkle, replicando un patrón ya existente (Balance) que funciona en producción. Tengo acceso al MCP de Fabric (`fabric-local`) y a Asana. Te doy solo hechos verificados; lo que no está verificado lo marco explícitamente como pregunta abierta. No asumas ni inventes nada de lo marcado como abierto: pregúntamelo antes de escribir la lógica definitiva.

## 0. Respuestas recibidas el 2026-11-03 (prevalecen sobre cualquier hipótesis de las secciones siguientes)

Fuente: la persona que llevó el proyecto al inicio (no Tinkle directamente).

**Mapeo de códigos confirmado** (plantilla Excel de Grupo). Coincide con la hipótesis de la sección 6bis:

| Código `d_fl` | Concepto | Letra en el DAX de Power BI (`AgingBucket`) |
|---|---|---|
| GR0 | Current (not due) | A- NOT DUE (días <= 0) |
| GR1 | 0-30 días | B (<= 30) |
| GR2 | 30-60 días | C (<= 60) |
| GR3 | 60-90 días | D (<= 90) |
| GR4 | 90-120 días | E (<= 120) |
| GR5 | 121-180 días | F (<= 180) |
| GR8C | 181-365 días | G (<= 365) |
| GR9C | Más de 1 año | H (> 365) |
| GRICFLAG | Intercompany flag, valor 1 = cliente del Grupo | (no es un tramo) |
| GRPROV | Provisión por dudoso cobro, siempre en negativo | (no aparece en marzo) |
| GRWIP / GRWIP1 / GRWIP9 | Work in progress total / 0-365 días / más de 1 año | (es el fichero Pendiente_Facturar) |
| GRRL | Límite de riesgo | (no aparece en marzo) |

Los rótulos del Excel ("30-60") y los límites del DAX (`<= 60`) difieren en un día en las fronteras; usar los límites del DAX, que son los implementados.

**GRICFLAG**: es una fila adicional por cliente intercompany con `p_amount = 1`, no un importe. En marzo aparece en 7 filas: ESP066 (`HAVAS474`, `ICHAVASWW`, `ESP016TIN637`), ESP070 (`ICESP046`, `ICHAVASWW`), ESP068 (`ESP016TIN637`, `ESP067COM550`). **Comprobado con datos (2026-11-03)**: casi seguro sale de `Aging_Clientes.Interno = 'Y'`. Hay 28 facturas con `Y` (787 con `N`) y todas son de empresas del grupo:

| Sociedad | Clientes con `Interno = 'Y'` | Flags en el TXT de marzo |
|---|---|---|
| COMM | HAVAS SHARED SERVICES LTD, SA HAVAS PARIS, TINKLE CONSULTANTS S.L.U (3) | HAVAS474, ICHAVASWW, ESP016TIN637 (3) |
| JAZZ | TINKLE COMMUNICATIONS SL, TINKLE CONSULTANTS S.L.U (2) | ESP016TIN637, ESP067COM550 (2) |
| CONS | H ADVISORS, HAVAS PR MILAN, HAVAS PR UK, PROXIMIA HAVAS, SA HAVAS PARIS (5) | ICESP046, ICHAVASWW (2) |

COMM y JAZZ coinciden en número. CONS encaja si varias entidades Havas comparten un mismo código Magnitude (por ejemplo `ICHAVASWW`): el flag va por código Magnitude, no por nombre. La verificación final requiere la columna de código Magnitude en `Dim_Clientes`. Regla propuesta: una fila `GRICFLAG` con `p_amount = 1` por cada código de cliente Magnitude que tenga alguna factura con `Interno = 'Y'`.

Las consultas de esta sesión se lanzaron con `C:\dev\tinkle_financiero\reporting-financiero\scripts\consultar_sql.py` (solo lectura, cuenta de Azure CLI `reporting@likuit.com`).

**Código de cliente (`d_client`)**: es el código de cliente en Magnitude. Hay que crearlo como columna nueva en `Dim_Clientes` (tarea abierta). La referencia es el Excel `Revenue 2026 FT3.xlsm`, que es el mismo fichero que el dataflow `INICIAL_Carga_Revenues` cargaba en `200.Revenues` (columna `Codigo cliente Magnitude`, hoy vacía). Mientras no exista esa columna, `d_client` sale provisional (nombre largo) y se sustituye al final.

**Comprobaciones del 2026-11-03**:
- Solo clientes: validado con bastante seguridad (plantilla con solo `MB4000`, fichero de marzo, y Josep en la reunión del 27 de abril: el Grupo "todavía" no pide aging de proveedores). No construir bloque de proveedores.
- `GRRL`: no hay ninguna columna de límite de crédito en el lakehouse (Asana: Tinkle no ha pasado el fichero). No se informa.
- `GRPROV`: la cuenta 490 tiene saldo (COMM -395.436,71 €; CONS -133.991,05 €; un único apunte por sociedad), pero el TXT de marzo no lleva `GRPROV`. Pendiente de Tinkle; mientras tanto, no se informa (igual que en marzo).
- Mapeo de código Magnitude: `Revenue 2026 FT3.xlsm` (en OneDrive, `3.Fuentes/Presupuestos/`, hojas "Revenue by client ...", columnas `Cliente` = código Oracle tipo `EE19362`, `Codigo MMS` y `Codigo cliente Magnitude`) cubre 124 de los 142 códigos de Ageing de marzo (los códigos numéricos hay que rellenarlos a 8 dígitos, porque Excel pierde el cero inicial). Faltan 18 (lista en `PREGUNTAS_PARA_TINKLE.md`). Ojo: `Aging_Clientes` no tiene código Oracle, solo `Nombre Cliente` y `NIF`, así que el cruce con `Dim_Clientes` tendrá que hacerse por nombre o NIF. Es un riesgo añadido a validar.
- **Validación exacta de importes y tramos (2026-11-03)**: a partir de `3.Fuentes/AGING Clientes Tinkle 2026 03 31.xlsx` (hoja `DATOS`, mismo contenido que `200.Aging_Clientes` hoy), con corte 31-03-2026, tramos del DAX y `S_Pendiente / 1000`, las 35 combinaciones sociedad y tramo cuadran con el TXT de marzo (diferencia máxima 0,0004, por redondeo a 4 decimales por línea). El total de COMM (4.640,74) es 4.637,74 de importes más 3 filas `GRICFLAG` con valor 1. Importes, tramos y escala: **validados**.
- **Validación del cruce de cliente (2026-11-03)**: el nombre de cliente del aging viene truncado a 25 caracteres, así que el cruce se hace por número de factura: `Nº Factura` del aging, a `MMS.[Nº Factura Cli.]` (misma sociedad), a `MMS.[Cod. Cliente]`, a `Codigo MMS` del Excel de Revenue, a `Codigo cliente Magnitude`. `Oracle_historico` no sirve (la factura va en texto libre y su número de tercero es otra numeración). Resultados: 707 de 815 facturas encuentran cliente en MMS (6 de ellas por NIF) y 9 (22.503 €) no; con el código Magnitude del Excel (hoja FT3 2026 con prioridad y códigos numéricos rellenados a 8 dígitos) **se reproducen exactas 192 de las 280 líneas del TXT (69%)**. El resto falla porque hay clientes MMS sin código en el Excel (unos 920.000 € sin código) y porque el Excel asigna algunos clientes a códigos distintos de los usados en marzo (sobre todo el genérico `16300001` y los intercompany). **Conclusión: el Excel de Revenue no es una fuente válida del código Magnitude para Ageing; hace falta el maestro de clientes de Magnitude que usa Tinkle.**

**CORRECCIÓN 2026-11-03**: una primera prueba dio 134 de 280 líneas y 21 códigos sin mapeo porque leía las hojas del Excel en otro orden y no recuperaba el cero inicial de los códigos numéricos. Las cifras buenas son 192 líneas y 18 códigos.

Validación reproducible: `python reporting-financiero/scripts/validar_ficheros_grupo.py ageing` (y `revenue`), con su test `reporting-financiero/tests/test_validar_ficheros_grupo_e2e.py` (`FABRIC_E2E=1`). Lee la carpeta `3.Fuentes` de OneDrive y consulta Fabric en solo lectura.
- Histórico: `Aging_Clientes` es copia de la última carga (`TRANS_Silver` copia `100.New_Agings_Clientes` sin fecha de foto), así que no se puede regenerar un mes pasado desde Fabric. El Excel de origen de marzo está en OneDrive (`3.Fuentes/AGING Clientes Tinkle 2026 03 31.xlsx`): sirve para validar Ageing de forma exacta contra el TXT de marzo.

## 1. Patrón técnico ya confirmado (funciona para Balance, replicable tal cual)

- Workspace Fabric: **"Tinkle - Financiero"**. Lakehouse: **lh_tinkle_financiero**. SQL Analytics Endpoint, esquema **200** para datos consolidados/intermedios.
- El pipeline **"Grabar salidas"** tiene, para Balance: actividad **Notebook** (ejecuta `Generar_txt_Balance_Saldos`) y después actividad **Copy data** ("Grabar balance").
- Configuración exacta de esa actividad Copy data (verificada en el portal):
  - **Source**: conexión "Lakehouse reporting (Preview)", Lakehouse `lh_tinkle_financiero`, Root folder = Files, Wildcard file path = `Exportaciones/Balance` / `*.txt`, Recursively = true, formato Binary.
  - **Destination**: conexión "SharePoint reporting" (SharePoint Online File), File path = `Shared Documents/Reporting Financiero/2. Salida de ficheros/Balance`, formato Binary.
- Para replicar en Ageing: el notebook debe escribir en `Files/Exportaciones/Ageing/...` dentro del Lakehouse, y hay que añadir una segunda actividad Notebook + Copy data al pipeline con Source `Exportaciones/Ageing` y Destination `.../2. Salida de ficheros/Ageing`.
- Mecánica de escritura de fichero ya validada y reutilizable tal cual (viene del notebook de Balance): escribir con `coalesce(1)`, `header=True`, `delimiter=";"`, `encoding=UTF-8`, `quote`/`escape` deshabilitados (`\u0000`), `lineSep="\n"`, luego mover el `part-*` generado por Spark a la ruta final con `notebookutils.fs` y borrar la carpeta temporal.
- Ya existe un borrador `Generar_txt_Ageing.ipynb` en este proyecto, **pero su lógica de columnas está construida sobre una premisa incorrecta** (leer directamente `Aging_Clientes`/`Aging_Proveedores` con sus columnas originales). NO reutilices esa parte. Sí puedes reutilizar sus funciones genéricas de escritura/movimiento de fichero (`escribir_csv`, `_mover_part_file`, `limpiar_nombre`) y el mapeo de sociedades.

## 2. Mapeo de sociedades (confirmado, viene del notebook de Balance)

```
ESP066 -> TINKLE_COMM
ESP067 -> TINKLE_EU
ESP068 -> TINKLE_JAZZ
ESP069 -> TINKLE_ONION
ESP070 -> TINKLE_CONS
```

## 3. Layout REAL del fichero de Ageing (verificado contra ficheros TXT reales de marzo 2026, no supuesto)

Ruta de los ficheros de ejemplo reales, ya en el proyecto:
`otros/2026 03 - 0001 Magnitude Marzo/Ageing/03 MAR-26/*.txt` (uno por sociedad, 5 ficheros en total, no separados por Clientes/Proveedores).

Nombre de fichero real observado: `TINKLE_COMM_Ageing_MAR-26_20260401_104852.txt`: patrón `{SOCIEDAD}_Ageing_{MES-AA}_{timestamp:%Y%m%d_%H%M%S}.txt`. La conversión de periodo a `MES-AA` (`MAR-26`) ya existe como función en el notebook de Balance (`convertir_periodo_a_nombre`, diccionario `MESES`).

Formato del fichero: CSV separado por `;`, con cabecera, **cabecera en minúsculas** (a diferencia de Balance/Revenue que usan mayúsculas `D_CA`), fin de línea `\n` (no CRLF), sin comillas. La cabecera termina en `;` (hay una columna 27 vacía residual).

Columnas exactas, en este orden, con lo que se ha observado que contienen (fijo vs variable) en los 5 ficheros de ejemplo (287 filas en total):

| # | Columna    | Contenido observado |
|---|------------|----------------------|
| 0 | d_ca       | Fijo: `C` |
| 1 | d_dp       | Periodo, formato `AAAA.M` (un solo dígito de mes, ej. `2026.3`, NO `2026.03`) |
| 2 | d_ru       | Código de sociedad (`ESP066`...`ESP070`) |
| 3 | d_devtr    | Siempre vacío |
| 4 | d_sajob    | Siempre vacío |
| 5 | d_dim2     | Siempre vacío |
| 6 | d_dim3     | Siempre vacío |
| 7 | d_acty     | Siempre vacío |
| 8 | d_client   | Código corto de cliente tipo MMS/Oracle (ej. `IKEA`, `RENFE`, `01500400`, `16300001`, `ESP066RIC8`), **NO es el nombre completo** que aparece en la tabla `Aging_Clientes.Nombre Cliente` |
| 9 | d_pe       | Igual que d_dp |
| 10| d_oru      | Siempre vacío (a diferencia de Balance, donde D_ORU debía ser igual a D_RU) |
| 11| d_ac       | Fijo: `MB4000` |
| 12| d_fl       | Código de tramo de antigüedad (variable, ver sección 4) |
| 13| d_au       | Fijo: `0LIA01` |
| 14| d_t1       | Siempre vacío |
| 15| d_t2       | Siempre vacío |
| 16| d_cu       | Fijo: `EUR` |
| 17| d_to       | Siempre vacío |
| 18| d_go       | Siempre vacío |
| 19| d_le       | Siempre vacío |
| 20| d_nu       | Siempre vacío |
| 21| d_dim4     | Siempre vacío |
| 22| d_dest     | Siempre vacío |
| 23| d_area     | Siempre vacío |
| 24| p_comment  | Siempre vacío |
| 25| p_amount   | Importe numérico con **punto** decimal (no coma), sin separador de miles, hasta 4 decimales (ej. `36.7401`, `-11.5353`), **CONFIRMADO en vivo: está expresado en MILES DE EUROS** (`S_Pendiente / 1000`, sin redondear a entero, a diferencia de Balance que sí redondea a entero). Ver hallazgo de validación más abajo. |
| 26| (vacío)    | Columna residual vacía por el `;` final de cabecera |

Valores de `d_fl` (tramo de antigüedad) observados en los 5 ficheros de ejemplo: `GR0, GR1, GR2, GR3, GR4, GR5, GR8C, GR9C, GRICFLAG`.

### Validación en vivo (2026-09-30): fuente y escala CONFIRMADAS

Se sumó el `p_amount` de las 120 líneas del fichero real de TINKLE_COMM: **total = 4.640,74**.
Se ejecutó `SELECT SUM([S_Pendiente]), COUNT(*) FROM [200].[Aging_Clientes] WHERE [Proveedor]='ES TINKLE COMMUNICATIONS'`, que da **4.637.740,72 en 372 facturas**.
`4.637.740,72 / 1000 = 4.637,74`, prácticamente idéntico a 4.640,74 (diferencia de 3€, explicable porque `Aging_Clientes` es una tabla "viva" que se sobrescribe en cada carga, no un histórico congelado a 31 de marzo, así que el número exacto se moverá con el tiempo, pero el orden de magnitud y la fuente quedan confirmados).

**Esto confirma con alta confianza**: la fuente es `Aging_Clientes.S_Pendiente`, filtrada por `Proveedor` (= la sociedad emisora), dividida entre 1000 (sin redondear a entero, a diferencia de Balance). El número de facturas (372) frente a las 120 líneas del TXT real es coherente: el TXT agrupa por `D_CLIENT` + tramo, así que varias facturas del mismo cliente en el mismo tramo se suman en una sola línea.

## 4. Reglas de negocio confirmadas por transcripción de reunión (Josep Zoppetti, financiero de Tinkle, y Álvaro Montero, es testimonio verbal, no verificado contra datos, pero es la fuente más fiable que tenemos)

- Los tramos de antigüedad que maneja Tinkle son: al día, 0-30 días, 31-60, 61-90, 91-120, 121-180, y más de 1 año de retraso. Esto encaja con `GR0`...`GR5` pero **no tengo la correspondencia exacta confirmada** entre cada `GRn` y su rango de días.
- La cuenta contable **490** es la de "dudoso cobro" (provisión por impago de clientes con más de 1 año de deuda sin respuesta). Es razonable (no confirmado) que `GR8C` o `GR9C` correspondan a esta provisión.
- Existen temas de **intercompany** (facturas/deuda con otras empresas del grupo Havas) gestionados aparte ("ICS"). Es razonable (no confirmado) que `GRICFLAG` sea el flag de intercompany.
- Regla de negocio explícita y repetida: el aging de los módulos auxiliares (AP para proveedores, AR para clientes) **siempre debe cuadrar con el saldo contable real** de las cuentas de clientes/proveedores. La contabilidad manda; si no cuadra, hay que corregir el aging, no la contabilidad.

## 5. Datos disponibles en el Lakehouse (esquema 200) para construir esto

- `Aging_Clientes`: columnas `Proveedor` (en realidad es la sociedad emisora, ej. "ES TINKLE CONSULTANTS"), `Cobrador`, `Interno`, `Nombre Cliente`, `Pais`, `Nº Factura`, columna de fecha envío/producto, `NIF`, `Tipo Factura`, `F.Factura`, `F. Vto.`, `Imp_Factura`, `S_Pendiente`.
- `Aging_Proveedores`: columnas `Compañía` (sociedad), `Cod. Proveedor`, `Proveedor`, `CIF Proveedor`, `Nº Factura`, `Fecha Factura`, `Fecha Vencimiento`, `Fecha Contable`, `Medio`, `Moneda`, `Método`, `IBAN`, `Imp_Factura`, `Imp_Pendiente`, `Imp_Vencido`.
- **No existe ninguna vista `vw_Export_Ageing`** en el SQL Analytics Endpoint (verificado por consulta SQL). Solo existen `vw_Export_Grupo` y `vw_Export_Saldos_4_7` (las de Balance) y `vw_Reporting_Actuals` (esquema 300).
- **Verificado por consulta SQL que `vw_Export_Grupo` NO contiene** filas con `D_AC` en (`MB4000`, `MP2010`, `MBFR010`, `MBFR011`, `MBFR020`, `MBFR021`). Es decir, Ageing/Revenue/Working_Capital no están ocultos dentro de esa vista: hay que construir la lógica desde cero.
- Existe una dimensión `Dim_Clientes` (esquema 300, confirmado en `documentacion/Documentacion_Tinkle_Financiero.md`) con columnas: `Cliente ORACLE, Cliente MMS, Descripción, Fecha Inicio/Finaliz., Activ., Ppal., Empresa, SECCION, ClienteKey_Oracle, ClienteKey_MMS`. Es el candidato más probable para traducir el nombre de cliente al código corto `D_CLIENT`, aunque no veo a simple vista una columna evidente tipo "código Magnitude" (a diferencia de la tabla `Revenues`, ver más abajo), hay que verificar el contenido real de `Cliente ORACLE`/`Cliente MMS`.
- **Pista fuerte**: la tabla `Revenues` (esquema 200, usada para el área Revenue) sí tiene columnas explícitas `Codigo cliente Magnitude` y `Code Magnitude` con exactamente el tipo de código corto que buscamos (`IKEA`, `01500400`...). Aunque `Revenues` no es la fuente de Ageing, demuestra que ese mapeo "código Magnitude por cliente" existe en algún sitio del proyecto, puede que también esté accesible vía `Dim_Clientes` o que haya que cruzar `Aging_Clientes` con `Revenues`/`Dim_Clientes` por nombre de cliente para heredar ese código.
- Existe un **modelo semántico separado llamado `Agings`** (id `e19def87-fdf3-4b44-bd60-d22e5d79ce88`, distinto del `Financial Model` que usa Balance), que alimenta el informe Power BI **"Agings"** y se refresca en el pipeline `Generar Reporting`. Es casi seguro que ahí ya está implementada en DAX la lógica de tramos de antigüedad (0-30/31-60/etc.) que buscamos, nunca se ha podido leer su definición TMDL por conector (documentado como "pendiente de verificar" en la auditoría del proyecto), pero se puede abrir directamente en el portal de Fabric o en Power BI Desktop para inspeccionar sus medidas DAX.

## 6bis. Fórmula DAX real del tramo de antigüedad (verificada, sacada del modelo semántico `Agings`, TMDL, columna calculada `AgingBucket` de la tabla `Aging_Clientes_Snapshot`)

```dax
"AgingBucket",
    VAR FechaCorte2 = [Date]
    VAR FechaVto2 = [F.Vto]

    VAR Dias =
        IF(
            ISBLANK(FechaVto2),
            BLANK(),
            DATEDIFF(FechaVto2, FechaCorte2, DAY)
        )

    RETURN
        SWITCH(
            TRUE(),
            ISBLANK(Dias), BLANK(),
            Dias <= 0,   "A- NOT DUE",
            Dias <= 30,  "B- 0-30 Days",
            Dias <= 60,  "C- 31-60 Days",
            Dias <= 90,  "D- 61-90 Days",
            Dias <= 120, "E- 90-120 Days",
            Dias <= 180, "F- 121-180 Days",
            Dias <= 365, "G- 181-365 Days",
            "H- Over 1 Year"
        )
```

Esto confirma con exactitud los rangos de días. Notas:
- `[Date]` es la fecha de corte que el usuario elige en el informe (día/mes/año, ver manual §6.2), **no necesariamente el último día del mes**. Para el TXT de cierre, previsiblemente hay que usar el último día del periodo (`Periodo`/`PeriodoMaximo`, como hace `vw_Export_Grupo`), pero no está confirmado.
- Este modelo usa **letras A-H** (8 categorías), no los códigos `GRn` del TXT real (9 códigos: `GR0..GR5, GR8C, GR9C, GRICFLAG`). Hipótesis razonable, NO confirmada:
  - `GR0..GR5` = `A..F` (mapeo directo 1 a 1, 6 categorías)
  - `GR8C`/`GR9C` = `G- 181-365 Days` / `H- Over 1 Year` (la `C` podría venir de "dudoso Cobro", cuenta 490, que Josep asocia justo a la deuda de más de 1 año)
  - `GRICFLAG` no parece ser un tramo de días (no hay una 9ª categoría en esta fórmula), en el fichero real aparecía como una fila aparte para el mismo cliente, lo que encaja más con ser el flag de intercompany que menciona Josep, ortogonal al tramo.
- Existe una tabla `Aging_Proveedores_Snapshot` con la misma estructura (`AgingBucket`, `DaysDue`), o sea, el modelo Power BI SÍ separa Ageing de clientes y de proveedores en dos tablas/snapshots distintos. Esto es un indicio a favor de que el TXT de Grupo también podría necesitar (o ya tener en algún otro fichero no incluido en la muestra) una versión de proveedores, aunque la muestra de marzo que tenemos solo mostraba clientes.
- Hay tablas `Aging_Clientes_Snapshot`/`Aging_Proveedores_Snapshot` (con columnas `AgingBucket`, `Date`, `DaysDue`, `F.Factura`, `F.Vto`, y en el caso proveedores `CIF Proveedor`, `Compañía`) que relacionan `200 Aging_Clientes`/`200 Aging_Proveedores` con una tabla `Fechas` (con `fechaseleccionada`), es decir, es un modelo de "snapshot a fecha seleccionada", no un cálculo permanente en la tabla base. Para el notebook no hace falta replicar esta arquitectura de snapshot con parámetro de usuario, basta con fijar `Date` = fin del periodo de cierre.

## 6. Preguntas abiertas que hay que resolver ANTES de dar la lógica por buena (no las asumas)

1. Confirmar el mapeo exacto `A..H` a `GR0..GR5, GR8C, GR9C` (hipótesis en 6bis, no verificada). Si existe una tabla/columna en el modelo `Agings` o en Magnitude que ya tenga este mapeo explícito, localizarla en vez de asumir la hipótesis.
2. ¿Qué es exactamente `GRICFLAG` y de qué columna sale (confirmar que es el flag de intercompany y no otra cosa)?
3. ¿Cómo se traduce el `Nombre Cliente` de `Aging_Clientes` (texto largo) al código corto `D_CLIENT` del fichero? Verificar el contenido de `Dim_Clientes.Cliente ORACLE`/`Cliente MMS`, y si no coincide, comprobar si se puede obtener cruzando por nombre con `Revenues.Codigo cliente Magnitude`.
4. El fichero de ejemplo de marzo solo tiene datos de tipo cliente (cuenta `MB4000`). El modelo Power BI sí separa clientes y proveedores en snapshots distintos, **¿hace falta también un fichero/bloque de proveedores (AP) en el TXT de Grupo, o Ageing de Grupo es solo de clientes?**
5. ¿De dónde sale el saldo contable de la cuenta de clientes (430) contra el que hay que cuadrar el total del aging, para poder añadir una validación de cuadre como la que describe Josep?
6. ¿Qué fecha exacta se usa como `[Date]` (fecha de corte) para el cierre mensual, el último día natural del mes, el último día hábil, u otra?

## 7. Qué quiero que hagas

Ayúdame a: (a) conseguir las respuestas a la sección 6 (dime qué consulta SQL o qué revisión en el portal de Fabric hace falta para cada una), y (b) una vez resueltas, construir el notebook `Generar_txt_Ageing` que genere exactamente el layout de la sección 3, validado línea a línea contra los ficheros reales de `otros/2026 03 - 0001 Magnitude Marzo/Ageing/03 MAR-26/`. Después seguiremos con Revenue, Pendiente_Facturar, Working_Capital y CashFlow, en ese orden, con el mismo nivel de rigor (nunca asumir un layout o una fuente de datos sin verificarla contra un fichero de ejemplo real o una fuente confirmada).
