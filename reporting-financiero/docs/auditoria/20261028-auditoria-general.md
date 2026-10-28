# Auditoría general del proyecto Reporting financiero

- Fecha: 28/10/2026.
- Alcance: estado real de la herramienta en Fabric, requerimientos y pendientes de las reuniones de abril y mayo, correo de valoración de Tinkle y reunión de seguimiento con Tinkle.
- Fuentes:
  - Registro de pendientes de las reuniones: [../reuniones/README.md](../reuniones/README.md) (ids P-nnn).
  - Auditoría técnica del workspace: sección 13 de [../contexto/Documentacion_Tinkle_Financiero.md](../contexto/Documentacion_Tinkle_Financiero.md) (ids S, O, M, D y N).
  - Definiciones exportadas de Fabric: `reporting-financiero/fabric/`.
  - Consultas de solo lectura al lakehouse y a la API de Fabric del 27 y 28/10/2026.
  - Correo de Tinkle con su valoración de las presentaciones de Docenteo.
  - Notas de Docenteo de la reunión de seguimiento con Tinkle.
- Lo medido en Fabric es un hecho a fecha de hoy. Lo que viene de las actas es testimonio verbal (ver las advertencias de cada acta). Las valoraciones de Docenteo se señalan como tales.
- Documento interno: incluye valoraciones sobre el proyecto que no deben enviarse tal cual a Tinkle.

## 1. Temas pendientes en 29 conceptos

Los 226 puntos del registro de reuniones y los riesgos de la auditoría técnica se agrupan en 29 conceptos. Cada punto del registro está en un solo concepto (columna "Pendientes"); el detalle de cada concepto sigue en las secciones 4 a 6.

### Cómo leer la tabla

- **Prioridad:** 1 es imprescindible para finales de enero; 2 puede ir después sin bloquear lo demás.
- **Estimación:** jornadas de trabajo (8 horas) de un consultor de Docenteo con experiencia en Fabric y Power BI. Es orientativa y está pendiente de calibrar con el equipo antes de comprometer fechas. El desglose por tareas está en la sección 9. Hay dos columnas:
  - **Tradicional:** el trabajo hecho a mano, sin asistentes de IA.
  - **Con IA:** la forma de trabajar del departamento (Claude Code con el repositorio, los scripts de Fabric y el vault). Cada tarea se multiplica por un factor según su tipo:
    - 0,4 en construcción técnica (DAX, Power Query M, SQL, notebooks, informes en PBIR, seguridad) y en análisis y documentación;
    - 0,8 en validación con datos y cierres reales;
    - 1 en sesiones, decisiones, formación y seguimiento con Tinkle.
  - La IA no reduce el tiempo de Tinkle ni el calendario de cierres y decisiones.
  - **Uso interno:** la estimación con IA no se presenta todavía a Tinkle.
- **Tinkle:** jornadas de cada persona de Tinkle. J es Josep Zoppetti, F Fátima Sánchez de Pazos, D David Marin, Dir cada directora e IT el administrador de Entra ID.

