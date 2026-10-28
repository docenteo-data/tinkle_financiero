# Reuniones con Tinkle

Actas de las sesiones de requerimientos con Tinkle (abril y mayo de 2026) y de los correos de la cliente; los originales (transcripciones .docx, grabaciones .mp4 y correos .msg) están en OneDrive, en `02.Clientes/04.Tinkle/Reporting financiero/3.Reuniones`, y no se versionan; las actas son resúmenes revisados contra la transcripción completa, y como la transcripción automática tiene errores, lo dudoso está marcado en cada acta.

## Actas

| Código | Fecha | Tema | Participantes de Tinkle | Fichero |
|---|---|---|---|---|
| C | 21/04/2026 y 22/04/2026 | Correos: apuntes del checklist, desgloses de cuentas y códigos de sociedad en Magnitude | Fátima Sánchez de Pazos (remitente), Josep Zoppetti (en copia) | [20260421-correos-checklist-desgloses-y-codigos.md](20260421-correos-checklist-desgloses-y-codigos.md) |
| I | 21/04/2026 | Requerimientos I: checklist de cierre | Josep Zoppetti, David Marin, Fátima Sánchez de Pazos; Antonio Serrano (solo saluda; empresa y papel no confirmados) | [20260421-requerimientos-1-checklist.md](20260421-requerimientos-1-checklist.md) |
| II | 22/04/2026 | Requerimientos II: cuentas X, HAPA y centros de coste | Josep Zoppetti, Fátima Sánchez de Pazos | [20260422-requerimientos-2-cuentas-y-hapa.md](20260422-requerimientos-2-cuentas-y-hapa.md) |
| III | 24/04/2026 | Requerimientos III: MMS y presupuesto | Josep Zoppetti, Fátima Sánchez de Pazos | [20260424-requerimientos-3-mms-y-presupuesto.md](20260424-requerimientos-3-mms-y-presupuesto.md) |
| IV | 27/04/2026 | Requerimientos IV: presupuesto y rentabilidad | Fátima Sánchez de Pazos, Josep Zoppetti | [20260427-requerimientos-4-presupuesto-y-rentabilidad.md](20260427-requerimientos-4-presupuesto-y-rentabilidad.md) |
| V | 07/05/2026 | Requerimientos V: forecast | Fátima Sánchez de Pazos, Josep Zoppetti | [20260507-requerimientos-5-forecast.md](20260507-requerimientos-5-forecast.md) |

## Registro de pendientes

Cómo leer la tabla:

- Origen: código del acta y marca de tiempo tal como figura en ella; entre paréntesis, el id interno del acta (T tarea, R requisito, D duda). En el acta C no hay marcas: "C req. n" es el requisito n, "C pend. n" el punto pendiente n y "C sec. n" la sección n.
- Relación: "Preg. n" es la pregunta n de `../contexto/PREGUNTAS_PARA_TINKLE.md`; "Téc. X" es el id X de la sección 13 de `../contexto/Documentacion_Tinkle_Financiero.md` (sus ids D no son las dudas D del acta II); "Glos. término" es una entrada de `../../CONTEXT.md`.
- Estado a 2026-05-07: abierto, parcial o cerrado, con la marca de la reunión posterior que lo cierra o lo retoma.
- No se incluyen los puntos que el acta de origen da por cumplidos o descarta: I T1 y I T22 (hechos), I T18 e I T23 (no son tareas), II T2 (oferta no aceptada), II T5 (códigos enviados por correo el 22/04), II T10 y II T15 (no son compromisos), II D7 y II D9 (resueltas por los correos), II R6, R12 y R27 (no son peticiones del cliente) y la forma de pago del maestro de clientes (IV 28:04, descartada). Las dudas que son solo de lectura de la transcripción (nombres y cifras) están en la sección "Datos dudosos" y no se repiten aquí.

### Checklist y cierre

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-001 | requisito | Definir los consolidados del cierre: hoy hay sin Portugal y con Portugal, el correo pide todas las sociedades, España, y España más Portugal, y David plantea añadir HAPA. | sin responsable | C req. 1; I 0:35:15 (R18); I 0:21:23 a 0:22:45 | abierto | Glos. Sociedad; Glos. Checklist |
| P-002 | requisito | Reportar en miles el cierre y el presupuesto, sin decimales hacia Magnitude, con opción de ver unidades y controlando los descuadres por redondeo. | sin responsable | C req. 2; I 1:03:14 a 1:06:32 (R11); III 33:46, 34:33, 35:30 | abierto | Glos. Fichero de Grupo |
| P-003 | requisito | Comparar el real con el presupuesto o el forecast en vista mensual y acumulada desde el 1 de enero hasta el mes de cierre. | sin responsable | C req. 3; I 1:03:14 a 1:06:32 (R11), 1:26:08; III 27:40 | abierto | Glos. Presupuesto; Téc. M6 |
| P-004 | requisito | Comparar siempre con el último presupuesto publicado, sin reajustarlo cada mes, y poder cambiar la edición de referencia (B01, FT3...). | sin responsable | I 1:15:54 a 1:18:32 (R12, R13) | abierto | Glos. Presupuesto; Glos. FT3 / FT8 |
| P-005 | requisito | Trazabilidad: explicar cualquier saldo con sus movimientos hasta el asiento y ver movimientos en el checklist, no solo saldos. | sin responsable | I 1:27:06 a 1:29:43 (R6); II 2:41, 3:39 (R2), 13:06 (R3) | abierto | Glos. Checklist |
| P-006 | requisito | Desgloses por cuenta de la tabla del correo (fondos propios, inmovilizado, provisiones, personal, impuestos, 480, bancos, gastos...), por sociedad y, en gastos, por cuenta de Oracle, cuenta española y proveedor, con el máximo detalle en los auxiliares. | sin responsable | C req. 4 y sec. 2; I 0:12:57 a 0:16:46 (R7); II 37:51 a 1:12:05 | abierto | Glos. Checklist |
| P-007 | requisito | Desglose de las provisiones 4007, 4009 y 4309, que preguntan siempre los auditores. | sin responsable | II 40:31, 41:25, 43:02 (R23) | abierto | Glos. Pendiente de facturar; Preg. 9 |
| P-008 | requisito | Informe mensual de gastos de las cuentas 62 con filtro de cuenta. | sin responsable | II 1:02:21 (R20) | abierto | - |
| P-009 | requisito | Informe mensual del alquiler de cada oficina. | sin responsable | II 1:03:57 (R21) | abierto | - |
| P-010 | duda | Si el control de fianzas (cuenta 26), hoy manual y fuera del sistema, entra en el alcance y si se reporta con detalle a Magnitude. | sin responsable | C pend. 5; II 59:19, 1:00:51, 1:01:06 (R18, D20) | abierto | - |
| P-011 | duda | Si las cuentas 52 y 555 se reportan o solo se controlan internamente (pregunta de Docenteo). | sin responsable | II 58:06, 58:31 (D21) | abierto | - |
| P-012 | requisito | Control mensual del intercompany entre sociedades de Tinkle (el total debe dar cero), aunque el Grupo solo lo pida en mayo y octubre. | sin responsable | II 1:09:53, 1:10:18 (R28) | abierto | Glos. Intercompañía; Preg. 5 |
| P-013 | requisito | Reducir la carga del Excel actual (tamaño y tiempos de guardado, sobre todo en diciembre). | sin responsable | I 1:30:10 a 1:30:35 (R15) | abierto | - |
| P-014 | requisito | Conservar una foto de cada cierre (P&L, activo y pasivo) y decidir qué foto queda fija en el histórico. | sin responsable | II 16:16, 16:52 (R8, D17) | abierto | Téc. O3 |
| P-015 | tarea | Anotar las pestañas de tablas dinámicas del checklist con su finalidad, con la explicación de Josep. | Álvaro Montero (anotar); Josep Zoppetti (explicar) | II 35:26, 37:26, 37:51 (T9, R26) | abierto | Glos. Checklist |
| P-016 | decisión | Partir del dato bruto de los extractos de Oracle y Databox, sin tocarlo a mano, y que el formato lo haga el modelo. | sin responsable | III 2:51 a 6:36; IV 6:52, 8:07, 10:40 | parcial: IV lo acepta como punto de partida, pendiente de confirmar en la práctica | Glos. Extracto; Téc. M2 |
| P-017 | tarea | Subir a Teams el informe de asientos de marzo ("prueba marzo") en Excel y CSV, tal como sale de Databox. | Josep Zoppetti | III 7:06 | abierto: no consta en IV ni V | Téc. D1 |
| P-018 | duda | Plazo real de cierre: Josep cierra los periodos el primer o segundo día hábil y el correo dice que se reporta el tercer día laborable. | sin responsable | I 0:42:09; C sec. 1 | abierto | Glos. Cierre |
| P-019 | duda | Calendario del Grupo con las fechas de cierre y de presupuesto: existe, pero no se ha compartido. | sin responsable | I 1:08:50, 1:11:06 | abierto | Glos. Cierre |
| P-020 | decisión | Posible fusión de sociedades (de cinco a dos o tres), comentada por David con Josep. | sin responsable | II 32:57, 33:14 | abierto | Glos. Sociedad; Téc. M8 |

