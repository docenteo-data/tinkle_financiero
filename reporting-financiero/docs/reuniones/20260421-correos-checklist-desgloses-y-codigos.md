# Correos del 21 y 22/04/2026: checklist, desgloses y códigos de empresa

- Fechas: 21/04/2026 13:43 (tras la reunión I) y 22/04/2026 10:33 y 11:05 (día de la reunión II).
- Remitente: Fátima Sánchez de Pazos (Tinkle, finanzas). En copia: Josep Zoppetti (Tinkle, finanzas).
- Destinatarios: Álvaro Montero y Alejandro Peris (Docenteo) el 21/04; Álvaro Montero el 22/04.
- Fuente: carpeta de OneDrive `02.Clientes/04.Tinkle/Reporting financiero/3.Reuniones`, ficheros `Checklist - primera sesión.msg`, `Detalle de checklist - Información relevante (Desgloses) .msg` y `Códigos de empresas - ESP0XX y PTE019.msg` (este último solo trae una captura de pantalla).
- Es información escrita por la cliente, más fiable que una transcripción, pero no verificada contra datos.

## 1. Checklist - primera sesión (21/04)

Apuntes de la cliente sobre la reunión I.

### Situación de las sociedades

- Tinkle España: Oracle, con cinco sociedades (Communications, Consultants, European, Onion y Jazz).
- Tinkle Portugal: un Excel que envía la consultoría externa.
- HAPA: Sage, en un Excel separado.

### Calendario y unidades de reporte

- Se reporta siempre en miles, tanto el cierre como los presupuestos (internamente pueden ver los cierres mensuales en unidades).
- El cierre se reporta el tercer día laborable del mes.
- Presupuesto del año siguiente: en septiembre. FT3: en abril, con enero a marzo reales. FT8: se publica en septiembre, con enero a agosto reales y septiembre a diciembre proyectados. Algunos años hay un FT5.

### Pestañas del Checklist

- Oracle: base de datos de las sociedades españolas. Se saca de Databox (Financial, Contabilidad, Centros de coste), normalmente en Excel, aunque admite CSV. Se ordena por fecha contable de más antigua a más reciente, se aplica separador de miles y se quita la fila final de totales. Se pega en la pestaña Oracle; desde la columna AK hay fórmulas que alimentan el resto de pestañas.
- Los asientos en divisa STAT no se tienen en cuenta.
- Assets, Liabilities y P&L: salida del cierre del mes. Importes acumulados hasta el mes de cierre y comparados con el forecast o el presupuesto. Hacen falta tres consolidados: todas las sociedades; España; y España más Portugal.
- Las cuentas de Magnitude empiezan por A las de activo, por P las de pasivo y por R las de P&L.
- COA Oracle: mapeo de las cuentas contables españolas a las cuentas de Oracle (columnas D a G). Puede cambiar si el grupo cambia el mapeo o se crean cuentas nuevas. En HAPA se crean cuentas nuevas todos los meses que hay que mapear.
- BSS OF: sumas y saldos para comprobar que cuadra a cero y que la pestaña Oracle está bien.
- PL OF: resultado de cada sociedad sacado de Oracle, también como comprobación.
- Pestañas de presupuesto: FT8, FT3 y B01 (y FT5 los años que lo hay).
- Portugal: pestaña con lo que se reporta, que sale de ficheros preparados aparte.

### Portugal

- Balancete analítico (sumas y saldos): se quitan subtotales y filas en blanco y se pone el signo, porque todos los importes vienen en positivo. Plan de cuentas portugués.
- La gestoría no prevé el impuesto de sociedades; Tinkle lo calcula para el Checklist.
- Actuals Portugal: se pega el balancete; la columna G mapea la cuenta portuguesa al plan del grupo con la pestaña MAPPING PORTUGAL. Al Checklist van las columnas J y K de la pestaña Portugal.
- Las cuentas P44200 y R69500 (impuesto de sociedades) se ajustan a mano con una previsión del 21 % sobre el resultado del balancete.

### Puntos que la cliente pidió para la reunión del 22/04

1. Cuentas X.
2. Reclasificaciones de centros de coste.
3. HAPA.
4. Información necesaria (amortizaciones, cuenta 480 y similares).
5. Presupuestos.
6. Si daba tiempo: ficheros que Havas da para subir a Magnitude. La cliente avisa de que esta plataforma "va a cambiar en breve".

## 2. Detalle de checklist - Información relevante (desgloses) (22/04)

Desgloses que la cliente necesita a partir de Oracle (son las pestañas auxiliares del Checklist):