| Nº | Concepto | Qué falta | Prior. | Docenteo tradicional | Docenteo con IA | Tinkle | Pendientes |
|---|---|---|---|---|---|---|---|
| | **Carga y datos** | | | | | | |
| 1 | Flujo de carga de ficheros | Lista cerrada de ficheros por cierre, en bruto, con responsable y carpeta de equipo | 1 | 3 | 1,5 | J 1 | P-016, P-017, P-067 a P-069, P-213 a P-217; S6 |
| 2 | Puesta al día de los datos | Cargar los cierres de abril a octubre, el FT8 de 2026, HAPA y Portugal del periodo | 1 | 4 | 3,2 | J 2 | Estado medido (sección 3) |
| 3 | Automatización de las extracciones | Exportación programada de Databox u Oracle y lectura de MMS; depende de IT del Grupo | 2 | 5 | 2,6 | J 1 | P-013, P-202 |
| | **Cierre y checklist** | | | | | | |
| 4 | Consolidados y vistas del cierre | Tres consolidados, vista mensual y acumulada, edición de presupuesto de referencia, foto fija del cierre | 1 | 4 | 1,6 | F 1 | P-001 a P-004, P-014, P-018 a P-020 |
| 5 | Desgloses del checklist | Páginas de provisiones, personal, impuestos, periodificaciones, fianzas, gastos y alquileres | 1 | 6 | 2,4 | J 1,5 | P-006 a P-011, P-015 |
| 6 | Trazabilidad hasta el asiento | Navegar de cualquier saldo a sus movimientos | 2 | 3 | 1,2 | J 0,5 | P-005 |
| 7 | Controles de veracidad | Cuadres del cierre (sumas y saldos, resultado, intercompany, 4000 y 430 contra agings, redondeos, cuentas sin mapear) y bloqueo de los TXT si fallan | 1 | 5 | 2 | J 1 | P-012; controles de BSS OF y PL OF |
| 8 | Mapeos de cuentas | Histórico con fecha de vigencia y alta mensual de cuentas nuevas | 1 | 5 | 2 | J 1 | P-050 a P-054 |
| 9 | Cuentas X | Exclusiones y relación con el detalle por cliente en Magnitude | 2 | 3 | 1,2 | J 1, F 0,5 | P-040 a P-049 |
| 10 | HAPA | Balancete con mapeo y checklist propio, impuesto de sociedades, TXT de ESP073 y diario cuando exista | 1 | 5 | 2 | J 2 | P-021 a P-030; N2 |
| 11 | Portugal | Detalle con su plan de cuentas, impuesto de sociedades al 21 %, facturación por cliente y TXT de PTE019 | 1 | 4 | 1,6 | F 1 | P-031 a P-039 |
| | **Reporting de Grupo** | | | | | | |
| 12 | TXT de Balance y Saldos 4_7 completos | Las siete unidades, comparación con lo subido a Magnitude en tres cierres, sin copiar el histórico entero | 1 | 6 | 3,4 | J 1,5 | P-055 a P-057, P-059 a P-062; O7 |
| 13 | TXT de Ageing, Revenue, Pendiente_Facturar y Working_Capital | Definir con Tinkle y construir los cuatro ficheros | 1 | 12 | 6 | J 1,5, F 1,5 | Preguntas 1 a 12 de `PREGUNTAS_PARA_TINKLE.md` |
| 14 | TXT de CashFlow | Que Tinkle explique el proceso; construir y validar | 1 | 5 | 2,7 | J 1, F 0,5 | P-064; preguntas 13 a 15 |
| 15 | Intercompany para Magnitude (LPR) | Fichero de mayo, octubre y a veces julio | 2 | 2 | 1,2 | J 0,5 | P-063 |
| 16 | Sustitución de Magnitude | Fecha y formato nuevos (probablemente Tagetik) | 2 | sin estimar | sin estimar | sin estimar | P-058 |
| | **MMS y clientes** | | | | | | |
| 17 | MMS | Foto de cierre mensual, cuadre con el checklist, pendientes de facturar y de recibir | 1 | 5 | 2,6 | J 1, F 0,5 | P-066, P-070 a P-082 |
| 18 | Maestro de clientes | Tabla única Oracle, MMS, sección y límite de crédito; correspondencia de centros de coste | 1 | 4 | 1,6 | J 1,5 | P-128 a P-133 |
| | **Presupuesto** | | | | | | |
| 19 | Modelo de atribución de gastos | Decidir cuentas, centros de coste, gastos comunes y compartidos, porcentajes, reparto mensual y objetivo | 1 | 4 | 2,5 | F 2, D 1,5 | P-091, P-092, P-099, P-101, P-102, P-135, P-136 |
| 20 | Draft de presupuesto y forecast | Reglas configurables por partida, mensualización, meses cerrados y abiertos, nuevo negocio | 1 | 15 | 6,6 | F 3, D 1 | P-083 a P-090, P-093 a P-098, P-100, P-107 a P-114 |
| 21 | Captura por directora | Formulario o Planning con sus clientes y MMS precargado, clientes nuevos y vuelta al lakehouse | 2 | 8 | 4,1 | F 2, Dir 0,5 c/u | P-103 a P-106, P-116 a P-119; M9 |
| 22 | Presupuesto a Magnitude | Salida en el formato de carga | 1 | 3 | 1,6 | F 0,5 | P-065 |
| | **Personal y rentabilidad** | | | | | | |
| 23 | Organigrama y dedicación | Equipos y subcentros, matriz de dedicación que sume 100 %, Compensation | 1 | 6 | 2,4 | F 3, D 0,5 | P-115, P-150 a P-164, P-168 a P-171 |
| 24 | Rentabilidad | Coste imputado, rentabilidad por directora, equipo y cliente sin doble cómputo, overheads, criterio de reparto entre secciones | 1 | 8 | 3,2 | F 1,5, D 0,5 | P-120 a P-127, P-134, P-137 a P-149, P-165 a P-167 |
| | **Agings** | | | | | | |
| 25 | Agings y riesgo de crédito | Fecha de vencimiento, consolidado, límites de crédito, calendario no fijo | 1 | 7 | 3,2 | F 1,5 | P-172 a P-187; N10 |
| | **Seguridad** | | | | | | |
| 26 | Accesos por usuario y datos salariales | Roles, directoras solo con lo suyo, salarios solo para finanzas, tratamiento de nóminas | 1 | 5 | 3 | F 0,5, D 0,5 | P-188 a P-201; S3, S4, N3 |
| 27 | Seguridad técnica | Sacar el secreto de las funciones de usuario y revisar las entidades de servicio | 1 | 1,5 | 0,6 | IT 0,5 | S1, S2, S8, N5 |
| | **Plataforma y proyecto** | | | | | | |
| 28 | Orquestación y operación | Pipeline padre, condiciones de éxito, alertas, un productor por tabla, maestros orquestados, capacidad | 1 | 5 | 2,3 | ninguno | O1 a O6, O8, O9, N1, N4 |
| 29 | Gobierno y adopción | Decisiones con responsable y fecha, seguimiento semanal, sesiones con Josep, formación | 1 | 10 | 9,1 | J 2, F 2, D 1 | P-203 a P-212, P-218 a P-226 |