### HAPA y Portugal

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-021 | tarea | Explicar el proceso de HAPA (Sage, saldos, diario). | Josep Zoppetti | I 1:30:53 (T10) | cerrado en II (2:10 a 10:41) | Glos. HAPA |
| P-022 | tarea | Obtener de HAPA un diario de movimientos tipo Oracle con analítica, subirlo y avisar a Docenteo cuando esté claro; sin fecha. | Josep Zoppetti | I 0:07:25 (T5); II 4:12, 4:29, 5:59, 7:02 (R1, T21, D2), 1:55:34 | parcial: en II 4:51 ya había recibido un Excel que no le sirve; sigue pendiente | Glos. HAPA; Téc. N2 |
| P-023 | duda | Formato del diario de HAPA (columnas, analítica) y si será estable una vez parametrizado. | sin responsable | II 5:14, 5:59 (D1, D25) | abierto | Glos. HAPA |
| P-024 | tarea | Posible visita a HAPA, aprovechando un viaje a Madrid, para ver qué fichero tipo Oracle pueden sacar. | Josep Zoppetti | II 5:59 (T1) | abierto: no consta en actas posteriores | - |
| P-025 | decisión | Integrar HAPA igual que Portugal (sumas y saldos, mapeo y checklist propio) hasta tener el diario. | sin responsable | II 2:41, 33:50, 34:02, 1:55:34 | parcial: acuerdo de intención; Fátima lo deja pendiente del diario | Glos. HAPA; Téc. M7 |
| P-026 | decisión | Presentación de HAPA: por separado (para poder compartirlo con HAPA) y agregado, como columna o pestaña, y si su checklist se unifica con el general. | sin responsable | I 0:08:07, 0:22:18 a 0:22:45 (R5); II 9:18 (D18) | abierto | Glos. HAPA |
| P-027 | tarea | Provisión del impuesto de sociedades de HAPA: hablar "con ellos" (por contexto, la contabilidad de HAPA) entre asiento con reversión o ajuste manual. | Josep Zoppetti | II 10:47, 10:49 (T4, D5, D23) | abierto | Glos. HAPA |
| P-028 | duda | Si HAPA seguirá con Sage o cuál será su solución futura. | sin responsable | I 0:12:57 a 0:16:46 (T16, T17) | abierto | Glos. HAPA |
| P-029 | duda | Nombre registrado actual de HAPA y su relación con "Acento", "APA", "Acento Public Affairs, S.L." (ESP073) y "H Advisor". | sin responsable | I 0:23:37; II 10:01; C sec. 3; IV 30:41 a 31:25 | abierto; resuelto después: `CONTEXT.md` (medido el 2026-10-27) la registra como H Advisors Asuntos Públicos España, S.L. en el modelo y Acento Public Affairs, S.L. (ESP073) en Magnitude, con Sage | Glos. HAPA |
| P-030 | requisito | Pestaña propia de HAPA (probablemente la "H Advisor" de la transcripción) en el presupuesto. | sin responsable | IV 31:04, 31:17, 31:25 | abierto | Glos. HAPA |
| P-031 | requisito | Calcular la previsión del impuesto de sociedades de Portugal al 21 % (cuentas P44200 y R69500). | sin responsable | C req. 7; I 1:19:13 a 1:25:42 | abierto | Glos. Portugal |
| P-032 | requisito | Detalle de los asientos de Portugal con su plan de cuentas original. | sin responsable | I 1:27:06 a 1:29:51 (R17) | abierto | Glos. Portugal |
| P-033 | tarea | Valorar si el extracto de contas de Portugal que Josep dice haber subido sirve como detalle de movimientos. | Docenteo (sin persona) | II 5:38, 7:02 (T3) | abierto | Glos. Portugal; Téc. M7 |
| P-034 | duda | Qué "otros ficheros separados" alimentan la pestaña de Portugal, además del balancete y Actuals Portugal. | sin responsable | C pend. 4 | abierto | Glos. Portugal |
| P-035 | duda | Cuál de los extractos PTG de la gestoría, uno de ellos por centros de coste, es el que se usa (Josep lo consulta con Fátima). | sin responsable | I 0:29:11, 0:29:23 | abierto | Glos. Extracto |
| P-036 | tarea | Localizar y compartir el Excel con el detalle de Portugal por empresa y mes. | Fátima Sánchez de Pazos | IV 42:48, 43:11 | abierto | Glos. Portugal |
| P-037 | requisito | Desglosar Portugal dentro del modelo, aunque a Magnitude vaya como una línea única, y definir qué datos hacen falta. | sin responsable | IV 42:16, 42:48, 43:11 | abierto | Glos. Portugal |
| P-038 | requisito | Entrada manual de la facturación de Portugal por cliente y mes (Portugal no está en MMS), actualizada con contabilidad. | Fátima Sánchez de Pazos (actualiza) | V 50:31 a 50:58 | abierto | Glos. Portugal |
| P-039 | duda | Integración futura de Portugal con sus propios sistemas en lugar del balancete, o si seguirá reportándose aparte. | sin responsable | I 0:12:57 a 0:16:46 (R10, T16); V 51:07 | abierto | Glos. Portugal |

### Cuentas X y mapeos

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-040 | tarea | Explicar qué son las cuentas X, las cuentas de amortización y los informes de amortización. | sin responsable | I 1:31:19 a 1:31:33 (T11) | cerrado en II (1:12:32 a 1:38:55; amortizaciones 38:12 a 38:54; repaso 1:55:34) | Glos. Cuenta Magnitude |
| P-041 | duda | Cómo encajan las cuentas X de Oracle con las cuentas Magnitude (prefijos A, P y R), si `CONTEXT.md` pone X705000 como cuenta Magnitude. | sin responsable | I 0:47:56; II 1:13:12; III 45:57 | abierto; resuelto después: `CONTEXT.md` (corrección del 2026-10-27, con el correo C sec. 1) fija que las cuentas Magnitude empiezan por A, P o R y que las X son cuentas analíticas de Oracle (término "Cuenta X") | Glos. Cuenta Magnitude; Glos. Cuenta X |
| P-042 | duda | Si Oracle puede tener el campo de cliente en las cuentas 600 y 700 sin X. | sin responsable | II 1:30:17, 1:38:55 (R7, D3) | abierto | - |
| P-043 | decisión | Mantener las cuentas X como fuente de la rentabilidad por cliente hasta tener otra. | sin responsable | II 1:19:52 (D12) | abierto | Glos. Gross Income |
| P-044 | duda | Si el detalle por cliente de las cuentas X está en Magnitude (Fátima) o solo el total (Josep). | sin responsable | II 1:27:23, 1:29:44 (D24) | abierto | Glos. Magnitude |
| P-045 | duda | Si la auditoría permite ver las cuentas X o deben seguir fuera del reporting (pregunta de Docenteo). | sin responsable | II 1:13:12 (D15) | abierto | - |
| P-046 | requisito | Excluir de los informes las cuentas de cuadre X 999. | sin responsable | II 1:23:52, 1:24:12 (R25) | abierto | - |
| P-047 | requisito | Excluir de la rentabilidad las cuentas X duplicadas (subcuentas 13 y 15) y las de estadística. | sin responsable | II 1:28:24, 1:28:46 (R29) | abierto | - |
| P-048 | duda | Si las cuentas de estadística que Oracle genera para el Grupo afectan a los saldos. | sin responsable | II 1:28:48, 1:29:03 (D14) | abierto | - |
| P-049 | duda | Qué iba a contar Fátima sobre las líneas duplicadas del fichero (unas 400 que podrían ser cuatro); no se retomó. | sin responsable | II 1:31:41 (D26) | abierto | - |
| P-050 | tarea | Dar de alta y mapear cada mes las cuentas nuevas que aparecen en el cierre, sobre todo de HAPA. | Josep Zoppetti | C req. 6; I 0:52:16 a 0:53:54 (T12); II 9:01 (T17) | abierto (recurrente) | Glos. Mapeo de cuentas |
| P-051 | tarea | Diseñar el histórico de mapeos con fecha de vigencia, en una sola tabla y con posibilidad de volver a una versión anterior. | Álvaro Montero | II 14:15, 15:25, 17:11, 17:31, 18:03, 18:25 (T16, R9) | abierto | Glos. Mapeo de cuentas |
| P-052 | decisión | Alcance de un cambio de mapeo: los ejercicios cerrados conservan su mapeo y el cambio se aplica a todo el ejercicio en curso, incluidas las cuentas que cambian de grupo (alquileres). | sin responsable | I 0:53:54 a 0:54:04; II 14:01, 14:54, 15:16, 15:25 (D13) | abierto | Glos. Mapeo de cuentas |
| P-053 | duda | Si Tinkle debe descargar y guardar el histórico de mapeos cada mes (Fátima) o la herramienta lo hace innecesario (Álvaro). | sin responsable | II 17:54, 18:03 (R10) | abierto | Glos. Mapeo de cuentas |
| P-054 | requisito | Mantener el mapeo de varios clientes agrupados en un mismo código de reporting. | sin responsable | I 0:12:57 a 0:16:46 (R8) | abierto | Preg. 3 |

