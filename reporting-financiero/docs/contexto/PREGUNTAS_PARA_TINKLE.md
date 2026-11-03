# Preguntas para Tinkle, TXT de Grupo

Estado a 2026-11-03. Las respuestas recibidas proceden de la persona que llevó el proyecto al inicio, no de Tinkle directamente.

## Respondidas

- **Código corto de cliente** (`IKEA`, `01500400`...): es el código de cliente en Magnitude. Hay que generarlo como columna nueva en `Dim_Clientes`. Referencia: `Revenue 2026 FT3.xlsm` (tarea abierta).
- **Destino de los ficheros**: Magnitude (confirmado de forma implícita por la respuesta anterior).
- **Códigos de Ageing** (plantilla Excel):

| Código | Concepto |
|---|---|
| GRICFLAG | Intercompany flag (1 = Grupo) |
| GRPROV | Provisión por dudoso cobro (siempre en negativo) |
| GRWIP | Total Work in progress |
| GRWIP1 | WIP 0-365 días |
| GRWIP9 | WIP más de 1 año |
| GR0 | Current (not due) |
| GR1 | 0-30 días |
| GR2 | 30-60 días |
| GR3 | 60-90 días |
| GR4 | 90-120 días |
| GR5 | 121-180 días |
| GR8C | 181-365 días |
| GR9C | Más de 1 año |
| GRRL | Límite de riesgo |
| (calculado) | Total sin límite de riesgo |

- **GRICFLAG**: indicador de intercompany, no es un tramo. En el TXT de marzo aparece con valor 1 en clientes del Grupo (`HAVAS474`, `ICHAVASWW`, `ESP016TIN637`, `ICESP046`, `ESP067COM550`).
- **GRICFLAG (comprobado con datos)**: casi seguro sale de `Aging_Clientes.Interno = 'Y'`. Falta la verificación final con el código Magnitude de cliente.
- **Revenue**: el dato real sale de `Fact_Actuals` y el importe es el total. Comprobado con datos: es la medida `REAL (Fees & other)` (ingresos menos coste de producción), acumulada del año, con el signo invertido y en miles. Cuadra en 4 de 5 sociedades; en COMM hay una diferencia del 0,24% pendiente de explicar.
- **Working_Capital**: la lógica de cálculo no se documentó en las reuniones.
- **CashFlow**: no está en el Excel porque es información específica para el reporting de Grupo. Existe una macro que lo calcula, pero no se facilitó.

## Pendientes

1. El fichero de marzo compartido, ¿es exactamente lo que se genera cada mes para Grupo, o tiene alguna diferencia (formato, filtros) respecto al proceso real?
2. Ageing: todo apunta a que solo se exportan clientes (plantilla, fichero de marzo y la reunión del 27 de abril, donde se dijo que el Grupo "todavía" no pide aging de proveedores). ¿Sigue siendo así?
3. Ageing: en contabilidad hay provisión por dudoso cobro (cuenta 490: COMM -395.437 €, CONS -133.991 €), pero el TXT de marzo no lleva líneas `GRPROV`. ¿Debe informarse? Si es así, ¿cómo se reparte por cliente, si en contabilidad es un único apunte por sociedad?
4. Ageing: `GRRL` (límite de riesgo) no puede informarse porque no hay datos de límites de crédito. ¿Se confirma que no hace falta hasta que se facilite ese fichero? ¿Y `GRWIP1`/`GRWIP9`?
5. Código de cliente Magnitude: el Excel `Revenue 2026 FT3.xlsm` no cubre todos los clientes. De los 167 códigos usados en los TXT de marzo, faltan 21 en el Excel, y 19 de ellos en todos los Excel del proyecto: `ARTURO`, `ESP001GEO98`, `ESP016CAR757`, `ESP016MAG821`, `ESP036TEL906`, `ESP066RIC328`, `ESP066RIC659`, `ESP066RIC8`, `ESP066RIC85`, `ESP070RIC138`, `ESP070RIC176`, `ESP070RIC199`, `ESP070RIC241`, `ESP070RIC297`, `ESP070RIC61`, `ESP070RIC806`, `ESP070RIC872`, `ICESP046`, `SAC257` (`RENFE` y `ESP066OPI154` solo aparecen en otros Excel). ¿Existe un maestro completo de clientes de Magnitude? Es bloqueante para Ageing: aplicando el mapeo del Excel a las facturas del aging de marzo solo se reproducen 192 de las 280 líneas del TXT, porque faltan códigos y porque algunos clientes tienen un código distinto (por ejemplo, el genérico `16300001` y los intercompany). Hace falta el maestro que se usó para generar el TXT de marzo. En Revenue el mismo Excel reproduce 132 de 172 líneas: va mejor, pero también hay clientes con otro código (por ejemplo, `ESP013TEL489` en el Excel frente a `ESP036TEL906` en el TXT).
6. Pendiente_Facturar: revisar juntos el cálculo (ver propuesta de validación en el prompt de Pendiente_Facturar).
7. Working_Capital: ¿cuál es la lógica de cálculo, o son líneas que se introducen a mano en Magnitude?
8. CashFlow: ¿se puede conseguir la macro que lo calcula?
9. CashFlow: el fichero de la carpeta CashFlow tiene formato de listado de Oracle ("HMES - Asientos con contrapartida fija"), no el formato de líneas Magnitude del resto. ¿Ese listado es lo que se entrega a Grupo, o es la entrada de la macro?
10. CashFlow: al principio de cada línea aparece un código de compañía (ej. `53`). ¿Qué código interno es?