### Totales

| | Docenteo tradicional | Docenteo con IA | Josep | Fátima | David | Directoras | IT |
|---|---|---|---|---|---|---|---|
| Prioridad 1 | 132,5 | 67,1 | 17 | 18,5 | 5 | 0 | 0,5 |
| Prioridad 2 | 21 | 10,3 | 3 | 2,5 | 0 | 0,5 cada una | 0 |
| Total | 153,5 | 77,4 | 20 | 21 | 5 | 0,5 cada una | 0,5 |

- **Sin incluir:** el concepto 16 (sin formato nuevo no se puede estimar) y la operación recurrente de Tinkle, que es subir los ficheros de cada cierre (unas 0,5 jornadas de Josep por cierre).
- **Contingencia:** conviene sumar un 15 %. Con ella, la prioridad 1 queda en unas 152 jornadas de Docenteo de forma tradicional y en unas 77 con IA.
- **Capacidad hasta finales de enero:** quedan unas 13 semanas, unas 11 descontando Navidad, que son unas 55 jornadas por persona.
  - Tradicional: la prioridad 1 con contingencia necesita unas 2,8 personas a tiempo completo. Con 2 personas no se llega a enero salvo que el presupuesto (conceptos 20 y 21) pase a febrero.
  - Con IA: unas 1,4 personas, es decir, una persona a tiempo completo y apoyo puntual de otra. Con dos personas cabe todo, incluida la prioridad 2 (unas 1,6 personas con contingencia).
- **Lado de Tinkle:** unas 20 jornadas de Josep y 21 de Fátima en 13 semanas, es decir, algo más de 1,5 días por semana cada uno. Es el compromiso que hay que pedir de forma explícita, junto con las decisiones de David.
- **Camino crítico:** con IA ya no lo marcan las horas de Docenteo, sino la disponibilidad de Josep y Fátima, las decisiones de David (sección 6) y el calendario de los cierres de octubre, noviembre y diciembre.

## 2. Resumen de hallazgos

1. **La herramienta está parada desde el cierre de marzo de 2026.** Los datos reales llegan hasta marzo (Oracle y Portugal) y HAPA solo tiene enero. Desde abril no se ha cargado ningún cierre: son siete cierres sin cargar (abril a octubre). Los ficheros de Grupo solo se han generado para marzo, en pruebas de julio y agosto. Lo que Tinkle ha visto en las presentaciones es, por tanto, una herramienta con datos de hace siete meses.
2. **Hay más construido de lo que Tinkle ha visto, pero nada está validado ni en uso.** Existen la comparativa del real con el presupuesto, el informe de rentabilidad por cliente y centro de coste, los agings y los TXT de Balance y Saldos 4_7. Sin embargo, se alimentan de cargas iniciales únicas o están a medias, y no se han revisado con Tinkle.
3. **Faltan piezas que Tinkle considera el valor del proyecto:** la confección del presupuesto, el reparto de gastos de personal, cinco de los siete tipos de ficheros de Grupo, los accesos por usuario y los controles de veracidad.
4. **El bloqueo principal es de definición, no técnico.** De los 226 puntos del registro, 155 no tienen responsable. Las decisiones que desbloquean el presupuesto, el reparto de personal y la rentabilidad por directora están en manos de Tinkle (sobre todo de David Marin) y llevan abiertas desde mayo.
5. **Hay riesgos que el correo no menciona y que conviene resolver antes de abrir la herramienta a más gente:**
   - Ningún modelo tiene seguridad por usuario, así que los datos salariales son visibles para cualquiera con acceso a los informes.
   - Las funciones de usuario tienen un secreto en el código.
   - La entrada de ficheros depende de un OneDrive personal.
6. **Plazo:** hasta finales de enero quedan unas 11 semanas efectivas. Caben tres cierres reales (octubre, noviembre y diciembre), que son la mejor ocasión para validar la herramienta en paralelo con el Excel. Para el presupuesto, el objetivo realista es el FT3 de 2027 (abril), porque según el calendario de Tinkle el presupuesto del año siguiente se prepara en septiembre (falta confirmar que el de 2027 ya está hecho).

## 3. Estado real de la herramienta (medido el 27 y 28/10/2026)