### Magnitude y ficheros de Grupo

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-055 | requisito | Generar los TXT de Grupo desde la información propia, sin depender de la herramienta de Oracle ni de IT del Grupo. | sin responsable | I 0:09:31, 0:11:23 a 0:12:24 (R1); II 23:40, 25:32, 33:50 (R11) | abierto | Preg. 1, 2; Glos. Fichero de Grupo; Téc. O2 |
| P-056 | duda | Qué información de los TXT no está en el checklist ("no toda", según Josep). | sin responsable | I 0:11:12 a 0:11:23 (R2) | abierto | Preg. 1; Glos. Fichero de Grupo |
| P-057 | duda | Qué herramienta de Oracle genera los TXT, qué depende de IT y si el Grupo permitirá generarlos fuera de ella. | sin responsable | I 0:11:23 a 0:12:24 | parcial: II 22:59, 25:12 aclara que el Grupo sube los de Oracle y Tinkle los de Portugal y HAPA | Preg. 1, 13 |
| P-058 | duda | Sustitución de Magnitude (probablemente por Tagetik): cuándo y si cambian el formato o la subida de los TXT. | sin responsable | C pend. 3; I 0:09:31 a 0:10:20; II 24:52 (D11) | abierto | Preg. 2; Glos. Magnitude |
| P-059 | tarea | Ver los ficheros que da el Grupo para subir a Magnitude; se vieron sin detalle y queda por decidir si hace falta otra sesión. | sin responsable | C sec. 1 punto 6 y pend. 2; II 19:26 a 33:50, 1:55:54 (T20) | parcial | Preg. 1; Glos. Fichero de Grupo |
| P-060 | tarea | Enseñar el sistema de reporting web (Magnitude) al equipo. | Josep Zoppetti | I 0:10:24 (T9) | cerrado en II (20:20, 20:37) | Glos. Magnitude |
| P-061 | duda | Qué es el paquete o categoría R de Magnitude (C es consolidado). | sin responsable | II 19:26, 21:18 (D8); C sec. 3 | abierto | Glos. Fichero de Grupo |
| P-062 | duda | Qué contiene la carpeta "engine" de Magnitude ("XT que se generan", probablemente los TXT de Grupo). | sin responsable | III 1:31:51 a 1:31:58 | abierto | Glos. Fichero de Grupo |
| P-063 | requisito | Informe intercompany (LPR) de mayo, octubre y a veces julio: qué datos y formato pide Magnitude; hoy se hace a mano. | sin responsable | II 1:06:03 a 1:09:36 (R22, D16) | abierto | Glos. Intercompañía; Preg. 5 |
| P-064 | tarea | Explicar el proceso de cash flow (macros y exportación de Oracle), que entra en el alcance. | Josep Zoppetti, con Fátima Sánchez de Pazos | III 1:32:34 a 1:33:08 | abierto: no consta en IV ni V | Preg. 13, 14, 15; Glos. Cash flow |
| P-065 | requisito | Salida del presupuesto en el formato de carga de Magnitude (hoy la genera una macro del fichero de presupuesto). | sin responsable | I 0:19:42 a 0:20:07 (R3); IV 28:34 a 29:02 | abierto | Glos. Presupuesto; Téc. M2 |

### MMS

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-066 | tarea | Tratar el fichero de MMS en una sesión. | sin responsable | II 41:25, 1:56:10, 2:00:56 (T24, R24) | cerrado en III (9:53 a 1:29:15) | Glos. MMS |
| P-067 | tarea | Subir los ficheros de MMS de marzo y del 24/04 en Excel y CSV. | Josep Zoppetti | II 1:56:10 (T7); III 51:34, 59:04 a 59:11, 1:02:50 | abierto: no consta en IV ni V | Glos. MMS |
| P-068 | tarea | Terminar la exportación de MMS del 24/04, que no incluye Communications. | Josep Zoppetti | III 59:11, 1:03:23 | abierto | Glos. MMS |
| P-069 | tarea | Sacar el CSV de Databox para tener los dos formatos. | Josep Zoppetti | III 1:02:50, 1:03:23 | abierto | Glos. Extracto |
| P-070 | duda | Si MMS es un sistema aparte o un módulo de Magnitude, y qué relación tienen. | sin responsable | II 1:56:27 (D10); III 9:53 a 12:57, 1:31:51 | parcial: III lo describe como aplicación a medida del IT de Havas; la relación con Magnitude no se trata | Glos. MMS; Glos. Magnitude |
| P-071 | duda | Fecha y frecuencia de la foto de MMS: una madrugada del cierre, programada por Tinkle; falta confirmar si la fecha es fija. | sin responsable | II 1:59:50, 2:00:04 (D19); III 22:22, 1:19:21 | abierto | Glos. MMS |
| P-072 | duda | Cómo comparar la foto de MMS con el cierre real cuando MMS cambia después. | sin responsable | III 1:16:38 a 1:17:05 | abierto | Glos. MMS |
| P-073 | duda | Descuadre de enero a marzo entre el fichero de MMS y el checklist, y en qué consiste la "diferencia identificada" de 38. | sin responsable | III 1:15:22 a 1:17:18 | abierto | Glos. MMS |
| P-074 | requisito | Foto de MMS cercana al cierre para comparar con el presupuesto y decidir provisiones. | sin responsable | III 1:19:21 a 1:21:46 | abierto | Glos. MMS |
| P-075 | requisito | Vincular MMS con contabilidad por número de factura y por código de cliente (propuesto, no validado). | sin responsable | III 1:28:25, 1:28:45, 1:29:15 | abierto | Preg. 3 |
| P-076 | requisito | Seguimiento de pendientes de facturar a clientes por año y mes, y de pendientes de recibir de proveedores con su antigüedad. | sin responsable | III 1:23:42 a 1:27:34 | abierto | Preg. 9, 10; Glos. Pendiente de facturar |
| P-077 | tarea | Aclarar con facturación los pendientes de facturar de 2024 y 2025 (seguimiento habitual, no compromiso de la reunión). | sin responsable | III 1:23:42 a 1:26:41 | abierto | Preg. 9; Glos. Pendiente de facturar |
| P-078 | decisión | Filtro de fechas de la carga de MMS: incluir 2024 y 2025, porque siguen entrando facturas de esos años (2023 está a cero). | sin responsable | III 48:08 a 49:55 | parcial: respondido en la reunión, sin decisión formal | Glos. MMS |
| P-079 | duda | Si los honorarios futuros desde contrato firmado valen para un cliente aún no dado de alta. | sin responsable | III 29:05, 29:54 | parcial: confirmado para contrato firmado, sin respuesta expresa para clientes nuevos | Glos. Honorarios |
| P-080 | duda | Honorarios de Cosmetic Active en MMS solo hasta marzo, cuando Fátima cree que deberían llegar a diciembre. | sin responsable | III 23:43 a 24:54, 28:26 | abierto | Glos. Honorarios |
| P-081 | duda | Si las provisiones aparecen en la rentabilidad al sacar un checklist nuevo (respondido por Josep, sin verificar con datos). | sin responsable | III 1:21:46 a 1:23:38 | parcial | - |
| P-082 | duda | Por qué el campo de centro de coste de MMS no se usa ni vuelca a Oracle, y si se puede arreglar. | sin responsable | II 1:39:29 a 1:40:42; III 1:10:04 a 1:10:52; V 7:02 | abierto | Glos. Centro de coste |

