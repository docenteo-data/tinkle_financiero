---
type: domain
load_tier: 2
schema_version: 1
last_sync: 2026-11-03T15:00:00Z
commit: a20d0d6
tags: [domain, ficheros-de-grupo, magnitude]
---

# Ficheros de Grupo (Magnitude)

> Cuándo cargar: vas a construir, validar o estimar un fichero de Grupo (Ageing, Revenue, Pendiente_Facturar, Working_Capital, CashFlow) o necesitas saber qué está confirmado con datos y qué falta.

## Qué son

Cada cierre, Tinkle entrega al Grupo (Havas) en Magnitude siete ficheros TXT por sociedad: Balance, Saldos 4_7, Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow. Unidades de informe: ESP066 Communications, ESP067 European, ESP068 Jazz, ESP069 Onion y ESP070 Consultants (HAPA y Portugal aún no). Nombre: `{SOCIEDAD}_{Tipo}_{MES-AA}_{AAAAMMDD_HHMMSS}.txt`, con SOCIEDAD de TINKLE_COMM a TINKLE_CONS.

Hoy solo existen Balance y Saldos 4_7 en Fabric. Referencia de validación: los TXT de marzo de 2026 subidos a Magnitude, en la carpeta `3.Fuentes/2026 03 - 0001 Magnitude Marzo/` del OneDrive del proyecto (no se versionan).

## Arquitectura (patrón de Balance)

Una vista `vw_Export_<fichero>` en el esquema `200` con la lógica; un notebook que da formato y escribe en `Files/Exportaciones/<fichero>/`; una actividad Copy data por carpeta en el pipeline `Grabar salidas` hacia `2. Salida de ficheros/<fichero>` en SharePoint. Ver [[repos/rf-fabric/overview]].

## Reglas confirmadas con datos

- **Ageing**: fuente `200.Aging_Clientes`; importe `S_Pendiente / 1000` sin redondear a entero; tramo de aging por días desde `F. Vto.` a fin de mes con los límites de `AgingBucket` del modelo `Agings`: GR0 no vencido, GR1 hasta 30, GR2 60, GR3 90, GR4 120, GR5 180, GR8C 365 y GR9C más. Cuenta fija `MB4000`. Las 35 combinaciones de sociedad y tramo de marzo cuadran (diferencia máxima 0,0004). Intercompañía: una fila `GRICFLAG` con valor 1 por cliente, casi seguro desde `Interno = 'Y'`. Solo clientes. `GRRL` no se informa (no hay límites de crédito); `GRPROV` no aparece en marzo aunque la cuenta 490 tiene saldo.
- **Revenue**: medida `REAL (Fees & other)` (cuentas X `X70000` y `X60000`, es decir Gross Income), acumulada desde enero, signo invertido, en miles. Cuenta `MP2010`. Cuadra el total en ESP067, ESP068, ESP069 y ESP070; ESP066 difiere en 6,82 (0,24%), sin explicar.
- **Pendiente_Facturar**: código `GRWIP` de la misma plantilla que Ageing (`GRWIP1`/`GRWIP9` por antigüedad). Escala probable en miles. La suma de MMS sin factura de cliente no lo reproduce: regla pendiente de Tinkle.
- **Working_Capital**: mismo layout, literales (`ORIG07-01`, `0000.PACKAGE`) y redondeo a miles que Balance; cuentas `MBFR010/011/020/021` sin rastro en Fabric. Lógica desconocida, quizá manual.
- **CashFlow**: listado de Oracle "HMES - Asientos con contrapartida fija" (Latin-1, CRLF, coma decimal), no líneas Magnitude. Fuente `200.Oracle_historico`; mezcla bancos, proveedores, clientes, nóminas e impuestos, así que no es solo la cuenta 572. Selección desconocida: existe una macro no facilitada.

## Código de cliente Magnitude

Código propio de Magnitude (`IKEA`, `01500400`, `ESP066RIC85`), distinto de las claves de Oracle y MMS. Bloquea la entrega de Ageing, Revenue y Pendiente_Facturar. Se creará como columna de `Dim_Clientes`.

- Cruce en Ageing: por número de factura contra MMS (el nombre del aging viene truncado a 25 caracteres; `Oracle_historico` usa otra numeración de tercero). Cruce en Revenue: `ClienteKey_Oracle` contra `Dim_Clientes`.
- El Excel `Revenue 2026 FT3.xlsm` no basta (rellenar a 8 dígitos los códigos numéricos): reproduce 192 de 280 líneas de Ageing y 132 de 172 de Revenue, y le faltan 21 de 167 códigos.
- Con el maestro cuadrarían casi todas: 33 de 53 códigos fallidos de Ageing y 28 de 40 de Revenue los explica un único cliente con importes idénticos; el resto agrupa varios clientes (genérico `16300001`, `REPSOL01`).

## Estado y estimación

Ageing y Revenue: se pueden construir enteros ya (1 a 1,5 jornadas cada uno). Pendiente_Facturar, Working_Capital y CashFlow: solo esqueleto hasta resolver sus bloqueos. Total 7 a 12,5 jornadas, de las que 4 a 5,5 se pueden hacer ya. Detalle en `reporting-financiero/docs/contexto/20261103-estado-ficheros-grupo.md`.

## Avisos

- `Aging_Clientes` guarda solo la última carga: un mes pasado se regenera recargando su Excel de origen, no desde Fabric.
- `notebooks/Generar_txt_Ageing.ipynb` es un borrador con premisa equivocada.
- Validación reproducible: `validar_ficheros_grupo.py` y su test E2E, ver [[agent-context/repo-cards/rf-scripts]].

## Evidence

- `reporting-financiero/fabric/sql/200.vw_Export_Grupo.sql` - patrón de Balance: literales, miles y redondeo.
- `reporting-financiero/fabric/Agings.SemanticModel/definition/tables/Aging_Clientes_Snapshot.tmdl#AgingBucket` - límites de los tramos.
- `reporting-financiero/fabric/Financial Model.SemanticModel/definition/tables/_Medidas.tmdl#REAL (Fees & other)` - medida de Revenue.
- `reporting-financiero/scripts/validar_ficheros_grupo.py` - reproducción y cifras de control.
- `reporting-financiero/docs/contexto/20261103-estado-ficheros-grupo.md`, `reporting-financiero/docs/contexto/PREGUNTAS_PARA_TINKLE.md`, `reporting-financiero/docs/prompts/` y `reporting-financiero/CONTEXT.md` - estado, preguntas abiertas, detalle por fichero y glosario.