| Elemento | Estado | Evidencia |
|---|---|---|
| Real contable de Oracle | Diciembre de 2025 a marzo de 2026 | `300.Fact_Actuals`, origen ORACLE |
| Real de Portugal | Enero a marzo de 2026 | `300.Fact_Actuals`, origen PT |
| Real de HAPA | Solo enero de 2026 (103 movimientos) | `300.Fact_Actuals`, origen HAPA |
| Agings | Última factura de clientes del 23/03/2026; 815 facturas de clientes y 708 de proveedores | `200.Aging_Clientes`, `200.Aging_Proveedores` |
| Presupuesto | B1 2026 y FT3 2026 cargados. El FT8 que hay es el de 2025; no está el FT8 de 2026 | `200.Presupuestos` |
| MMS | Periodos hasta diciembre de 2026 (incluye previsión) | `200.MMS` |
| Dedicaciones | Carga inicial única: 373 asignaciones en 12 equipos | `300.Fact_Asignacion_RRHH` |
| Ficheros de Grupo | Solo marzo de 2026, solo Balance y Saldos 4_7, solo las cinco sociedades españolas. Generados en pruebas del 20/07 al 21/08 | OneLake `Files/Exportaciones/Balance/2026.03` |
| Ejecuciones | La API no devuelve ninguna ejecución reciente de `Generar Reporting`, `Grabar salidas`, `INGESTA_Carga_Datos` ni `INGESTA_Maestros` | API de trabajos de Fabric |
| Capacidad | Ya no es la de prueba de septiembre; tipo sin confirmar | Documento técnico, sección 11.2 |
| Uso | Alguien abrió las métricas de uso de un informe entre el 26 y el 28/10 (Power BI creó sus items automáticamente) | Inventario del workspace |

Informes existentes: Checklist (Oracle), HAPA, Agings, MMS, Presupuesto y Rentabilidad, publicados en la app "Tinkle - Financiero". Hojas de Planning: Revenue FT3, Revenue FT8 y Dedicaciones, pendientes de validación según el manual funcional.

## 4. Respuesta punto por punto al correo de Tinkle

### 4.1 Carga de información (conceptos 1 a 3)

- **Lo que dice Tinkle:** cargar en una carpeta en vez de en una pestaña es la misma tarea; no ahorra tiempo.
- **Situación:** es cierto. Todas las fuentes llegan como ficheros que alguien deposita a mano en `1. Entrada de Datos` (documento técnico, sección 3). No hay conexión con Oracle, Databox, MMS ni la gestoría de Portugal. Además, el flujo de ficheros no está definido: qué fichero, de qué sistema, en qué formato, quién lo sube y cuándo (notas de la reunión; P-016, P-214, P-215, P-216).
- **Qué falta:**
  1. Un procedimiento de carga escrito: lista cerrada de ficheros por cierre con origen, formato bruto sin retocar (P-016), carpeta definitiva (P-214) y responsable.
  2. Valorar la automatización real: exportación programada de Databox o de Oracle (P-202, depende de IT del Grupo), lectura directa de MMS, y que el modelo haga el formato que hoy se hace a mano (ordenar, separador de miles, quitar totales).
  3. Mover la carpeta de entrada del OneDrive personal de la cuenta de reporting a un sitio de equipo (S6).
- **Valoración de Docenteo:** el ahorro no estará en la carga, sino en lo que viene después: cuadres automáticos, ficheros de Grupo sin macros ni IT, comparativas y rentabilidad sin tocar el Excel. Hay que decirlo así y medirlo en un cierre real.

### 4.2 Análisis de información (conceptos 4 a 9 y 24)

- **Lo que dice Tinkle:** se han visto el balance y el P&L, pero no la comparativa con presupuestos ni la rentabilidad por cliente y centro de coste.
- **Situación:**
  - La comparativa existe en el informe Checklist (página de P&L, medidas `FCT`, `Budget Reporting Cuentas` y `DIF_ASOC01_FCT`), pero solo con el B1 y el FT3 de 2026 y el real hasta marzo.
  - El informe de Rentabilidad existe (cliente, cliente por centro de coste, rentabilidad avanzada y salarios), pero se alimenta de una carga única de dedicaciones y su contribución usa el gross income de MMS, no el real (`CONTEXT.md`, Contribución).
- **Qué falta:**
  1. Cargar los cierres de abril a septiembre y el FT8 de 2026 para enseñar la comparativa con datos actuales.
  2. Vista mensual y acumulada, comparación con la última edición publicada y selector de edición (P-003, P-004).
  3. Rentabilidad por cliente y por centro de coste con un proceso mantenido, no una carga única (ver 4.4).
  4. Desgloses y auxiliares del checklist que aún no tienen página: provisiones 4007, 4009 y 4309, gastos de las cuentas 62 y alquileres, fianzas, intercompany y el resto de la tabla del correo (P-006 a P-012).

### 4.3 Confección de presupuestos (conceptos 19 a 22)

- **Lo que dice Tinkle:** es lo que más valor aportaría y falta desarrollarlo. Exigiría tiempo suyo. Falta definir la asignación por cuentas, centros de costes, repartos de gastos comunes y porcentajes.
- **Situación:** no está construido. Hay hojas de Planning para Revenue FT3 y FT8 sin validar y cuyo writeback no vuelve al lakehouse (M9). En las reuniones IV y V se explicó el proceso, pero quedó sin decidir casi todo lo que lo define:
  - la regla de reparto mensual (P-091, P-092, P-093, la decide David);
  - las reglas configurables por partida (P-094, P-095, P-096);
  - la mensualización del revenue y del nuevo negocio (P-097, P-103, P-104);
  - la herramienta para las directoras (P-117, la decide David);
  - si presupuesto y forecast son el mismo proceso (P-099);
  - el objetivo de crecimiento (P-101, P-102);
  - la salida en el formato de carga de Magnitude (P-065).