### Presupuesto y forecast

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-083 | tarea | Explicar cómo se elabora el presupuesto, qué ficheros usa y en qué orden, y las pestañas de presupuesto del checklist. | Fátima Sánchez de Pazos | C sec. 1 punto 5; I 1:02:57, 1:31:33 (T8); II 1:05:53, 1:55:34, 2:00:56 (T8, T19) | cerrado en IV (28:34 a 1:02:27), con continuación en V (52:03 a 1:04:27) | Glos. Presupuesto |
| P-084 | tarea | Explicar lo que Fátima anota entre revisiones del presupuesto publicado (FT3, FT8). | Fátima Sánchez de Pazos | I 1:17:59 a 1:18:22 (T13) | abierto: no consta en IV ni V | Glos. FT3 / FT8 |
| P-085 | tarea | Subir los ficheros de presupuesto (el de la macro, los cuatro ficheros y "el otro") y la carpeta de TXT generados. | Fátima Sánchez de Pazos | I 0:20:07, 0:20:14, 1:03:13 (T7); II 1:56:10 (T7); IV 28:34 | abierto: no consta que se hayan subido | Téc. M2 |
| P-086 | tarea | Terminar de ver cómo entra el real de los meses cerrados (del checklist) y cómo se ajustan los meses abiertos. | Álvaro Montero, Fátima Sánchez de Pazos, Josep Zoppetti | III 43:35, 1:26:41; IV 36:21, 54:51, 1:11:42, 1:11:50 | parcial: V describe el proceso por fases, pero no trata los meses cerrados | Glos. Forecast; Glos. Real |
| P-087 | requisito | Estructura del presupuesto y del forecast: P&L igual que el checklist, proyectado a fin de año, con columnas FT8 (en curso), FT3 y presupuesto. | sin responsable | IV 31:29, 33:10, 35:47 | abierto | Glos. FT3 / FT8 |
| P-088 | requisito | Usar el presupuesto para proyectar a meses vista, no solo para comparar. | sin responsable | I 0:21:23 (R4) | abierto | Glos. Forecast |
| P-089 | requisito | Que la herramienta sirva para presupuestar y analizar gastos por proveedor, como el antiguo fichero de presupuesto con Sage. | sin responsable | I 0:19:42, 0:20:59 (R19) | abierto | Glos. Presupuesto |
| P-090 | tarea | Dar consejo sobre cómo integrar el presupuesto y el resto de ficheros, hoy hechos "con parches". | Docenteo (sin persona) | I 0:20:18 (T20) | abierto | - |
| P-091 | tarea | Consultar con David la regla de reparto mensual de los meses abiertos y los criterios posibles, para habilitarlos como opción. | Fátima Sánchez de Pazos (decide David Marin) | IV 58:14 a 1:02:27, 1:11:14, 1:12:19 | abierto | Glos. Forecast |
| P-092 | tarea | Preparar y enviar un Excel de ejemplo con la lógica de reparto (ejemplo de 957 y julio). | Fátima Sánchez de Pazos | IV 1:00:15, 1:00:34 | abierto | - |
| P-093 | tarea | Intentar construir la lógica de reparto con lo explicado; si no, pedir que se explique. | Álvaro Montero | IV 1:00:40 | abierto | - |
| P-094 | requisito | Draft de presupuesto y forecast con reglas configurables por partida (año anterior, porcentaje de incremento, importe manual), corregible a mano por quien lo usa. | Álvaro Montero (revisar cómo construirlo) | IV 1:01:56, 1:02:26; V 1:01:05, 1:02:19, 1:02:32 | abierto | Glos. Planning |
| P-095 | tarea | Decir qué partidas de gastos suelen aumentar (alquileres, viajes, fees). | Fátima Sánchez de Pazos | V 1:01:05, 1:02:19 | abierto | - |
| P-096 | requisito | Mensualizar los gastos generales con el IPC y los cambios de proveedor, permitiendo concentrar un gasto en un mes, con validación final de dirección. | sin responsable | V 57:19 a 58:02, 1:03:41 a 1:04:17 | abierto | - |
| P-097 | requisito | Mensualizar el revenue por cliente: repartir un importe anual sin desglose (lineal o según contrato) y llevar al mes de inicio los proyectos conocidos y el nuevo negocio. | sin responsable | V 49:17, 54:50 | abierto | Glos. Revenue |
| P-098 | tarea | Pintar el proceso de presupuesto y forecast fase a fase y validarlo. | Álvaro Montero | V 1:04:27 | abierto | Glos. Forecast |
| P-099 | duda | Si presupuesto y forecast son el mismo proceso (solo cambia de dónde llega el objetivo); no se formaliza. | sin responsable | V 53:01 a 53:36, 54:21, 55:52 | abierto | Glos. Presupuesto; Glos. Forecast |
| P-100 | duda | Cuándo se hace la fase de nuevo negocio respecto a la de gross income. | sin responsable | V 55:25 a 55:52 | abierto | Glos. Gross Income |
| P-101 | duda | Quién fija el objetivo de incremento ("global", probablemente el Grupo, o David). | sin responsable | IV 39:26, 40:01; V 52:03 a 53:36 | parcial: V dice que el presupuesto llega de fuera y el forecast puede venir de fuera o de David | Glos. Gross Income |
| P-102 | duda | Cómo se calcula cada año el porcentaje de crecimiento y si se revisa durante el año. | sin responsable | IV 40:27, 40:31 | abierto | Glos. Gross Income |
| P-103 | tarea | Tratamiento del nuevo negocio: importe y número de personas con salario base, sin dedicación por cliente, estandarizado para todas las directoras. | Álvaro Montero | V 11:57 a 15:17 | abierto | - |
| P-104 | duda | Cómo modelar los dos escenarios de cada directora: real (lo firmado) y estimado (con nuevo negocio y personas necesarias). | sin responsable | V 15:30 | abierto | Glos. Real |
| P-105 | requisito | Revenue por cliente construido desde MMS, revisado con las directoras y llevado al forecast. | sin responsable | IV 51:48, 57:33, 57:37; V 54:21 a 54:46 | abierto | Glos. Revenue; Téc. N8 |
| P-106 | requisito | Cruzar directamente la estimación de cada directora con MMS (hoy a mano, cliente a cliente, con nombres que no coinciden). | sin responsable | V 3:16, 8:51, 48:21 | abierto | Preg. 3 |
| P-107 | requisito | Guardar el importe exacto por cliente, con decimales, y ajustar el redondeo al subir. | sin responsable | IV 50:24, 50:51 | abierto | - |
| P-108 | requisito | Que los totales anuales cuadren con el revenue y se expliquen las diferencias mensuales por MMS vivo. | sin responsable | IV 54:12 a 54:51, 58:37 | abierto | Glos. Revenue |
| P-109 | duda | Por qué la línea 17 del forecast está en positivo y la 33 en negativo. | sin responsable | IV 55:01 | abierto | - |
| P-110 | duda | Unidades de las cifras del presupuesto (miles o euros). | sin responsable | IV 58:50, 59:18 | abierto | - |
| P-111 | duda | Si FT8 es acumulado. | sin responsable | I 1:09:09 a 1:10:03; IV 31:29, 35:47 | abierto (V no trata FT3 ni FT8); resuelto después: `CONTEXT.md` (confirmado el 2026-10-27 con el correo C sec. 1) define FT8 como enero a agosto reales más septiembre a diciembre proyectados | Glos. FT3 / FT8; Téc. M9 |
| P-112 | duda | Si habrá FT5 este año y si lo hubo en 2025 (no está contemplado en Planning). | sin responsable | C pend. 6; I 1:01:09, 1:02:33, 1:10:50 | abierto; `CONTEXT.md` (2026-10-27) solo recoge que algunos años hay FT5 | Glos. FT3 / FT8 |
| P-113 | duda | Fecha de entrega del FT8: 3 o 4 de septiembre (Josep) u 8 de septiembre (Fátima). | sin responsable | I 1:09:09, 1:11:38 | abierto | Glos. FT3 / FT8 |
| P-114 | duda | Si existe un plan a 2 o 3 años y si entra en el alcance (pregunta de Álvaro). | sin responsable | I 1:14:42 a 1:15:21 (R14) | abierto | - |
| P-115 | tarea | Reunión de Compensation entre Josep y Fátima, si asiste Docenteo y qué incluye Compensation. | Josep Zoppetti y Fátima Sánchez de Pazos | IV 1:12:19, 1:12:40, 1:12:43 | parcial: V 56:22 describe Compensation (salarios, bonus e indemnizaciones, subidas en abril y septiembre); no consta la reunión | Glos. Empleado |
| P-116 | tarea | Preparar cómo se presenta el revenue a las directoras, para la reunión de cierre de presupuesto. | Fátima Sánchez de Pazos | IV 1:03:32, 1:04:04 | abierto | Glos. Revenue |
| P-117 | decisión | Herramienta para las directoras (formulario o Excel): la decide David; Fátima lo verá con "Dan" (probablemente David). | David Marin | IV 1:08:02, 1:10:56, 1:11:14 | abierto | Glos. Planning; Téc. M9 |
| P-118 | requisito | Formulario por directora con los datos de MMS precargados, solo con sus clientes y rápido con muchos clientes (no uno por cliente). | Álvaro Montero (pensar la forma) | IV 49:18, 49:58, 51:16, 51:23, 1:10:51 | abierto | Glos. Planning |
| P-119 | requisito | Que las directoras puedan añadir clientes nuevos a mano y decidir quién gestiona ese formulario. | sin responsable | IV 1:10:39 | abierto | Glos. Planning |

