# Reporting financiero

Reporting financiero y de control de gestión de Tinkle (grupo Havas): sustituye
los Excel de cierre, presupuesto y rentabilidad por un modelo común en Microsoft
Fabric que alimenta informes, Planning y los ficheros de reporting de Grupo.

## Language

Cuando un dato se mide o se confirma con el cliente, se añade debajo con fecha
(`**Medido el AAAA-MM-DD**: ...`). Si una afirmación resulta falsa, no se borra:
se añade `**CORRECCIÓN AAAA-MM-DD**: ...` con la evidencia y dónde está.

### Organización

**Sociedad**:
Entidad legal de Tinkle que lleva su propia contabilidad y se reporta al Grupo.
_Avoid_: compañía, empresa, entidad

**Grupo**:
Havas, el grupo empresarial al que pertenece Tinkle y al que se reporta cada cierre.
_Avoid_: corporativo, matriz

**HAPA**:
Sociedad comprada por el Grupo (Acento) que se reporta aparte con su propio plan de cuentas.
_Avoid_: Acento

**Portugal**:
Sociedad portuguesa de Tinkle, que llega en un extracto contable propio con su propio plan de cuentas.
_Avoid_: PT, sociedad de Portugal

**Directora**:
Persona responsable de un área de negocio, que agrupa equipos, clientes y centros de coste y por la que se analiza el P&L.
_Avoid_: responsable, manager

**Equipo**:
Grupo de empleados bajo una directora que atiende a uno o varios clientes.

**Centro de coste**:
Unidad de imputación de gastos, asociada a una directora.
_Avoid_: CDC, CeCo, sección

**Empleado**:
Persona de Tinkle con un coste salarial que se reparte entre clientes según su dedicación.
_Avoid_: recurso, persona asignada

### Fuentes

**Oracle**:
ERP del que salen los movimientos contables reales de las sociedades de Tinkle.

**Magnitude**:
Sistema financiero del cliente que entrega datos a Fabric y recibe los ficheros de Grupo.
**Confirmado el 2026-10-26** (Adrián Valbuena): es un sistema del cliente y funciona en los dos sentidos, como origen y como destino.

**MMS**:
Sistema operativo de órdenes y campañas por cliente que da la previsión de ingresos y producción.

**Extracto**:
Fichero Excel o CSV que el equipo financiero deposita en la carpeta compartida para un periodo.
_Avoid_: export, descarga

**Maestro**:
Fichero de referencia (clientes, sociedades, cuentas, mapeos, centros de coste, RRHH) que clasifica los extractos.

### Contabilidad y reporting

**Cierre**:
Proceso mensual en el que finanzas consolida los datos reales de un periodo y genera el reporting.

**Periodo**:
Mes contable de un ejercicio, con formato `AAAA.MM` en los ficheros de Grupo.
_Avoid_: mes de cierre

**Real**:
Importe contable registrado de un periodo ya cerrado, procedente de Oracle, HAPA o Portugal.
_Avoid_: actuals, ASOC01, statutory

**Cuenta origen**:
Cuenta del plan contable propio de cada fuente (Oracle, HAPA o Portugal).

**Cuenta Magnitude**:
Cuenta del plan común de Magnitude (por ejemplo `X705000`) a la que se traduce cada cuenta origen.
_Avoid_: cuenta común, cuenta normalizada, cuenta mapeada

**Mapeo de cuentas**:
Equivalencia entre una cuenta origen y su cuenta Magnitude.

**Línea de reporte**:
Fila de un estado financiero (Balance o P&L) con su etiqueta, orden y formato, independiente de las cuentas.

**P&L**:
Cuenta de resultados de un periodo.
_Avoid_: PyG, cuenta de pérdidas y ganancias

**Balance**:
Estado de activo (assets) y pasivo (liabilities) a cierre de un periodo.

**Checklist**:
Libro de cierre que finanzas revisa cada mes con balance, P&L y desgloses de cuentas, hoy reproducido en el informe Checklist (Oracle).

**Intercompañía**:
Operación entre sociedades del Grupo, que se identifica aparte en el reporting.
_Avoid_: intercía, IC

### Presupuesto y previsión

**Presupuesto**:
Plan anual aprobado de P&L por sociedad y cuenta Magnitude.
_Avoid_: budget, B01

**Forecast**:
Reestimación del año completo que combina real en los meses cerrados con previsión en los abiertos.
_Avoid_: FCT, previsión

**FT3 / FT8**:
Ediciones del forecast del ejercicio, que se diferencian en qué meses están ya cerrados.
_Avoid_: FC3, FC8
Pendiente de confirmar: FT3 se haría en el cuarto mes, tras el primer trimestre, y FT8 en el noveno. Falta saber si FT8 es acumulado.

**Planning**:
Hojas de captura en Fabric donde las directoras revisan el forecast de revenue y las dedicaciones.

### Rentabilidad

**Revenue**:
Ingreso de un cliente en un periodo.
_Avoid_: ingresos, facturación

**Honorarios**:
Parte del revenue que corresponde a los fees de Tinkle por el servicio (cuenta Magnitude `X705000`).
_Avoid_: fees