- **Qué falta:** una sesión de trabajo para fijar el modelo de atribución de cada gasto: cuenta, centro de coste, gasto común o compartido y porcentaje (notas de la reunión). Sin ese modelo no se puede construir. Después hay que construir el draft por reglas, la captura por directora y la exportación a Magnitude.
- **Calendario:** el presupuesto del año siguiente se prepara en septiembre (correo del 21/04), así que el próximo hito es el FT3 de 2027 (primera semana de abril, con enero a marzo reales). Llegar a finales de enero con el modelo de reparto decidido y un draft funcional permite usar la herramienta en ese FT3.

### 4.4 Gastos de personal (conceptos 23 y 24)

- **Lo que dice Tinkle:** falta definir las asignaciones presupuestarias con sus repartos entre departamentos o centros de coste, y los criterios de uso para presupuesto y rentabilidad.
- **Situación:** hoy la dedicación de cada persona no está en ningún maestro. Vive en los Excel de cada directora como importe, el organigrama por equipos no existe y el centro de coste de MMS no se usa (P-151, P-157, P-158, P-082). En la reunión V se plantearon la matriz de dedicación y los subcentros de coste, sin decisión. Está pendiente:
  - registrar el reparto por cliente, por equipo o por centro de coste (P-156);
  - que la dedicación sume exactamente el 100 % (P-154);
  - repartir los gastos generales y los que no van por centro de coste (P-135, P-136);
  - tratar el nuevo negocio (P-103).
- **Bloqueante:** el fichero de nóminas es la entrada de todo esto. Falta decidir cómo se comparte (anonimizado o con permiso de David) y quién lo ve (P-194 a P-198). Ver 4.7.

### 4.5 Reporting de Grupo (conceptos 10 a 16 y 22)

- **Lo que dice Tinkle:** no han visto la conversión a TXT para Magnitude ni la carga de presupuestos.
- **Situación:** el notebook genera Balance y Saldos 4_7, con validaciones de formato, solo para las cinco sociedades españolas y solo se ha ejecutado para marzo. Faltan:
  - Portugal (PTE019) y HAPA (ESP073), que son justo los que Tinkle sube hoy a mano (P-057);
  - los otros cinco tipos: Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow (las preguntas 1 a 15 de `PREGUNTAS_PARA_TINKLE.md` siguen sin respuesta y el cash flow no se ha explicado, P-064);
  - la salida del presupuesto en formato Magnitude (P-065).
- **Riesgos:** la sustitución anunciada de Magnitude (probablemente por Tagetik) puede cambiar el formato a mitad de proyecto (P-058). La copia a SharePoint lleva siempre todo el histórico (O7), y el pipeline que genera los ficheros no está encadenado con el de carga (O2).
- **Prueba de valor:** generar los TXT de octubre, noviembre y diciembre de las siete unidades en paralelo con el proceso actual y compararlos línea a línea con los que se suben a Magnitude.

### 4.6 Agings (concepto 25)

- **Situación:** el informe y el modelo existen, con carga inicial hasta marzo. Falta lo pedido en la reunión IV:
  - fecha de vencimiento desde cuentas a pagar y a cobrar (P-175, P-176);
  - consolidado por vencimiento con filtro por sociedad (P-177);
  - control de riesgo de crédito con límite y alerta, y su maestro (P-179 a P-181);
  - cuadre con las cuentas 4000 y 430 (P-173).

  Además, el modelo usa un calendario fijo de 2026 a 2027 (N10), y los extractos brutos prometidos no constan como subidos (P-182, P-183).

### 4.7 Accesos y restricciones por usuario (conceptos 26 y 27)

- **Situación:** ni `Financial Model` ni `Agings` tienen roles de seguridad. Cualquiera con acceso a un informe ve todos los datos, incluidos los salarios de `Dim_RRHH` (S3, S4). La tabla `RLS` existe y se carga, pero no está enlazada a ningún modelo (N3).
- **Requisitos de las reuniones:** las directoras solo ven sus clientes y su equipo (P-192); las nóminas, solo finanzas (P-194); en MMS, cada persona ve solo lo suyo (P-193).
- **Pendientes:**
  - el correo de Docenteo a David con roles e inventario de accesos (P-188);
  - la respuesta de David (P-189);
  - una reunión con él (P-190);
  - el número de usuarios y el acceso de cada uno (P-191).
- **Valoración de Docenteo:** debe resolverse antes de dar acceso a las directoras o a cualquier persona fuera de finanzas, incluida la sesión con Josep si se usa la app con datos salariales.

### 4.8 Controles de veracidad de la información (concepto 7)

- **Situación:** solo hay validaciones de formato en el notebook de ficheros de Grupo. No existen en la herramienta los controles que hoy hace el checklist:
  - sumas y saldos que cuadran a cero (BSS OF);
  - resultado por sociedad contra Oracle (PL OF);
  - intercompany que da cero (P-012);
  - 4000 y 430 contra agings (P-173);
  - descuadres por redondeo hacia Magnitude (P-002);
  - cuentas sin mapear en el cierre (P-050).

  Tampoco hay alertas de fallo en los pipelines. Además, los refrescos de los modelos se lanzan aunque falle la transformación (O1).