### Rentabilidad y dedicaciones

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-120 | duda | Alcance de la fase 2: rentabilidad, informes de directoras y criterios de reparto. | sin responsable | I 0:05:11, 0:12:57 a 0:16:46 | parcial: tratada en IV (1:03:32 a 1:10:56) y V, sin cerrar | Glos. Contribución |
| P-121 | duda | Si la sección del cliente es siempre su centro de coste o su directora. | sin responsable | I 0:29:32; II 1:44:12; III 1:10:52; IV 27:03; V 7:26, 23:24, 27:58 | parcial: II y III la identifican con la directora; V muestra que un cliente puede estar en varios centros de coste y tiene una sola sección | Glos. Centro de coste |
| P-122 | tarea | Confirmar con David el criterio de reparto de clientes entre secciones (porcentual, fijo o "un fijo que pueda cambiar"). | Fátima Sánchez de Pazos y Josep Zoppetti | C sec. 1 punto 2; II 1:53:16, 1:53:24, 1:53:39 (T11, D4, D29) | abierto: V 20:53 a 21:24 muestra que hoy el reparto está como importe en los ficheros de las directoras | Glos. Centro de coste |
| P-123 | tarea | Confirmar la propuesta de reparto por porcentaje, con opción de introducir importes que se conviertan en porcentaje. | Fátima Sánchez de Pazos y Josep Zoppetti | II 1:53:55 a 1:54:29 (T12) | abierto | Glos. Centro de coste |
| P-124 | requisito | Registrar desde el principio por qué un cliente se reparte entre secciones. | sin responsable | II 1:49:25 (R30) | abierto | - |
| P-125 | requisito | Rentabilidad por directora aunque el cliente esté repartido entre secciones, sin que cada directora se asigne más de lo que le corresponde. | sin responsable | II 1:48:23, 1:48:48, 1:50:40 (R15) | abierto | Glos. Directora |
| P-126 | tarea | Hablar con Fátima sobre su correo del 21/04 y renombrar la sección de los clientes afectados por la división de un departamento. | Josep Zoppetti | II 1:47:30 a 1:48:13 (T13) | abierto: V 17:02 a 18:10 menciona una separación de clientes en MMS, sin que conste que sea el mismo cambio | - |
| P-127 | tarea | Responder a la propuesta de secciones combinadas (por ejemplo, "MP/CS"). | Josep Zoppetti | II 1:48:53 (T14) | abierto | - |
| P-128 | tarea | Mantener cada mes la pestaña de clientes: alta de clientes nuevos con empresa y sección (directora) y control de los que no tienen sección. | Josep Zoppetti | II 1:44:12 a 1:46:06 (R14, R16); III 1:11:10; V 5:37, 7:26 | abierto (recurrente) | Preg. 3; Glos. Maestro |
| P-129 | tarea | Consultar el fichero del servidor con la sección de los clientes que indicó Fátima. | Josep Zoppetti | II 1:45:44 (T6) | abierto | Glos. Maestro |
| P-130 | decisión | Maestro de clientes: partir de la pestaña de clientes del checklist, añadirle columnas (límite de crédito) y decidir si es una tabla separada que se cruza en varios sitios. | Álvaro Montero | IV 23:07, 24:30 a 27:51 | parcial: punto de partida acordado, diseño sin cerrar | Preg. 3; Glos. Maestro; Téc. M5 |
| P-131 | tarea | Decir a Josep si hace falta un maestro de clientes de Oracle con más campos y qué información nueva añadir a la pestaña. | Álvaro Montero | IV 24:59, 27:28 | abierto | Glos. Maestro |
| P-132 | tarea | Compartir la correspondencia entre los centros de coste de MMS (sección) y los de Oracle. | sin responsable | III 1:11:00, 1:11:58 a 1:12:04 | abierto | Glos. Centro de coste |
| P-133 | duda | Estructura del código de centro de coste de Oracle (letra de país, letra de ciudad y número). | sin responsable | III 1:11:43 a 1:12:45 | abierto | Glos. Centro de coste |
| P-134 | duda | Código del centro genérico del que se reparte la nómina al cierre (transcrito "SP Uno"). | sin responsable | II 1:41:00, 1:41:40 (D6) | abierto | Glos. Centro de coste |
| P-135 | tarea | Definir los porcentajes de reparto de los gastos generales por centro de coste y un aplicativo que controle esos repartos. | David Marin con Fátima Sánchez de Pazos | II 1:41:40 a 1:43:14 (T23, R13) | abierto | Glos. Centro de coste |
| P-136 | tarea | Definir cómo se reparten entre directoras los gastos que no van por centro de coste ("item"). | sin responsable | IV 1:03:32, 1:08:55 | abierto | Glos. Centro de coste |
| P-137 | requisito | Rentabilidad de cliente con margen bruto y overheads (Captio y otros por directora; globales por porcentaje de facturación); propuesta sin cerrar. | sin responsable | III 40:14, 40:56 a 41:22 | abierto | Glos. Contribución |
| P-138 | tarea | Apuntar Captio en la lista de temas, para ver de dónde salen sus asientos. | sin responsable | III 39:10 a 39:23 | abierto | - |
| P-139 | requisito | Rentabilidad mensual por cliente con honorarios y producción por separado (el presupuesto no los separa). | sin responsable | II 1:24:12 a 1:26:09 (R4) | abierto | Preg. 8; Glos. Honorarios; Glos. Producción |
| P-140 | requisito | Cruzar automáticamente contabilidad con presupuesto por cliente y mostrar las diferencias. | sin responsable | II 1:26:32 (R5) | abierto | Glos. Presupuesto |
| P-141 | duda | Regla exacta de las refacturaciones de un cliente entre sociedades en la rentabilidad, y cómo se recalcula cada año la refacturación incluida en fees. | sin responsable | III 1:09:39 a 1:10:04; V 1:01:05 | abierto | Glos. Intercompañía |
| P-142 | tarea | Mostrar en la sesión del 27/04 los ficheros de rentabilidad de directora y de presupuesto, aunque estén en construcción. | Fátima Sánchez de Pazos | III 1:04:01, 1:04:20, 1:30:54 a 1:31:13 | cerrado en IV (28:34; 1:08:55) | - |
| P-143 | duda | Si Docenteo necesita copia del fichero de rentabilidad, que se enseñó en pantalla sin acordar su envío. | sin responsable | IV 44:12, 1:08:55 | parcial: en V 1:05:03 Fátima se compromete a subir los ficheros de todas las directoras | - |
| P-144 | tarea | Preparar la revisión con las directoras de julio (o de finales de junio), con el fichero de rentabilidad mensualizado y por directora. | sin responsable | IV 44:12, 49:36, 1:07:35, 1:07:56 | abierto | Glos. Directora |
| P-145 | requisito | Resumen por directora con honorarios, gross income, personal, Contribution y su porcentaje, y por cliente la facturación de cierre de 2025 y la estimación de 2026. | sin responsable | IV 1:08:53, 1:08:55; V 2:56 a 3:16 | abierto | Glos. Contribución |
| P-146 | duda | Por qué en el resumen de la directora a veces difieren el total de honorarios y el de gross income. | sin responsable | V 3:16 | abierto | Glos. Gross Income |
| P-147 | tarea | Definir el reparto del gross income por persona según su dedicación y qué hacer con las dedicaciones que las directoras no rellenan. | sin responsable | IV 1:08:55 | abierto | Glos. Dedicación |
| P-148 | tarea | Subir a la carpeta los ficheros de todas las directoras, incluido el más ordenado y los que tienen el reparto de clientes entre equipos. | Fátima Sánchez de Pazos | V 21:10, 48:07 a 48:21, 1:05:03 | abierto | - |
| P-149 | tarea | Revisar y validar los ficheros de las directoras. | Álvaro Montero | V 1:05:43 | abierto | - |
| P-150 | tarea | Indicar qué equipos son casos particulares (personas repartidas entre subequipos, como en los equipos digitales) y cómo tratarlos. | Fátima Sánchez de Pazos | V 45:36, 46:58 a 48:07 | abierto | Glos. Equipo |
| P-151 | tarea | Crear el organigrama de quién está en cada equipo, con subcentros de coste y el porcentaje de cada persona (hoy no existe). | equipo financiero de Tinkle (sin persona) | V 21:33, 23:24, 24:26 a 24:46, 40:37, 41:11 | abierto | Glos. Equipo |
| P-152 | tarea | Diseñar la solución empezando por la matriz de dedicación y el organigrama de las directoras. | Álvaro Montero | V 41:11, 42:31, 45:11, 1:05:43 | abierto | Glos. Dedicación; Téc. M9 |
| P-153 | requisito | Matriz de clientes por personas, visual, con control para que una persona no pase del 100 % (propuesta de Docenteo). | sin responsable | V 10:59 a 11:42 | abierto | Glos. Dedicación |
| P-154 | decisión | Que cada persona sume exactamente el 100 % entre todos sus equipos, aunque dependa de centros de coste distintos. | sin responsable | V 10:46, 24:12, 26:01 a 26:54 | abierto: aceptado en la conversación, sin formalizar | Glos. Dedicación |
| P-155 | requisito | Subcentros de coste (equipos) dentro de cada centro de coste (directora), cuya suma cuadre con el centro. | sin responsable | V 23:24 a 25:49 | abierto | Glos. Centro de coste; Glos. Equipo |
| P-156 | decisión | Si el reparto se registra por cliente, por equipo o por centro de coste (Álvaro propone desde el cliente; Fátima, por equipo). | sin responsable | V 27:05 a 31:15, 41:51 a 42:27 | abierto | Glos. Dedicación |
| P-157 | duda | Dónde se registra la dedicación de una persona que trabaja para varios equipos (hoy solo en los Excel de cada directora). | sin responsable | V 34:52, 37:25 | abierto | Glos. Dedicación |
| P-158 | duda | Dónde queda registrado un acuerdo entre directoras o con dirección para repartir recursos (hoy solo como importe, sin campo de porcentaje). | sin responsable | V 34:29 a 35:48, 37:49 | abierto | Glos. Dedicación |
| P-159 | requisito | Plantilla de la directora con el coste de cada persona ya ajustado y el porcentaje en otra casilla. | sin responsable | V 31:26, 37:35 a 37:49 | abierto | Glos. Coste imputado |
| P-160 | tarea | Ver cómo obtener el porcentaje de dedicación a partir de los importes y cómo presentarlo a las directoras. | Álvaro Montero | V 43:06 | abierto | Glos. Dedicación |
| P-161 | duda | Si se analiza la rentabilidad cuando el coste de una persona va a un solo centro de coste aunque trabaje para varios (reestructuraciones). | sin responsable | V 32:37 a 33:04 | abierto | Glos. Coste imputado |
| P-162 | duda | Cómo se decide la dedicación de una persona en dos centros de coste cuando solo uno carga su coste. | sin responsable | V 32:37 a 33:03 | abierto | Glos. Dedicación |
| P-163 | duda | Cómo se mantiene el organigrama cuando cambia a mitad de año. | sin responsable | V 44:40 a 45:11 | abierto | Glos. Equipo |
| P-164 | duda | Cómo conoce la directora la dedicación de una persona en otros equipos, si no la ve. | sin responsable | V 29:22 a 30:20 | abierto | Glos. Dedicación |
| P-165 | requisito | Coste imputado: dedicación por coste de la persona, distribuido por porcentajes, para la rentabilidad por cliente. | sin responsable | V 32:14, 43:33 a 44:13 | abierto | Glos. Coste imputado |
| P-166 | requisito | Ver la rentabilidad por equipo y por cliente. | sin responsable | V 27:18 | abierto | Glos. Contribución |
| P-167 | requisito | Ver el equipo de cada directora con su coste. | sin responsable | V 21:33 a 22:38 | abierto | Glos. Equipo |
| P-168 | requisito | Asignar cada alta de empleado a un equipo de una directora. | sin responsable | V 22:56 a 23:11 | abierto | Glos. Empleado |
| P-169 | requisito | Diferenciar si un cliente de una directora está en un equipo o en varios (hoy no se sabe qué proyecto corresponde a cada equipo). | sin responsable | V 19:25, 20:20 a 20:53 | abierto | Glos. Equipo |
| P-170 | requisito | Una estructura común para los ficheros de todas las directoras a final de año. | sin responsable | V 8:51 | abierto | - |
| P-171 | tarea | Estandarizar todas las casuísticas vistas. | Álvaro Montero | V 59:58 | abierto | - |