**Producción**:
Parte del revenue que corresponde a trabajos o compras de terceros repercutidos al cliente (cuenta Magnitude `X700000`).

**Coste de producción**:
Coste de terceros asociado a la producción de un cliente (cuenta Magnitude `X600000`).

**Gross Income**:
Honorarios más producción menos coste de producción de un cliente.
_Avoid_: margen bruto, GI
**Medido el 2026-10-26**: así lo calcula la medida `Gross Income Real` del `Financial Model`; en MMS se calcula igual por la columna `CATEGORIA`.

**Dedicación**:
Porcentaje del tiempo de un empleado asignado a un cliente dentro de un equipo.
_Avoid_: asignación, imputación

**Coste imputado**:
Coste de un empleado multiplicado por su dedicación a un cliente.

**Contribución**:
Gross Income de un cliente menos su coste imputado.
_Avoid_: margen, rentabilidad (cuando se habla del importe)
**Medido el 2026-10-26**: la medida `Contribution MMS 2026` usa el Gross Income de MMS, no el real, y solo las dedicaciones de tipo `CLIENTE`.

### Cobros, pagos y Grupo

**Aging**:
Antigüedad a una fecha de las facturas pendientes de cobro (clientes) o de pago (proveedores), agrupada en tramos.
_Avoid_: Ageing (salvo en el nombre del fichero de Grupo), vencimientos

**Tramo de aging**:
Intervalo de días vencidos en el que cae una factura pendiente (por ejemplo 61-90 o más de un año).
_Avoid_: bucket

**Pendiente de facturar**:
Importe de trabajo ya realizado para un cliente que todavía no se ha facturado.

**Working capital**:
Fichero de capital circulante que se reporta al Grupo cada cierre.

**Cash flow**:
Fichero de movimientos de tesorería del ejercicio que se reporta al Grupo cada cierre.

**Fichero de Grupo**:
TXT con formato fijo que Tinkle entrega al Grupo cada cierre, uno por sociedad y tipo (Balance, Saldos 4_7, Ageing, Revenue, Pendiente_Facturar, Working_Capital, CashFlow).
_Avoid_: export, salida, txt

**Saldos 4_7**:
Fichero de Grupo con los saldos de las cuentas de los grupos 4 y 7 por sociedad.

## Relationships

- Una **Sociedad** tiene muchas **Cuentas origen**; cada **Cuenta origen** tiene exactamente un **Mapeo de cuentas** a una **Cuenta Magnitude**.
- Una **Línea de reporte** agrupa una o varias **Cuentas Magnitude**, cada una con su signo.
- Una **Directora** tiene uno o varios **Equipos** y **Centros de coste**; un **Equipo** pertenece a una sola **Directora**.
- Un **Cliente** tiene una clave en **Oracle** y otra en **MMS**; el maestro de clientes las une.
- Un **Empleado** tiene una o varias **Dedicaciones**; la suma de sus dedicaciones no supera el 100 %.
- El **Coste imputado** de un **Cliente** es la suma de los costes imputados de las **Dedicaciones** a ese cliente.
- La **Contribución** de un **Cliente** es su **Gross Income** menos su **Coste imputado**.
- Un **Forecast** toma el **Real** en los periodos cerrados y **MMS** como propuesta en los abiertos, que la **Directora** puede corregir en **Planning**.
- Cada **Cierre** produce un **Fichero de Grupo** por **Sociedad** y tipo.

## Example dialogue

> **Dev:** "Para el **Gross Income** de Repsol en marzo, ¿sumo **Honorarios** y **Producción** del **Real**?"
> **Finanzas:** "Sumas honorarios y producción y restas el **Coste de producción**. Y si lo quieres comparar con **MMS**, cruzas por el maestro de clientes, porque Oracle y MMS usan códigos distintos."
> **Dev:** "¿Y la **Contribución**?"
> **Finanzas:** "Al **Gross Income** le restas el **Coste imputado**, que sale de las **Dedicaciones** que cada **Directora** informa en **Planning**."

## Flagged ambiguities

- "Magnitude" aparecía como destino de los **Ficheros de Grupo** y como origen de datos. Resuelto: es un sistema del cliente que hace las dos cosas. Pendiente: qué datos concretos entrega a Fabric y si **MMS** es un módulo de **Magnitude** o un sistema aparte.
- "Real", "Actuals", "ASOC01 - Statutory data" y "REAL (Fees & other)" aparecen para el dato contable. Resuelto: el término es **Real**; las variantes son nombres de medidas.
- "FT3/FT8" y "FC3/FC8" aparecen mezclados. Resuelto: **FT3 / FT8** es la edición del forecast; FC3/FC8 son nombres de medidas de Planning.
- "Sección", "CDC", "CeCo" e "iniciales Captio" se usan para el **Centro de coste**. Pendiente de confirmar que la sección de un cliente es siempre su centro de coste.
- "Aging" (informes) y "Ageing" (fichero de Grupo) son el mismo concepto. Resuelto: **Aging**.
- El significado de los códigos de tramo del fichero de Grupo (`GR0` a `GR9C`, `GRICFLAG`) está pendiente de confirmar con el cliente (ver `docs/contexto/PREGUNTAS_PARA_TINKLE.md`).