- **Qué falta:** una página de controles del cierre con semáforo por control y sociedad, y que la generación de TXT no se permita si un control falla.

## 5. Pendientes que el correo no menciona

| Tema | Riesgo | Concepto | Ids |
|---|---|---|---|
| Secreto de Entra ID en el código de las dos funciones de usuario | Alto: cualquiera con lectura del item puede ejecutar como esa aplicación | 27 | S1, S2 |
| Carpeta de entrada en el OneDrive personal de la cuenta de reporting | Medio: si la cuenta se desactiva se rompe la ingesta | 1 | S6 |
| HAPA sin diario de movimientos, solo saldos, y solo enero cargado | Alto para trazabilidad y para su TXT | 10 | P-022 a P-027, N2 |
| Portugal: impuesto de sociedades al 21 %, detalle de asientos y facturación por cliente | Medio | 11 | P-031 a P-039 |
| Mapeos sin histórico ni fecha de vigencia; cuentas nuevas cada mes | Alto: un cambio de mapeo altera cierres ya reportados | 8 | P-050 a P-053 |
| Cuentas X: exclusiones y si el detalle por cliente llega a Magnitude | Medio | 9 | P-041 a P-049 |
| Maestro de clientes Oracle y MMS, secciones y límite de crédito | Medio: base de rentabilidad y de agings | 18 | P-128 a P-133 |
| Tablas con dos productores en modo Replace (relanzar una carga inicial pisa el histórico) | Medio | 28 | O3, N4 |
| Dataflows de maestros, presupuesto y rentabilidad fuera de cualquier pipeline | Medio | 28 | O4 |
| Capacidad nueva sin confirmar (tipo, coste y quién la administra) | Medio | 28 | N1 |
| Vista `300.vw_Reporting_Actuals` sin uso | Bajo | 28 | N9 |
| Calendario y plazos del Grupo no compartidos; plazo real de cierre sin aclarar | Medio para planificar | 4 | P-018, P-019 |

## 6. Decisiones que solo puede tomar Tinkle

Sin ellas no se puede avanzar en el presupuesto, el personal ni la rentabilidad. Conviene pedirlas por escrito, con fecha.

| Decisión | Quién | Concepto | Ids |
|---|---|---|---|
| Modelo de atribución de gastos: cuentas, centros de coste, comunes, compartidos y porcentajes | David Marin y Fátima Sánchez de Pazos | 19 | P-135, P-136, P-091 |
| Regla de reparto mensual de los meses abiertos del presupuesto y del forecast | David Marin | 19 | P-091, P-092 |
| Registro de la dedicación: por cliente, equipo o centro de coste; organigrama con subcentros | Fátima Sánchez de Pazos, con validación de David | 23 | P-151, P-154, P-156 |
| Criterio de reparto de un cliente entre secciones | David Marin | 24 | P-122, P-123 |
| Herramienta para las directoras (formulario o Excel) y quién la gestiona | David Marin | 21 | P-117, P-119 |
| Roles y accesos por usuario; tratamiento del fichero de nóminas | David Marin | 26 | P-188 a P-196 |
| Lista de ficheros por cierre, formato y responsable de subirlos | Josep Zoppetti | 1 | P-016, P-214 a P-216 |
| Diario de HAPA y presentación de HAPA separada o agregada | Josep Zoppetti | 10 | P-022, P-026 |
| Consolidados del cierre (todas, España, España con Portugal, con o sin HAPA) | Fátima Sánchez de Pazos | 4 | P-001 |

## 7. Diagnóstico

Valoración de Docenteo, a partir de las actas, las notas internas de septiembre y la reunión de seguimiento:

1. La toma de requisitos terminó el 07/05 con el proceso explicado, pero con las decisiones de diseño abiertas y sin responsable. Después hubo presentaciones de la herramienta (las cita el correo de Tinkle), pero no consta, en lo documentado en el repositorio, ninguna sesión para cerrar esas decisiones.
2. La construcción se centró en replicar el checklist (balance, P&L y desgloses) y en una primera versión de rentabilidad y TXT. No hubo un ciclo de uso real: no se ha cargado ningún cierre desde marzo.
3. Tinkle preparó en primavera una ventana con su equipo y las directoras para adoptar la herramienta, y no se aprovechó. Esa es la causa directa de la pérdida de confianza.
4. En las presentaciones se enseñaron datos antiguos y piezas a medias, sin un caso de ahorro medible.
5. Las notas internas de septiembre ya recogen que los plazos se alargaron y que no hubo seguimiento.

## 8. Plan hasta finales de enero

Orden pensado para recuperar la confianza primero con lo que ya existe y después construir lo que falta. Jornadas de Docenteo por fase, sumando sus conceptos, de forma tradicional y con IA (sin contingencia).