### Agings

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-172 | tarea | Ver los agings de clientes y proveedores en una sesión. | sin responsable | II 43:51, 1:56:10 (T25) | cerrado en IV (1:09 a 24:09) | Glos. Aging |
| P-173 | requisito | Cuadrar las cuentas 4000 y 430 con los agings de proveedores y clientes. | sin responsable | C req. 5; II 43:51, 45:48 (R31) | abierto | Glos. Aging |
| P-174 | requisito | Aging mensual de clientes y proveedores en Power BI, con los tramos del Grupo y fecha de cálculo elegible (al menos dos veces al mes). | sin responsable | II 28:14, 28:40 (R17); IV 6:01, 18:30, 19:13, 19:28 | abierto | Preg. 4, 6; Glos. Tramo de aging; Téc. N10 |
| P-175 | tarea | Obtener la fecha de vencimiento de los módulos de cuentas a pagar y a cobrar y decidir cómo llega al modelo. | sin responsable | IV 4:58, 5:18, 5:46, 6:01, 6:11, 6:25 | abierto | Glos. Aging |
| P-176 | requisito | Añadir al extracto de proveedores la fecha de factura, la de vencimiento y la contable. | sin responsable | IV 1:09 | abierto | Glos. Aging |
| P-177 | requisito | Consolidado por fecha de vencimiento con filtro por sociedad. | sin responsable | IV 15:23 | abierto | Glos. Aging |
| P-178 | duda | Si el Grupo pedirá el aging de proveedores y revisar sus tramos. | sin responsable | IV 18:30 | abierto | Preg. 6 |
| P-179 | requisito | Control del riesgo de crédito en el aging de clientes: límite, saldo y alerta de riesgo excedido. | sin responsable | IV 3:30, 3:50, 21:36 a 22:42 | abierto | - |
| P-180 | decisión | Dónde viven los límites de crédito: maestro de clientes, Excel o ficha de cliente en Power BI. | sin responsable | IV 23:00 a 24:09 | abierto | Glos. Maestro |
| P-181 | duda | Quién fija y revisa los límites de crédito y con qué frecuencia cambian. | sin responsable | IV 22:43, 23:00 | abierto | - |
| P-182 | tarea | Guardar sin modificar y subir el extracto bruto de aging de clientes descargado de Oracle. | Fátima Sánchez de Pazos | IV 8:21, 13:05, 13:13 | abierto | Glos. Extracto |
| P-183 | tarea | Enviar el extracto de proveedores de Databox en Excel y en CSV. | Fátima Sánchez de Pazos | IV 16:23, 16:47 | abierto | Glos. Extracto |
| P-184 | tarea | Facilitar un aging de referencia, que Álvaro no encuentra en lo cargado. | sin responsable | II 1:56:10 (T7); III 1:31:25, 1:31:39 a 1:32:01 | parcial: en IV Fátima muestra la descarga y se compromete a subir los extractos | Preg. 4, 6 |
| P-185 | tarea | Mirar si Databox tiene también aging de clientes. | Josep Zoppetti o Fátima Sánchez de Pazos (no queda claro) | IV 10:18, 10:38, 10:40 | abierto | - |
| P-186 | tarea | Enseñar cómo se extraen los agings. | Josep Zoppetti | IV 5:18 | parcial: Fátima mostró la descarga de Oracle y de Databox (9:07, 15:58) | - |
| P-187 | duda | Si la pestaña de resumen del aging se usa o no (frase ambigua). | sin responsable | IV 14:14 | abierto | - |

### Accesos y datos sensibles

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-188 | tarea | Definir por escrito los roles y quién ve qué, con un inventario de procesos y de acceso a datos, en un correo a David. | Álvaro Montero | III 1:39:48; V 1:54, 2:36 | abierto | Téc. S4, S5, S8, N3 |
| P-189 | tarea | Contestar el correo sobre usuarios y accesos (sin urgencia). | David Marin | V 1:05:15 | abierto | Téc. S8 |
| P-190 | tarea | Convocar una reunión con David, con él presente, para decidir los accesos. | sin responsable | V 1:43 a 2:09 | abierto | Téc. S4 |
| P-191 | duda | Cuántos usuarios hay en financiero y qué acceso necesita cada uno. | sin responsable | V 0:52 a 1:43, 2:09 | abierto | Téc. S8 |
| P-192 | requisito | Que cada directora solo vea sus clientes y su equipo, y no el fichero de forecast con todos los clientes. | sin responsable | IV 44:12, 45:09; V 5:21 | abierto | Téc. S4, N3; Glos. Directora |
| P-193 | requisito | Datos de MMS: cada persona ve solo sus clientes y los ejecutivos no ven los de otros equipos; falta concretar el alcance ("le caparía ahí"). | sin responsable | III 1:37:38, 1:38:05, 1:38:18 | abierto | Téc. S4 |
| P-194 | requisito | Nóminas visibles solo para finanzas, con control por rol a nivel de fila y columna. | sin responsable | III 1:34:09 a 1:34:33, 1:36:59, 1:39:31 | abierto | Téc. S3, S4 |
| P-195 | requisito | Fichero de nóminas como entrada del presupuesto y de la rentabilidad de directora, con una estructura aún por definir. | sin responsable | III 1:33:08, 1:36:23, 1:38:58 a 1:39:31 | abierto | Téc. S3, M3 |
| P-196 | decisión | Vía para el fichero de nóminas: anonimizar, pedir permiso a David u otra. | sin responsable (Tinkle decide; Álvaro ofrece preguntar a David) | III 1:35:58, 1:38:53, 1:40:12 | abierto | Téc. S3 |
| P-197 | tarea | Hacer una copia del fichero de nóminas sin el campo de nombre. | sin responsable | III 1:35:58 a 1:36:23 | abierto | Téc. S3 |
| P-198 | tarea | Enseñar el fichero de punto de partida de nóminas, si se puede. | sin responsable | III 1:38:18 | abierto | Téc. S3 |
| P-199 | duda | Cómo tratar el nombre del tercero cuando es un empleado (cuentas 460 y liquidaciones de gastos), que Josep necesita ver. | sin responsable | II 45:59, 47:28, 1:02:45 (R19, D28) | abierto | Téc. S3 |
| P-200 | requisito | Usar nombres funcionales, sin nombres de sociedades ni terceros, en lo que pueda compartirse. | sin responsable | I 0:17:35 (R16) | abierto | - |
| P-201 | duda | Si Docenteo puede acceder al fichero del servidor con la sección de los clientes. | sin responsable | II 1:45:44 (D22) | abierto | Glos. Maestro |
| P-202 | duda | Si se puede conectar directamente a las fuentes o hay algún mecanismo de acceso (hoy dependen del Grupo hasta para sacar un informe). | sin responsable | IV 10:57, 11:09, 11:18 | abierto | Téc. D1 |