| Cuenta o grupo | Contenido |
|---|---|
| Grupo 1 (FFPP) | Fondos propios, por sociedad. |
| 24 (Part) | Participaciones en el grupo; solo Communications. Casi estática: solo cambia con compra o venta de acciones. |
| 20 y 21 | Activos e inmovilizado. |
| 2 y 28 (FA) | Activos y amortización acumulada. |
| 68 | Gasto de amortización mensual. |
| 4007 | Costes pendientes de recibir (provisión). |
| 4009 | Costes pendientes de recibir de clientes (provisión). |
| 4309 | Facturas pendientes de emitir a clientes (provisión). |
| 4000 y 430 | Proveedores y clientes: se usan para cuadrar con los agings de proveedores y de clientes. |
| 460 | Personal: anticipos, embargos, donaciones, comida, transporte y formación. |
| 465 | Salarios pendientes de pago (bonus, gratificaciones). |
| 475, 4751 y 4752 | Impuestos; IRPF por proveedor; impuesto de sociedades. |
| 476 | Seguridad social. |
| 480 | Periodificaciones (facturas que cubren varios meses y se imputan mes a mes). Su detalle está en la pestaña "Period 2025". |
| 490 | Provisión de clientes que no se van a cobrar. |
| 52 | Cuenta puente de las tarjetas VISA; debería estar a cero. |
| 555 | Partidas pendientes de aplicar; debería estar siempre a cero. |
| 572 | Bancos. |
| 26 | Fianzas. Se controlan a mano fuera del sistema porque todas van a la misma cuenta. |
| 566 | Depósitos de clientes. |
| Grupo 6 | Pestañas de gastos: sirven para decidir provisiones de proveedores con gasto recurrente que un mes no aparece. Necesitan sociedad, cuenta de Oracle, cuenta contable española y nombre del tercero (proveedor). |
| 621 | Gasto de alquileres. |
| 64 | Gastos de personal. |

## 3. Códigos de empresas - ESP0XX y PTE019 (22/04)

Sin texto: una captura de Magnitude (pantalla con las acciones Publicar, Exportar, Imprimir y Ejecutar reglas) con las unidades de informe del periodo 2026.03, categoría R:

| Unidad de informe | Sociedad |
|---|---|
| ESP066 | Tinkle Communications, S.L. |
| ESP067 | European Public Relations Services (nombre cortado en la captura) |
| ESP068 | Jazz Alternative Thinking, S.L. |
| ESP069 | Onion Digital Services, S.L. |
| ESP070 | Tinkle Consultants, S.L. |
| PTE019 | Tinkle Portugal (Sociedade Unipessoal, nombre cortado en la captura) |
| ESP073 | Acento Public Affairs, S.L. (HAPA) |

## Requisitos pedidos por la cliente

1. Tres consolidados en el cierre: todas las sociedades, España, y España más Portugal.
2. Reporting en miles para cierre y presupuestos.
3. Comparación del real acumulado con el forecast o el presupuesto.
4. Los desgloses de la tabla de la sección 2, con detalle por sociedad y, en gastos, por cuenta de Oracle, cuenta española y proveedor.
5. Cuadre de las cuentas 4000 y 430 con los agings de proveedores y clientes.
6. Mapeo mensual de cuentas nuevas de HAPA.
7. Cálculo de la previsión del impuesto de sociedades de Portugal (21 %).

## Tareas y puntos pendientes

1. Temas pedidos para la reunión del 22/04 (lista de la sección 1). Comprobar en el acta de la reunión II cuáles se trataron y cuáles quedaron pendientes.
2. Ficheros de Havas para subir a Magnitude: planteado como "si nos da tiempo"; comprobar si se vieron.
3. Cambio de la plataforma Magnitude anunciado "en breve" (21/04): sin fecha ni detalle. Riesgo para los ficheros de Grupo.
4. Pestaña de Portugal: la cliente dice que sale de "otros ficheros separados"; no se detalla cuáles, salvo el balancete y Actuals Portugal.
5. Control de fianzas (cuenta 26): hoy es manual y fuera del sistema; no se dice si debe entrar en el alcance.
6. FT5: existe algunos años; no está contemplado en Planning (solo FT3 y FT8).

## Términos para el glosario

- FT3 y FT8: ediciones del forecast con 3 y 8 meses reales (abril y septiembre). Resuelve la duda pendiente en `CONTEXT.md`. FT5 existe algunos años.
- B01: presupuesto anual (pestaña del Checklist).
- Unidad de informe: código de Magnitude para cada sociedad (ESP066 a ESP070, ESP073 y PTE019). Completa la relación de sociedades de `CONTEXT.md`.
- Databox: herramienta de la que se extrae el mayor de Oracle.
- Divisa STAT: asientos estadísticos de Oracle que no se usan.
- Balancete analítico: sumas y saldos de Portugal que entrega la gestoría.
- Prefijos de cuenta Magnitude: A activo, P pasivo, R P&L.
- Sage: sistema contable de HAPA. `CONTEXT.md` no lo menciona.