| Fase | Conceptos | Docenteo tradicional | Docenteo con IA | Tinkle | Cuándo |
|---|---|---|---|---|---|
| 0. Recuperar el uso: flujo de carga, datos de abril a octubre, cierre y controles; sesión con Josep con datos actuales | 1, 2, 4, 5, 7 | 22 | 10,7 | J 5,5, F 1 | Noviembre, semanas 1 y 2 |
| 1. Reporting de Grupo: siete unidades, cinco tipos que faltan, mapeos, HAPA y Portugal; comparación con Magnitude en los cierres de octubre, noviembre y diciembre | 8, 10 a 15 | 39 | 18,9 | J 7,5, F 3 | Noviembre a enero, en paralelo con cada cierre |
| 2. Seguridad y operación: accesos, salarios, secreto, carpeta de equipo, orquestación y alertas | 26, 27, 28 | 11,5 | 5,9 | F 0,5, D 0,5, IT 0,5 | Noviembre |
| 3. Atribución, personal y rentabilidad: decisiones, organigrama, dedicación, maestro de clientes, MMS y rentabilidad | 17, 18, 19, 23, 24 | 27 | 12,3 | J 2,5, F 7, D 2,5 | Noviembre (decisiones) y diciembre (construcción) |
| 4. Presupuesto y forecast: draft por reglas, captura por directora, exportación a Magnitude; listo para el FT3 de 2027 | 20, 21, 22 | 26 | 12,3 | F 5,5, D 1, Dir 0,5 c/u | Diciembre y enero (de forma tradicional con 2 personas, febrero) |
| 5. Agings y riesgo de crédito | 25 | 7 | 3,2 | F 1,5 | Enero |
| Transversal: gobierno, seguimiento y formación | 29 | 10 | 9,1 | J 2, F 2, D 1 | Todo el periodo |
| Posterior: automatización, trazabilidad, cuentas X y cambio de Magnitude | 3, 6, 9, 16 | 11 | 5 | J 2,5, F 0,5 | Desde febrero |
| **Total** | | **153,5** | **77,4** | J 20, F 21, D 5, Dir 0,5 c/u, IT 0,5 | |

La columna "Tinkle" es la base de la estimación por persona que ha pedido Tinkle. Conviene presentarla junto con las decisiones de la sección 6, porque sin ellas las fases 3 y 4 no se pueden cumplir en plazo.
## 9. Estimación detallada por tareas

Jornadas de Docenteo por tarea; la suma de cada concepto es la de la sección 1. Entre paréntesis, la aportación de Tinkle.