### Organización del proyecto

| Id | Tipo | Descripción | Responsable | Origen | Estado a 2026-05-07 | Relación |
|---|---|---|---|---|---|---|
| P-203 | tarea | Tratar el 22/04 los temas del correo: cuentas X, reclasificaciones de centros de coste, HAPA, amortizaciones y 480, presupuestos y ficheros del Grupo. | Fátima Sánchez de Pazos y Josep Zoppetti (explicar); Álvaro Montero (agenda) | C sec. 1 y pend. 1; I 1:30:53 a 1:32:19 (T3, T21) | cerrado en II salvo presupuestos (II 1:55:34), que se tratan en IV | - |
| P-204 | tarea | Revisar lo explicado para plantear dudas en la sesión del 22/04. | Álvaro Montero | I 1:30:44 (T2) | parcial: la sesión II se celebró; no consta la revisión | - |
| P-205 | tarea | Repasar lo visto antes de la sesión del 24/04. | Álvaro Montero | II 2:02:30 (T22) | parcial: la sesión III se celebró; no consta el repaso | - |
| P-206 | tarea | Avisar a David al terminar la sesión del 21/04 para comentarla. | Alejandro Peris | I 0:30:27, 0:30:38 (T4) | abierto: no consta | - |
| P-207 | tarea | Avisar en el grupo cada vez que se suba documentación a Teams, porque Docenteo no recibe notificaciones. | Josep Zoppetti | I 0:04:12, 0:04:18 (T6) | abierto (recurrente) | - |
| P-208 | tarea | Cerrar una tercera o cuarta reunión si queda algo pendiente tras el 22/04. | Álvaro Montero | I 1:32:19 (T19) | cerrado: sesiones III, IV y V | - |
| P-209 | tarea | Enviar la invitación de la sesión del 24/04 a los tres participantes. | Álvaro Montero | II 2:02:09, 2:02:14 (T18) | cerrado en III | - |
| P-210 | tarea | Enviar la convocatoria de la sesión del 27/04. | Álvaro Montero | III 1:40:32 | cerrado en IV | - |
| P-211 | tarea | Programar al menos otra sesión y decidir cuándo se ven cash flow, nóminas y el resto de "cositas". | sin responsable | III 1:32:34, 1:33:32 a 1:33:39 | parcial: hubo sesiones IV y V, pero cash flow y nóminas no se han tratado | - |
| P-212 | tarea | Siguiente sesión para cerrar presupuesto; Fátima avisa cuando lo tenga validado con David. | Fátima Sánchez de Pazos | IV 1:04:04, 1:05:58, 1:06:07, 1:12:43, 1:13:24 | cerrado en V (07/05) | - |
| P-213 | tarea | Crear la carpeta compartida de Docenteo con Tinkle, enviar las instrucciones y validar acceso y subida de un fichero. | Álvaro Montero (crear); Fátima Sánchez de Pazos y Josep Zoppetti (validar) | IV 1:04:34, 1:05:33, 1:05:51 | cerrado: V 2:40 dice que el acceso ya se validó | Glos. Extracto |
| P-214 | decisión | Cuál será la carpeta compartida definitiva. | sin responsable | V 2:40 | abierto | Téc. S6; Glos. Extracto |
| P-215 | tarea | Descargar los extractos y dejarlos en el sitio acordado mientras no haya integración con el origen. | equipo financiero de Tinkle (sin persona) | III 1:30 a 1:50 | abierto (recurrente) | Glos. Extracto; Téc. S6 |
| P-216 | tarea | Pensar qué ficheros de entrada necesita el proyecto y la lógica que se verá en conjunto. | Josep Zoppetti y Fátima Sánchez de Pazos | III 1:33:41 a 1:34:03 | abierto | Glos. Maestro |
| P-217 | tarea | Facilitar los TSV y Excel pendientes y los ficheros de selling. | equipo financiero de Tinkle (sin persona) | III 1:31:25 | abierto | - |
| P-218 | tarea | Enseñar a Tinkle qué ofrece la herramienta (presentación o vista) antes de comunicar nada a las directoras, en mayo. | Álvaro Montero | III 1:36:27; IV 1:08:02, 1:08:20, 1:11:13 | abierto | Glos. Planning |
| P-219 | tarea | Responder las dudas de Álvaro durante el diseño. | Josep Zoppetti y Fátima Sánchez de Pazos | V 1:06:02 | abierto | - |
| P-220 | requisito | Que la herramienta sirva para reporting, presupuestación y análisis de rentabilidad para dirección y directoras. | sin responsable | I 0:23:00 (R20) | abierto | - |
| P-221 | requisito | Flexibilidad para absorber nuevas fuentes y sociedades (sociedad nueva como HAPA o un posible cambio de ERP de Tinkle, del que no se sabe si ni cuándo). | sin responsable | I 0:12:57 a 0:16:46 (R9, T16); II 33:23, 33:32 | abierto | Téc. M8 |
| P-222 | duda | Papel exacto de David en el presupuesto y en el visto bueno del cierre. | sin responsable | III 36:42, 1:18:47 | abierto | - |
| P-223 | duda | Si "lo tendremos ya la semana que viene" (David) es una broma o una expectativa real. | sin responsable | I 0:29:37, 0:29:51 (T14) | abierto | - |
| P-224 | tarea | Hablar sobre una factura que ya no entra a final de mes (tema comercial entre Tinkle y Docenteo). | Alejandro Peris | I 0:02:24 a 0:02:37 (T15) | abierto: no consta | - |
| P-225 | duda | Qué le pasó Fátima a Josep durante la reunión ("te lo acabo de pasar"). | sin responsable | II 1:25:45 (D27) | abierto | - |
| P-226 | duda | Qué es "la respuesta de Aras" que menciona Josep y si afecta al proyecto. | sin responsable | IV 8:51, 8:54 | abierto | - |

## Contradicciones con el glosario

Términos en los que las actas contradicen o completan `../../CONTEXT.md`. No se ha modificado el glosario.