| Nº | Concepto | Tareas (jornadas de Docenteo, estimación tradicional) | Total tradicional | Total con IA | Tinkle |
|---|---|---|---|---|---|
| 1 | Flujo de carga | Inventario y procedimiento escrito por cierre 1; ajustar los dataflows a ficheros en bruto 1,5; carpeta de equipo y cambio del shortcut 0,5 | 3 | 1,5 | J 1 (validar el procedimiento y mover la carpeta) |
| 2 | Puesta al día | Carga y revisión de los cierres de abril a octubre 2,5; FT8 de 2026 y maestros 0,5; HAPA y Portugal del periodo 1 | 4 | 3,2 | J 2 (extraer siete meses) |
| 3 | Automatización | Análisis de opciones con IT del Grupo 1; prototipo de exportación programada 3; lectura de MMS 1 | 5 | 2,6 | J 1 |
| 4 | Consolidados y vistas | Tres consolidados más HAPA opcional 1,5; vista mensual y acumulada con edición de referencia 2; foto fija del cierre 0,5 | 4 | 1,6 | F 1 (validar) |
| 5 | Desgloses | Páginas de provisiones, personal, impuestos, periodificaciones, fianzas, gastos y alquileres 5; documentar las pestañas 1 | 6 | 2,4 | J 1,5 (explicar y validar) |
| 6 | Trazabilidad | Navegación de saldo a asiento en Oracle 2; Portugal y HAPA según su detalle 1 | 3 | 1,2 | J 0,5 |
| 7 | Controles | Sumas y saldos y resultado por sociedad 1,5; intercompany y 4000 y 430 contra agings 1,5; redondeos y cuentas sin mapear 1; página de semáforo y bloqueo de TXT 1 | 5 | 2 | J 1 (validar en un cierre) |
| 8 | Mapeos | Tabla de mapeos con vigencia 2,5; recálculo y vuelta a una versión anterior 1,5; alta mensual asistida 1 | 5 | 2 | J 1 |
| 9 | Cuentas X | Exclusiones (X 999, duplicadas y estadística) 1,5; detalle por cliente frente a Magnitude 1,5 | 3 | 1,2 | J 1, F 0,5 |
| 10 | HAPA | Balancete, mapeo y checklist propio 2,5; impuesto de sociedades 0,5; TXT de ESP073 1; diario cuando exista 1 | 5 | 2 | J 2 (diario con la contabilidad de HAPA) |
| 11 | Portugal | Detalle con su plan de cuentas 1; impuesto de sociedades al 21 % 1; facturación por cliente 1; TXT de PTE019 1 | 4 | 1,6 | F 1 |
| 12 | TXT de Balance y Saldos | Sociedades desde el maestro en lugar de fijas 1; parametrizar las siete unidades 1,5; comparación con Magnitude en tres cierres 2,5; copia solo del periodo 1 | 6 | 3,4 | J 1,5 (TXT reales de cada cierre) |
| 13 | TXT de cuatro tipos | Ageing 3; Revenue 3; Pendiente_Facturar 3; Working_Capital 3 (cada uno: definición, vista, generación y validación) | 12 | 6 | J 1,5, F 1,5 (responder las preguntas y validar) |
| 14 | TXT de CashFlow | Sesión y análisis del proceso 1,5; construcción 2,5; validación 1 | 5 | 2,7 | J 1, F 0,5 |
| 15 | Intercompany LPR | Construcción y validación 2 | 2 | 1,2 | J 0,5 |
| 16 | Sustitución de Magnitude | Sin estimar hasta conocer el formato nuevo | 0 | 0 | sin estimar |
| 17 | MMS | Foto de cierre mensual 1,5; cuadre de MMS con el checklist 1,5; pendientes de facturar y de recibir 2 | 5 | 2,6 | J 1, F 0,5 |
| 18 | Maestro de clientes | Tabla única Oracle, MMS, sección y límite 2,5; control de clientes sin sección 0,5; correspondencia de centros de coste 1 | 4 | 1,6 | J 1,5 |
| 19 | Modelo de atribución | Propuesta de Docenteo 1,5; tres sesiones de trabajo 1,5; documentar las reglas 1 | 4 | 2,5 | F 2, D 1,5 |
| 20 | Draft de presupuesto y forecast | Estructura de P&L con FT8, FT3 y B01 2; motor de reglas por partida 5; mensualización de revenue y gastos 3; real de meses cerrados y ajuste de abiertos 2; nuevo negocio y escenarios 1,5; validación con un caso real 1,5 | 15 | 6,6 | F 3, D 1 |
| 21 | Captura por directora | Diseño del formulario o de Planning 2; precarga de MMS y solo sus clientes 2; clientes nuevos y vuelta al lakehouse 2,5; formación 1,5 | 8 | 4,1 | F 2, Dir 0,5 c/u |
| 22 | Presupuesto a Magnitude | Formato de carga 2; validación 1 | 3 | 1,6 | F 0,5 |
| 23 | Organigrama y dedicación | Organigrama con subcentros 2; matriz con control del 100 % 2,5; carga desde los ficheros de las directoras 1,5 | 6 | 2,4 | F 3, D 0,5 |
| 24 | Rentabilidad | Coste imputado desde la matriz 2; rentabilidad por directora, equipo y cliente sin doble cómputo 3; overheads y reparto de gastos 2; resumen por directora 1 | 8 | 3,2 | F 1,5, D 0,5 |
| 25 | Agings | Vencimiento desde cuentas a pagar y a cobrar 2; consolidado y filtro por sociedad 1; riesgo de crédito 2; calendario no fijo 1; validación 1 | 7 | 3,2 | F 1,5 |
| 26 | Accesos | Matriz de roles 1; seguridad por fila para directoras 2; seguridad por columna para salarios 1; pruebas por usuario 1 | 5 | 3 | F 0,5, D 0,5 |
| 27 | Seguridad técnica | Sacar el secreto a una conexión gestionada o Key Vault 1; revisar las entidades de servicio 0,5 | 1,5 | 0,6 | IT 0,5 (rotar el secreto) |
| 28 | Orquestación y operación | Pipeline padre y condiciones de éxito 1,5; alertas 1; un productor por tabla 1; maestros en la orquestación 1; capacidad 0,5 | 5 | 2,3 | ninguno |
| 29 | Gobierno y adopción | Seguimiento semanal (0,5 por semana durante 13 semanas) 6,5; sesiones con Josep y formación 2; mantener el registro y las decisiones 1,5 | 10 | 9,1 | J 2, F 2, D 1 |
| | **Total** | | **153,5** | **77,4** | J 20, F 21, D 5, Dir 0,5 c/u, IT 0,5 |
## 10. Próximos pasos inmediatos

1. Antes de la sesión con Josep:
   - pedirle los extractos de abril a octubre tal como salen del sistema;
   - cargarlos y comprobar que los controles cuadran;
   - no enseñar la app con datos salariales a nadie fuera de finanzas hasta tener la fase 2.
2. Enviar a David el correo de roles y accesos (P-188) y, en el mismo envío, la lista de decisiones de la sección 6 con una fecha propuesta para cada una.
3. Calibrar la estimación de la sección 1 con el equipo de Docenteo y decidir con qué equipo se trabaja (con IA, una o dos personas) antes de dar fechas a Tinkle. Mientras tanto, a Tinkle solo se le traslada su parte: la dedicación de Josep, Fátima y David y las decisiones de la sección 6.
4. Confirmar con Tinkle el calendario del Grupo y las fechas de cierre de octubre, noviembre y diciembre (P-018, P-019) para planificar la validación en paralelo.
5. Volver a exportar Fabric después de cada cambio publicado y mantener este documento y el registro de pendientes al día.