- Cuenta Magnitude y Cuenta X: el glosario ponía como ejemplo de cuenta Magnitude `X705000`; el correo dice que las cuentas de Magnitude empiezan por A (activo), P (pasivo) o R (P&L), y en II las cuentas X son cuentas analíticas de Oracle que no se reportan (C sec. 1; I 0:47:56; II 1:13:12, 1:14:20; III 45:57). Resuelto en `CONTEXT.md` (corrección del 2026-10-27 y término nuevo "Cuenta X"); Honorarios, Producción y Coste de producción ya citan sus cuentas X como tales.
- FT3 / FT8: el correo e I sitúan el FT3 en la primera semana de abril con enero a marzo reales y el FT8 en septiembre con enero a agosto reales (C sec. 1; I 1:09:09 a 1:11:38); `CONTEXT.md` lo confirma desde el 2026-10-27, con el FT5 de algunos años. Queda una discrepancia entre actas: IV dice "FT3 en marzo (empezó en febrero)" (IV 35:36).
- Presupuesto: el glosario pide evitar budget y B01, pero B01 es el nombre de la edición y de la pestaña, no un sinónimo genérico (I 0:35:54, 1:02:35); en IV se usa "budget" y "B uno" (IV 35:01, 35:09).
- P&L: el glosario pide evitar PyG; el cliente la usa como nombre de pestaña en formato Hacienda y para el PyG de HAPA (I 0:26:22).
- Real: el glosario exige periodo cerrado; en IV marzo se presentó como real antes de cerrarse (IV 36:21, 37:08), y en V "lo real" es el escenario de lo firmado frente al estimado (V 15:30). Actuals y "Estatutory data" aparecen como nombres de fichero y de etiqueta (I 0:24:12; II 7:47, 21:37).
- Checklist: el glosario lo da como "reproducido en el informe Checklist (Oracle)"; las actas lo describen como un Excel montado a mano con tablas dinámicas, con un libro separado para HAPA, que es además la base de la provisión del impuesto de sociedades (I 0:08:07; II 9:18, 36:33; III 1:18:47). Completa.
- Extracto: para el cliente son los extractos de cuentas de la gestoría de Portugal; a lo que sale de Oracle lo llama extracción o exportación (I 0:06:40, 0:29:11, 0:42:35). Difiere de la definición del glosario.
- Fichero de Grupo: el glosario pide evitar "txt", que es el término habitual del cliente. Dice "uno por sociedad y tipo" y "formato fijo": con Sage se subía un único TXT con todas las sociedades, la sociedad la marca un código dentro del fichero y Josep genera un TXT separado por punto y coma (II 27:32, 30:03, 30:40). Completa, a confirmar con los ficheros.
- Magnitude: el glosario lo presenta como sistema vigente; está previsto sustituirlo (probablemente por Tagetik) y no compara con presupuesto (C sec. 1; I 0:09:31; II 21:37, 24:52). Completa.
- MMS: el glosario dice "sistema operativo de órdenes y campañas"; las actas lo describen como aplicación a medida del IT de Havas para facturación, órdenes de compra y clientes, de la que salen los asientos de previsión y de cuentas X (II 1:56:27, 1:57:42, 2:00:50; III 9:53 a 12:57). Sigue abierta su relación con Magnitude.
- Oracle: el glosario dice "sociedades de Tinkle"; en Oracle solo están cinco sociedades, no Portugal ni HAPA, y no hay conexión directa (II 22:59, 31:33; IV 10:57).
- HAPA: el glosario pide evitar "Acento", que es como la llama el cliente, también "APA" y "H Advisor" (C sec. 1 y 3; I 0:08:07; II 10:01; IV 31:04). Desde el 2026-10-27 `CONTEXT.md` recoge su nombre en el modelo (H Advisors Asuntos Públicos España, S.L.), en Magnitude (Acento Public Affairs, S.L., ESP073) y que usa Sage; sigue sin decidirse el nombre funcional que se usará con el cliente.
- Sociedad: el glosario pide evitar "empresa", que es el nombre literal de una columna del maestro de clientes (IV 27:03).
- Centro de coste y sección: el glosario pone "sección" y "CeCo" en Avoid y deja pendiente que sean lo mismo. Josep define la sección como "el centro de coste o la directora" (II 1:44:12) y dice que los centros de coste son las propias directoras (V 23:24); pero un cliente puede repartirse entre dos a cuatro secciones (II 1:48:23) y estar en varios centros de coste con una sola sección (V 7:26, 27:58). El cliente usa "cecos" (II 2:01; V 32:37).
- Dedicación: el glosario dice que la suma de las dedicaciones de un empleado "no supera el 100 %"; en V cada persona debe sumar exactamente 100 entre sus equipos, y la dedicación puede ser a clientes, equipos o centros de coste, no solo a un cliente dentro de un equipo (V 10:46, 24:12, 26:01).
- Equipo y directora: el glosario dice que un equipo pertenece a una sola directora; V no lo contradice, pero una persona puede estar en equipos de directoras distintas y hay subequipos con personas repartidas (V 19:25, 45:36).
- Intercompañía: el glosario pide evitar "intercía", que es el nombre del campo de Oracle; el cliente usa también "intercompany", LPR e ICS, y en MMS la categoría "Servicios" (II 35:04, 1:06:22; III 1:08:59).
- Revenue: el glosario pide evitar "facturación"; el cliente habla de "facturación real" (comprometida) y de "fichero de revenue" (IV 40:57, 57:37; V 2:56).
- Honorarios: el glosario pide evitar "fees"; el cliente lo usa como sinónimo y es el nombre de un soporte de MMS (III 57:44; IV 57:30).
- Producción: en el glosario es solo ingreso; en MMS la categoría producción mezcla ingresos y costes, y existe un "coste fee" absorbido por los honorarios, distinto del coste de producción (III 32:07 a 33:46, 57:44).
- Forecast: el glosario pide evitar "previsión", que el cliente usa para los asientos de previsión del cierre (II 1:57:42; III 19:48). El glosario dice que en meses abiertos se toma MMS y la directora corrige en Planning; en IV los meses abiertos se reparten por porcentajes y son Fátima y David quienes ajustan el revenue tras reunirse con cada directora (IV 43:37, 57:37, 58:14).
- Planning: el glosario lo define como hojas de captura en Fabric; en IV la herramienta no está decidida y las directoras no ven el fichero de forecast, sino el de rentabilidad (IV 44:12, 1:11:14).
- Contribución y rentabilidad: el cliente usa "Contribution", "personal contribution" y "fichero de rentabilidad" (IV 1:08:55; V 3:16; III 41:03).
- Pendiente de facturar: el cliente dice "pendiente de emitir" (cuenta 4309) para el mismo concepto (II 1:57:42; III 1:25:09).
- Mapeo de cuentas: el glosario dice que cada cuenta origen tiene exactamente un mapeo; hoy el mapeo no tiene vigencia y se propone un histórico con fecha de vigencia (I 0:54:04; II 17:11).
- Portugal: el glosario dice que llega en un extracto contable; llega como balancete (sumas y saldos) más extractos de la gestoría, se reporta a Magnitude como una única línea y no está en MMS (I 1:19:13 a 1:25:42; IV 42:48; V 50:31).
- Términos que faltan en el glosario: Databox, Captio, Tagetik, balancete, sumas y saldos, divisa STAT, foto de MMS, soporte, coste fee, nuevo negocio, Compensation, overheads, mensualización y riesgo de crédito (actas C, I, II, III, IV y V, secciones de términos). Unidad de informe y Sage ya están en `CONTEXT.md` desde el 2026-10-27.

## Datos dudosos por confirmar con la grabación

Marcados como dudosos en las actas. No usar sin verificar.

- Cifras de la reunión I: resultado consolidado 852151 y 877 (0:57:28); ejemplo de ingresos "5", "5 900", "100000" y "117000" (0:59:59); "7080 megas" y guardados de "un par de minutos" o "1 minuto y medio" (1:30:10); 12.000 líneas de extracción (0:46:46); 32.000 filas en marzo y "más de 100000" en diciembre (1:30:35); enero 306, febrero 340 y acumulado 647 (1:03:14 a 1:06:32); "10820" en Portugal (1:26:08); "4000" y "862" en la trazabilidad (1:27:06); 11 versiones "en martes" (1:08:09); "año 2006" (1:09:09); "enero del 28" en la factura (0:02:24); "como a 2, 5 años" (1:14:42).
- Nombres y términos de la reunión I: "Avas", "Abbas", "Avast" y "habas" por Havas; "Taggetic" por Tagetik (0:09:31); "abas" probablemente HAPA (1:31:33); "Giuseppe" por Josep; "Sagit" por Sage (0:12:57); nombre nuevo de Acento ilegible (0:23:37); FT3 con "enero, febrero, marzo y abril" según la transcripción (1:11:18; manda el correo); empresa y papel de Antonio Serrano y papel de David Marin (deducido).
- Reunión II: "porte de Villaver" en el diario de HAPA (4:51, 5:59); "tecos" por cecos (2:01); centro genérico "SP Uno" (1:41:40); cuentas de estadística "6:29" (1:28:46); importes del descuadre de cuentas X 500640, 5678, 38 y 3545 (1:32:39, 1:37:00); foto de abril "esta noche 22" (1:59:50); "IGES" o "inges" (1:59:50, 2:00:15); "Jack" por Jazz (31:33); "Age Advisors Public Affairs" (10:01); "leggin" por agings (1:56:10); unas 400 líneas duplicadas (1:31:41).
- Reunión III: "MMS 360" (9:53); "Inges" y "Jobs" (9:53, 45:57); "Josevilla" (1:06:37); "Costefi" por coste fee (57:44); pestaña "Rentavi" o "rentable" (42:47, 1:13:24); "XT" de la carpeta engine (1:31:58); "meta cuatro", probablemente Meta4 (1:34:56); "a R", probablemente AR (15:08); MMS 5.966 frente a checklist 5.640 y diferencia de "38" (1:15:22 a 1:17:18); pendientes de recibir de unos 2,5 millones y 1 millón de 2025 (1:27:12 a 1:27:34); pendientes de emitir de 2025 de 186.000 EUR, 141.000 de diciembre (1:25:09 a 1:26:41); "treinta y cuantas mil" líneas (52:45); estructura del código de centro de coste (1:12:04 a 1:12:45); nombres de las cinco empresas de MMS (52:45); título interno "Requerimientos II".
- Reunión IV: "Dan", probablemente David (1:10:56); "H Advisor" y "Chadvisors" (30:41 a 31:25); "European Just", "Euro" y "Jazz" (30:18, 42:16, 21:09); "RP" por ERP (19:28); "Abbas" y "habas" por Havas (11:09, 1:04:34); "Aras" (8:51); "Matrix" (1:12:43); "BMS" por MMS (23:07); "legging", "edging" y "eging" por aging; "global", probablemente el Grupo (39:26); "Acento" en 22:20; cifra 12615 sin unidad (54:12); unidades del presupuesto (58:50).
- Reunión V: "Zero Syncom", probablemente gross income (52:03); "FIS", probablemente fees (1:01:05); "la plantilla no", sin contexto (11:42); pestaña total, del fichero de MMS o de la directora (8:10); nombres de directoras y clientes escritos de varias formas; título "VI" en la transcripción.
- Correos: nombres cortados en la captura de ESP067 (European Public Relations Services) y PTE019 (Tinkle Portugal) (C sec. 3).
