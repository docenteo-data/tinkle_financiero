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

Los 226 puntos del registro de reuniones y los riesgos de la auditoría técnica se agrupan en 29 conceptos. Cada punto del registro está en un solo concepto (columna "Pendientes"). El análisis de cada concepto sigue en las secciones 4 a 6, y la descripción completa de cada punto, riesgo técnico y pregunta, agrupada por concepto, está en el anexo (sección 11).

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

<!-- anexo:inicio -->

## 11. Anexo. Pendientes por concepto

Todos los puntos que agrupa cada concepto de la sección 1, con su descripción. Se genera con `scripts/anexo_pendientes.py` a partir del registro de reuniones, la auditoría técnica y las preguntas de septiembre; no se edita a mano.

- Puntos del registro (P-nnn): estado a 07/05/2026, fecha de la última reunión; el origen exacto (acta y minuto) está en `docs/reuniones/README.md`.
- Riesgos técnicos (S, O, M, D, N): situación según la última verificación de la auditoría técnica.

#### Concepto 1. Flujo de carga de ficheros

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-016 | decisión | Partir del dato bruto de los extractos de Oracle y Databox, sin tocarlo a mano, y que el formato lo haga el modelo. | sin responsable | parcial: IV lo acepta como punto de partida, pendiente de confirmar en la práctica |
| P-017 | tarea | Subir a Teams el informe de asientos de marzo ("prueba marzo") en Excel y CSV, tal como sale de Databox. | Josep Zoppetti | abierto: no consta en IV ni V |
| P-067 | tarea | Subir los ficheros de MMS de marzo y del 24/04 en Excel y CSV. | Josep Zoppetti | abierto: no consta en IV ni V |
| P-068 | tarea | Terminar la exportación de MMS del 24/04, que no incluye Communications. | Josep Zoppetti | abierto |
| P-069 | tarea | Sacar el CSV de Databox para tener los dos formatos. | Josep Zoppetti | abierto |
| P-213 | tarea | Crear la carpeta compartida de Docenteo con Tinkle, enviar las instrucciones y validar acceso y subida de un fichero. | Álvaro Montero (crear); Fátima Sánchez de Pazos y Josep Zoppetti (validar) | cerrado: V 2:40 dice que el acceso ya se validó |
| P-214 | decisión | Cuál será la carpeta compartida definitiva. | sin responsable | abierto |
| P-215 | tarea | Descargar los extractos y dejarlos en el sitio acordado mientras no haya integración con el origen. | equipo financiero de Tinkle (sin persona) | abierto (recurrente) |
| P-216 | tarea | Pensar qué ficheros de entrada necesita el proyecto y la lógica que se verá en conjunto. | Josep Zoppetti y Fátima Sánchez de Pazos | abierto |
| P-217 | tarea | Facilitar los TSV y Excel pendientes y los ficheros de selling. | equipo financiero de Tinkle (sin persona) | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| S6 | Media | El shortcut de entrada apunta a un OneDrive personal (`/personal/reporting_likuit_com/`, §3). Si la cuenta se desactiva, se rompe toda la ingesta. Además, el dominio `likuit` no coincide con Tinkle. | Confirmado: Sin cambios; la URL del sitio de destino de las exportaciones tampoco está disponible. |

#### Concepto 2. Puesta al día de los datos

No agrupa puntos del registro: sale de Estado medido (sección 3).

#### Concepto 3. Automatización de las extracciones

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-013 | requisito | Reducir la carga del Excel actual (tamaño y tiempos de guardado, sobre todo en diciembre). | sin responsable | abierto |
| P-202 | duda | Si se puede conectar directamente a las fuentes o hay algún mecanismo de acceso (hoy dependen del Grupo hasta para sacar un informe). | sin responsable | abierto |

#### Concepto 4. Consolidados y vistas del cierre

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-001 | requisito | Definir los consolidados del cierre: hoy hay sin Portugal y con Portugal, el correo pide todas las sociedades, España, y España más Portugal, y David plantea añadir HAPA. | sin responsable | abierto |
| P-002 | requisito | Reportar en miles el cierre y el presupuesto, sin decimales hacia Magnitude, con opción de ver unidades y controlando los descuadres por redondeo. | sin responsable | abierto |
| P-003 | requisito | Comparar el real con el presupuesto o el forecast en vista mensual y acumulada desde el 1 de enero hasta el mes de cierre. | sin responsable | abierto |
| P-004 | requisito | Comparar siempre con el último presupuesto publicado, sin reajustarlo cada mes, y poder cambiar la edición de referencia (B01, FT3...). | sin responsable | abierto |
| P-014 | requisito | Conservar una foto de cada cierre (P&L, activo y pasivo) y decidir qué foto queda fija en el histórico. | sin responsable | abierto |
| P-018 | duda | Plazo real de cierre: Josep cierra los periodos el primer o segundo día hábil y el correo dice que se reporta el tercer día laborable. | sin responsable | abierto |
| P-019 | duda | Calendario del Grupo con las fechas de cierre y de presupuesto: existe, pero no se ha compartido. | sin responsable | abierto |
| P-020 | decisión | Posible fusión de sociedades (de cinco a dos o tres), comentada por David con Josep. | sin responsable | abierto |

#### Concepto 5. Desgloses del checklist

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-006 | requisito | Desgloses por cuenta de la tabla del correo (fondos propios, inmovilizado, provisiones, personal, impuestos, 480, bancos, gastos...), por sociedad y, en gastos, por cuenta de Oracle, cuenta española y proveedor, con el máximo detalle en los auxiliares. | sin responsable | abierto |
| P-007 | requisito | Desglose de las provisiones 4007, 4009 y 4309, que preguntan siempre los auditores. | sin responsable | abierto |
| P-008 | requisito | Informe mensual de gastos de las cuentas 62 con filtro de cuenta. | sin responsable | abierto |
| P-009 | requisito | Informe mensual del alquiler de cada oficina. | sin responsable | abierto |
| P-010 | duda | Si el control de fianzas (cuenta 26), hoy manual y fuera del sistema, entra en el alcance y si se reporta con detalle a Magnitude. | sin responsable | abierto |
| P-011 | duda | Si las cuentas 52 y 555 se reportan o solo se controlan internamente (pregunta de Docenteo). | sin responsable | abierto |
| P-015 | tarea | Anotar las pestañas de tablas dinámicas del checklist con su finalidad, con la explicación de Josep. | Álvaro Montero (anotar); Josep Zoppetti (explicar) | abierto |

#### Concepto 6. Trazabilidad hasta el asiento

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-005 | requisito | Trazabilidad: explicar cualquier saldo con sus movimientos hasta el asiento y ver movimientos en el checklist, no solo saldos. | sin responsable | abierto |

#### Concepto 7. Controles de veracidad

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-012 | requisito | Control mensual del intercompany entre sociedades de Tinkle (el total debe dar cero), aunque el Grupo solo lo pida en mayo y octubre. | sin responsable | abierto |

Además: controles de BSS OF y PL OF.

#### Concepto 8. Mapeos de cuentas

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-050 | tarea | Dar de alta y mapear cada mes las cuentas nuevas que aparecen en el cierre, sobre todo de HAPA. | Josep Zoppetti | abierto (recurrente) |
| P-051 | tarea | Diseñar el histórico de mapeos con fecha de vigencia, en una sola tabla y con posibilidad de volver a una versión anterior. | Álvaro Montero | abierto |
| P-052 | decisión | Alcance de un cambio de mapeo: los ejercicios cerrados conservan su mapeo y el cambio se aplica a todo el ejercicio en curso, incluidas las cuentas que cambian de grupo (alquileres). | sin responsable | abierto |
| P-053 | duda | Si Tinkle debe descargar y guardar el histórico de mapeos cada mes (Fátima) o la herramienta lo hace innecesario (Álvaro). | sin responsable | abierto |
| P-054 | requisito | Mantener el mapeo de varios clientes agrupados en un mismo código de reporting. | sin responsable | abierto |

#### Concepto 9. Cuentas X

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-040 | tarea | Explicar qué son las cuentas X, las cuentas de amortización y los informes de amortización. | sin responsable | cerrado en II (1:12:32 a 1:38:55; amortizaciones 38:12 a 38:54; repaso 1:55:34) |
| P-041 | duda | Cómo encajan las cuentas X de Oracle con las cuentas Magnitude (prefijos A, P y R), si `CONTEXT.md` pone X705000 como cuenta Magnitude. | sin responsable | abierto; resuelto después: `CONTEXT.md` (corrección del 2026-10-27, con el correo C sec. 1) fija que las cuentas Magnitude empiezan por A, P o R y que las X son cuentas analíticas de Oracle (término "Cuenta X") |
| P-042 | duda | Si Oracle puede tener el campo de cliente en las cuentas 600 y 700 sin X. | sin responsable | abierto |
| P-043 | decisión | Mantener las cuentas X como fuente de la rentabilidad por cliente hasta tener otra. | sin responsable | abierto |
| P-044 | duda | Si el detalle por cliente de las cuentas X está en Magnitude (Fátima) o solo el total (Josep). | sin responsable | abierto |
| P-045 | duda | Si la auditoría permite ver las cuentas X o deben seguir fuera del reporting (pregunta de Docenteo). | sin responsable | abierto |
| P-046 | requisito | Excluir de los informes las cuentas de cuadre X 999. | sin responsable | abierto |
| P-047 | requisito | Excluir de la rentabilidad las cuentas X duplicadas (subcuentas 13 y 15) y las de estadística. | sin responsable | abierto |
| P-048 | duda | Si las cuentas de estadística que Oracle genera para el Grupo afectan a los saldos. | sin responsable | abierto |
| P-049 | duda | Qué iba a contar Fátima sobre las líneas duplicadas del fichero (unas 400 que podrían ser cuatro); no se retomó. | sin responsable | abierto |

#### Concepto 10. HAPA

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-021 | tarea | Explicar el proceso de HAPA (Sage, saldos, diario). | Josep Zoppetti | cerrado en II (2:10 a 10:41) |
| P-022 | tarea | Obtener de HAPA un diario de movimientos tipo Oracle con analítica, subirlo y avisar a Docenteo cuando esté claro; sin fecha. | Josep Zoppetti | parcial: en II 4:51 ya había recibido un Excel que no le sirve; sigue pendiente |
| P-023 | duda | Formato del diario de HAPA (columnas, analítica) y si será estable una vez parametrizado. | sin responsable | abierto |
| P-024 | tarea | Posible visita a HAPA, aprovechando un viaje a Madrid, para ver qué fichero tipo Oracle pueden sacar. | Josep Zoppetti | abierto: no consta en actas posteriores |
| P-025 | decisión | Integrar HAPA igual que Portugal (sumas y saldos, mapeo y checklist propio) hasta tener el diario. | sin responsable | parcial: acuerdo de intención; Fátima lo deja pendiente del diario |
| P-026 | decisión | Presentación de HAPA: por separado (para poder compartirlo con HAPA) y agregado, como columna o pestaña, y si su checklist se unifica con el general. | sin responsable | abierto |
| P-027 | tarea | Provisión del impuesto de sociedades de HAPA: hablar "con ellos" (por contexto, la contabilidad de HAPA) entre asiento con reversión o ajuste manual. | Josep Zoppetti | abierto |
| P-028 | duda | Si HAPA seguirá con Sage o cuál será su solución futura. | sin responsable | abierto |
| P-029 | duda | Nombre registrado actual de HAPA y su relación con "Acento", "APA", "Acento Public Affairs, S.L." (ESP073) y "H Advisor". | sin responsable | abierto; resuelto después: `CONTEXT.md` (medido el 2026-10-27) la registra como H Advisors Asuntos Públicos España, S.L. en el modelo y Acento Public Affairs, S.L. (ESP073) en Magnitude, con Sage |
| P-030 | requisito | Pestaña propia de HAPA (probablemente la "H Advisor" de la transcripción) en el presupuesto. | sin responsable | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| N2 | Alta | `Carga_New_HAPA_asientos` no es cargable, así que `100.New_HAPA` no se actualiza (§5.2, §5.5). `TRANS_Silver` y `TRANS_Gold` siguen procesando HAPA con datos antiguos, lo que puede dejar desactualizado el informe `HAPA`. | Contradicho: `Carga_New_HAPA_asientos` sí tiene destino en la definición: escribe en `100.New_HAPA` (consulta `Carga_HAPA_asientos_DataDestination`). La tabla tiene datos (103 filas el 2026-10-26). Falta comprobar en el historial que la carga se ejecuta. |

#### Concepto 11. Portugal

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-031 | requisito | Calcular la previsión del impuesto de sociedades de Portugal al 21 % (cuentas P44200 y R69500). | sin responsable | abierto |
| P-032 | requisito | Detalle de los asientos de Portugal con su plan de cuentas original. | sin responsable | abierto |
| P-033 | tarea | Valorar si el extracto de contas de Portugal que Josep dice haber subido sirve como detalle de movimientos. | Docenteo (sin persona) | abierto |
| P-034 | duda | Qué "otros ficheros separados" alimentan la pestaña de Portugal, además del balancete y Actuals Portugal. | sin responsable | abierto |
| P-035 | duda | Cuál de los extractos PTG de la gestoría, uno de ellos por centros de coste, es el que se usa (Josep lo consulta con Fátima). | sin responsable | abierto |
| P-036 | tarea | Localizar y compartir el Excel con el detalle de Portugal por empresa y mes. | Fátima Sánchez de Pazos | abierto |
| P-037 | requisito | Desglosar Portugal dentro del modelo, aunque a Magnitude vaya como una línea única, y definir qué datos hacen falta. | sin responsable | abierto |
| P-038 | requisito | Entrada manual de la facturación de Portugal por cliente y mes (Portugal no está en MMS), actualizada con contabilidad. | Fátima Sánchez de Pazos (actualiza) | abierto |
| P-039 | duda | Integración futura de Portugal con sus propios sistemas en lugar del balancete, o si seguirá reportándose aparte. | sin responsable | abierto |

#### Concepto 12. TXT de Balance y Saldos 4_7 completos

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-055 | requisito | Generar los TXT de Grupo desde la información propia, sin depender de la herramienta de Oracle ni de IT del Grupo. | sin responsable | abierto |
| P-056 | duda | Qué información de los TXT no está en el checklist ("no toda", según Josep). | sin responsable | abierto |
| P-057 | duda | Qué herramienta de Oracle genera los TXT, qué depende de IT y si el Grupo permitirá generarlos fuera de ella. | sin responsable | parcial: II 22:59, 25:12 aclara que el Grupo sube los de Oracle y Tinkle los de Portugal y HAPA |
| P-059 | tarea | Ver los ficheros que da el Grupo para subir a Magnitude; se vieron sin detalle y queda por decidir si hace falta otra sesión. | sin responsable | parcial |
| P-060 | tarea | Enseñar el sistema de reporting web (Magnitude) al equipo. | Josep Zoppetti | cerrado en II (20:20, 20:37) |
| P-061 | duda | Qué es el paquete o categoría R de Magnitude (C es consolidado). | sin responsable | abierto |
| P-062 | duda | Qué contiene la carpeta "engine" de Magnitude ("XT que se generan", probablemente los TXT de Grupo). | sin responsable | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| O7 | Media | Los TXT se generan con timestamp y nunca se borran; la copia a SharePoint es recursiva sobre `*.txt` (§7, §8.2). Cada ejecución vuelve a copiar todo el histórico y la carpeta crece sin límite. | Abierto desde la auditoría de septiembre |

#### Concepto 13. TXT de Ageing, Revenue, Pendiente_Facturar y Working_Capital

**Preguntas pendientes**

| Nº | Pregunta pendiente para Tinkle |
|---|---|
| 1 | El fichero de marzo compartido, ¿es exactamente lo que se genera cada mes para el reporting de Grupo, o tiene alguna diferencia (formato, filtros) respecto al proceso real? |
| 2 | Por varias menciones en las reuniones y en el nombre de la carpeta compartida, se ha asumido que el destino final de estos ficheros es el sistema "Magnitude". ¿Es correcto, o el destino es otro / ha cambiado? |
| 3 | Cuando se prepara hoy a mano el fichero, el cliente aparece con un código corto (ej. `IKEA`, `01500400`, `AMAZO594`). ¿De dónde sale ese código exactamente? ¿Existe un listado o fichero en algún sitio que relacione cada cliente con su código? (Afecta a Ageing, Revenue y Pendiente_Facturar). |
| 4 | Los tramos de antigüedad ya están calculados en días (0-30, 31-60, 61-90, 91-120, 121-180, más de 1 año). En el fichero final aparecen como códigos `GR0, GR1, GR2, GR3, GR4, GR5, GR8C, GR9C` y `GRICFLAG`. ¿Qué tramo corresponde a cada código? |
| 5 | `GRICFLAG` no parece ser un tramo de días, sino algo aparte. ¿Es el marcador de operaciones intercompany (con otras empresas del grupo Havas)? |
| 6 | El fichero de marzo compartido solo tenía clientes. ¿Ageing de Grupo también necesita un bloque de proveedores, o es solo de clientes? |
| 7 | La tabla de ingresos identificada como fuente está vacía en el sistema. ¿Se puede relanzar su proceso de carga para que vuelva a tener datos? |
| 8 | ¿El importe que va al fichero es el ingreso total del cliente (honorarios + producción juntos), o solo una de las dos partidas? |
| 9 | Se ha intentado reproducir el cálculo de varias formas con los datos de MMS (por fecha de factura en blanco, desagregando también por estado de pedido) y en ningún caso salen números parecidos a los del fichero de ejemplo. ¿Se puede mostrar, con el fichero de marzo delante, cómo se calcula exactamente el importe pendiente de facturar de un cliente concreto (por ejemplo Repsol)? |
| 10 | En MMS hay varios estados de pedido (`P`, `C`, `I`, `FP`, `E`, entre otros). ¿Cuáles de esos estados cuentan como "pendiente de facturar"? |
| 11 | No se ha encontrado ningún dato en el sistema que explique este fichero. ¿Working_Capital sale de algún cálculo, o son líneas que se introducen a mano directamente en Magnitude? |
| 12 | Si sale de un cálculo, ¿de qué información parte (aging, tesorería, algo del balance)? |

#### Concepto 14. TXT de CashFlow

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-064 | tarea | Explicar el proceso de cash flow (macros y exportación de Oracle), que entra en el alcance. | Josep Zoppetti, con Fátima Sánchez de Pazos | abierto: no consta en IV ni V |

**Preguntas pendientes**

| Nº | Pregunta pendiente para Tinkle |
|---|---|
| 13 | El fichero se llama internamente "HMES - Asientos con contrapartida fija" y mezcla cuentas de banco, proveedores, clientes, intercompany, nóminas, gastos financieros e impuestos, no es solo la cuenta 572. ¿Qué informe o consulta concreta de Oracle genera exactamente este listado, y con qué criterio selecciona esas líneas? |
| 14 | ¿La fecha de inicio del informe es siempre el 1 de enero del ejercicio (acumulado desde principio de año hasta el cierre), o depende de otra cosa? |
| 15 | Al principio de cada línea del fichero aparece un código de compañía (ej. `53`). ¿Qué código interno es ese? |

#### Concepto 15. Intercompany para Magnitude (LPR)

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-063 | requisito | Informe intercompany (LPR) de mayo, octubre y a veces julio: qué datos y formato pide Magnitude; hoy se hace a mano. | sin responsable | abierto |

#### Concepto 16. Sustitución de Magnitude

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-058 | duda | Sustitución de Magnitude (probablemente por Tagetik): cuándo y si cambian el formato o la subida de los TXT. | sin responsable | abierto |

#### Concepto 17. MMS

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-066 | tarea | Tratar el fichero de MMS en una sesión. | sin responsable | cerrado en III (9:53 a 1:29:15) |
| P-070 | duda | Si MMS es un sistema aparte o un módulo de Magnitude, y qué relación tienen. | sin responsable | parcial: III lo describe como aplicación a medida del IT de Havas; la relación con Magnitude no se trata |
| P-071 | duda | Fecha y frecuencia de la foto de MMS: una madrugada del cierre, programada por Tinkle; falta confirmar si la fecha es fija. | sin responsable | abierto |
| P-072 | duda | Cómo comparar la foto de MMS con el cierre real cuando MMS cambia después. | sin responsable | abierto |
| P-073 | duda | Descuadre de enero a marzo entre el fichero de MMS y el checklist, y en qué consiste la "diferencia identificada" de 38. | sin responsable | abierto |
| P-074 | requisito | Foto de MMS cercana al cierre para comparar con el presupuesto y decidir provisiones. | sin responsable | abierto |
| P-075 | requisito | Vincular MMS con contabilidad por número de factura y por código de cliente (propuesto, no validado). | sin responsable | abierto |
| P-076 | requisito | Seguimiento de pendientes de facturar a clientes por año y mes, y de pendientes de recibir de proveedores con su antigüedad. | sin responsable | abierto |
| P-077 | tarea | Aclarar con facturación los pendientes de facturar de 2024 y 2025 (seguimiento habitual, no compromiso de la reunión). | sin responsable | abierto |
| P-078 | decisión | Filtro de fechas de la carga de MMS: incluir 2024 y 2025, porque siguen entrando facturas de esos años (2023 está a cero). | sin responsable | parcial: respondido en la reunión, sin decisión formal |
| P-079 | duda | Si los honorarios futuros desde contrato firmado valen para un cliente aún no dado de alta. | sin responsable | parcial: confirmado para contrato firmado, sin respuesta expresa para clientes nuevos |
| P-080 | duda | Honorarios de Cosmetic Active en MMS solo hasta marzo, cuando Fátima cree que deberían llegar a diciembre. | sin responsable | abierto |
| P-081 | duda | Si las provisiones aparecen en la rentabilidad al sacar un checklist nuevo (respondido por Josep, sin verificar con datos). | sin responsable | parcial |
| P-082 | duda | Por qué el campo de centro de coste de MMS no se usa ni vuelca a Oracle, y si se puede arreglar. | sin responsable | abierto |

#### Concepto 18. Maestro de clientes

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-128 | tarea | Mantener cada mes la pestaña de clientes: alta de clientes nuevos con empresa y sección (directora) y control de los que no tienen sección. | Josep Zoppetti | abierto (recurrente) |
| P-129 | tarea | Consultar el fichero del servidor con la sección de los clientes que indicó Fátima. | Josep Zoppetti | abierto |
| P-130 | decisión | Maestro de clientes: partir de la pestaña de clientes del checklist, añadirle columnas (límite de crédito) y decidir si es una tabla separada que se cruza en varios sitios. | Álvaro Montero | parcial: punto de partida acordado, diseño sin cerrar |
| P-131 | tarea | Decir a Josep si hace falta un maestro de clientes de Oracle con más campos y qué información nueva añadir a la pestaña. | Álvaro Montero | abierto |
| P-132 | tarea | Compartir la correspondencia entre los centros de coste de MMS (sección) y los de Oracle. | sin responsable | abierto |
| P-133 | duda | Estructura del código de centro de coste de Oracle (letra de país, letra de ciudad y número). | sin responsable | abierto |

#### Concepto 19. Modelo de atribución de gastos

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-091 | tarea | Consultar con David la regla de reparto mensual de los meses abiertos y los criterios posibles, para habilitarlos como opción. | Fátima Sánchez de Pazos (decide David Marin) | abierto |
| P-092 | tarea | Preparar y enviar un Excel de ejemplo con la lógica de reparto (ejemplo de 957 y julio). | Fátima Sánchez de Pazos | abierto |
| P-099 | duda | Si presupuesto y forecast son el mismo proceso (solo cambia de dónde llega el objetivo); no se formaliza. | sin responsable | abierto |
| P-101 | duda | Quién fija el objetivo de incremento ("global", probablemente el Grupo, o David). | sin responsable | parcial: V dice que el presupuesto llega de fuera y el forecast puede venir de fuera o de David |
| P-102 | duda | Cómo se calcula cada año el porcentaje de crecimiento y si se revisa durante el año. | sin responsable | abierto |
| P-135 | tarea | Definir los porcentajes de reparto de los gastos generales por centro de coste y un aplicativo que controle esos repartos. | David Marin con Fátima Sánchez de Pazos | abierto |
| P-136 | tarea | Definir cómo se reparten entre directoras los gastos que no van por centro de coste ("item"). | sin responsable | abierto |

#### Concepto 20. Draft de presupuesto y forecast

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-083 | tarea | Explicar cómo se elabora el presupuesto, qué ficheros usa y en qué orden, y las pestañas de presupuesto del checklist. | Fátima Sánchez de Pazos | cerrado en IV (28:34 a 1:02:27), con continuación en V (52:03 a 1:04:27) |
| P-084 | tarea | Explicar lo que Fátima anota entre revisiones del presupuesto publicado (FT3, FT8). | Fátima Sánchez de Pazos | abierto: no consta en IV ni V |
| P-085 | tarea | Subir los ficheros de presupuesto (el de la macro, los cuatro ficheros y "el otro") y la carpeta de TXT generados. | Fátima Sánchez de Pazos | abierto: no consta que se hayan subido |
| P-086 | tarea | Terminar de ver cómo entra el real de los meses cerrados (del checklist) y cómo se ajustan los meses abiertos. | Álvaro Montero, Fátima Sánchez de Pazos, Josep Zoppetti | parcial: V describe el proceso por fases, pero no trata los meses cerrados |
| P-087 | requisito | Estructura del presupuesto y del forecast: P&L igual que el checklist, proyectado a fin de año, con columnas FT8 (en curso), FT3 y presupuesto. | sin responsable | abierto |
| P-088 | requisito | Usar el presupuesto para proyectar a meses vista, no solo para comparar. | sin responsable | abierto |
| P-089 | requisito | Que la herramienta sirva para presupuestar y analizar gastos por proveedor, como el antiguo fichero de presupuesto con Sage. | sin responsable | abierto |
| P-090 | tarea | Dar consejo sobre cómo integrar el presupuesto y el resto de ficheros, hoy hechos "con parches". | Docenteo (sin persona) | abierto |
| P-093 | tarea | Intentar construir la lógica de reparto con lo explicado; si no, pedir que se explique. | Álvaro Montero | abierto |
| P-094 | requisito | Draft de presupuesto y forecast con reglas configurables por partida (año anterior, porcentaje de incremento, importe manual), corregible a mano por quien lo usa. | Álvaro Montero (revisar cómo construirlo) | abierto |
| P-095 | tarea | Decir qué partidas de gastos suelen aumentar (alquileres, viajes, fees). | Fátima Sánchez de Pazos | abierto |
| P-096 | requisito | Mensualizar los gastos generales con el IPC y los cambios de proveedor, permitiendo concentrar un gasto en un mes, con validación final de dirección. | sin responsable | abierto |
| P-097 | requisito | Mensualizar el revenue por cliente: repartir un importe anual sin desglose (lineal o según contrato) y llevar al mes de inicio los proyectos conocidos y el nuevo negocio. | sin responsable | abierto |
| P-098 | tarea | Pintar el proceso de presupuesto y forecast fase a fase y validarlo. | Álvaro Montero | abierto |
| P-100 | duda | Cuándo se hace la fase de nuevo negocio respecto a la de gross income. | sin responsable | abierto |
| P-107 | requisito | Guardar el importe exacto por cliente, con decimales, y ajustar el redondeo al subir. | sin responsable | abierto |
| P-108 | requisito | Que los totales anuales cuadren con el revenue y se expliquen las diferencias mensuales por MMS vivo. | sin responsable | abierto |
| P-109 | duda | Por qué la línea 17 del forecast está en positivo y la 33 en negativo. | sin responsable | abierto |
| P-110 | duda | Unidades de las cifras del presupuesto (miles o euros). | sin responsable | abierto |
| P-111 | duda | Si FT8 es acumulado. | sin responsable | abierto (V no trata FT3 ni FT8); resuelto después: `CONTEXT.md` (confirmado el 2026-10-27 con el correo C sec. 1) define FT8 como enero a agosto reales más septiembre a diciembre proyectados |
| P-112 | duda | Si habrá FT5 este año y si lo hubo en 2025 (no está contemplado en Planning). | sin responsable | abierto; `CONTEXT.md` (2026-10-27) solo recoge que algunos años hay FT5 |
| P-113 | duda | Fecha de entrega del FT8: 3 o 4 de septiembre (Josep) u 8 de septiembre (Fátima). | sin responsable | abierto |
| P-114 | duda | Si existe un plan a 2 o 3 años y si entra en el alcance (pregunta de Álvaro). | sin responsable | abierto |

#### Concepto 21. Captura por directora

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-103 | tarea | Tratamiento del nuevo negocio: importe y número de personas con salario base, sin dedicación por cliente, estandarizado para todas las directoras. | Álvaro Montero | abierto |
| P-104 | duda | Cómo modelar los dos escenarios de cada directora: real (lo firmado) y estimado (con nuevo negocio y personas necesarias). | sin responsable | abierto |
| P-105 | requisito | Revenue por cliente construido desde MMS, revisado con las directoras y llevado al forecast. | sin responsable | abierto |
| P-106 | requisito | Cruzar directamente la estimación de cada directora con MMS (hoy a mano, cliente a cliente, con nombres que no coinciden). | sin responsable | abierto |
| P-116 | tarea | Preparar cómo se presenta el revenue a las directoras, para la reunión de cierre de presupuesto. | Fátima Sánchez de Pazos | abierto |
| P-117 | decisión | Herramienta para las directoras (formulario o Excel): la decide David; Fátima lo verá con "Dan" (probablemente David). | David Marin | abierto |
| P-118 | requisito | Formulario por directora con los datos de MMS precargados, solo con sus clientes y rápido con muchos clientes (no uno por cliente). | Álvaro Montero (pensar la forma) | abierto |
| P-119 | requisito | Que las directoras puedan añadir clientes nuevos a mano y decidir quién gestiona ese formulario. | sin responsable | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| M9 | Media | Planning no devuelve datos al lakehouse (§10): los forecasts FT3/FT8 quedan en `CPM` y no se pueden usar en los informes. `Dedicaciones` no tiene writeback, por lo que lo introducido se pierde fuera de Planning. | Confirmado: Nada lee de `CPM`. |

#### Concepto 22. Presupuesto a Magnitude

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-065 | requisito | Salida del presupuesto en el formato de carga de Magnitude (hoy la genera una macro del fichero de presupuesto). | sin responsable | abierto |

#### Concepto 23. Organigrama y dedicación

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-115 | tarea | Reunión de Compensation entre Josep y Fátima, si asiste Docenteo y qué incluye Compensation. | Josep Zoppetti y Fátima Sánchez de Pazos | parcial: V 56:22 describe Compensation (salarios, bonus e indemnizaciones, subidas en abril y septiembre); no consta la reunión |
| P-150 | tarea | Indicar qué equipos son casos particulares (personas repartidas entre subequipos, como en los equipos digitales) y cómo tratarlos. | Fátima Sánchez de Pazos | abierto |
| P-151 | tarea | Crear el organigrama de quién está en cada equipo, con subcentros de coste y el porcentaje de cada persona (hoy no existe). | equipo financiero de Tinkle (sin persona) | abierto |
| P-152 | tarea | Diseñar la solución empezando por la matriz de dedicación y el organigrama de las directoras. | Álvaro Montero | abierto |
| P-153 | requisito | Matriz de clientes por personas, visual, con control para que una persona no pase del 100 % (propuesta de Docenteo). | sin responsable | abierto |
| P-154 | decisión | Que cada persona sume exactamente el 100 % entre todos sus equipos, aunque dependa de centros de coste distintos. | sin responsable | abierto: aceptado en la conversación, sin formalizar |
| P-155 | requisito | Subcentros de coste (equipos) dentro de cada centro de coste (directora), cuya suma cuadre con el centro. | sin responsable | abierto |
| P-156 | decisión | Si el reparto se registra por cliente, por equipo o por centro de coste (Álvaro propone desde el cliente; Fátima, por equipo). | sin responsable | abierto |
| P-157 | duda | Dónde se registra la dedicación de una persona que trabaja para varios equipos (hoy solo en los Excel de cada directora). | sin responsable | abierto |
| P-158 | duda | Dónde queda registrado un acuerdo entre directoras o con dirección para repartir recursos (hoy solo como importe, sin campo de porcentaje). | sin responsable | abierto |
| P-159 | requisito | Plantilla de la directora con el coste de cada persona ya ajustado y el porcentaje en otra casilla. | sin responsable | abierto |
| P-160 | tarea | Ver cómo obtener el porcentaje de dedicación a partir de los importes y cómo presentarlo a las directoras. | Álvaro Montero | abierto |
| P-161 | duda | Si se analiza la rentabilidad cuando el coste de una persona va a un solo centro de coste aunque trabaje para varios (reestructuraciones). | sin responsable | abierto |
| P-162 | duda | Cómo se decide la dedicación de una persona en dos centros de coste cuando solo uno carga su coste. | sin responsable | abierto |
| P-163 | duda | Cómo se mantiene el organigrama cuando cambia a mitad de año. | sin responsable | abierto |
| P-164 | duda | Cómo conoce la directora la dedicación de una persona en otros equipos, si no la ve. | sin responsable | abierto |
| P-168 | requisito | Asignar cada alta de empleado a un equipo de una directora. | sin responsable | abierto |
| P-169 | requisito | Diferenciar si un cliente de una directora está en un equipo o en varios (hoy no se sabe qué proyecto corresponde a cada equipo). | sin responsable | abierto |
| P-170 | requisito | Una estructura común para los ficheros de todas las directoras a final de año. | sin responsable | abierto |
| P-171 | tarea | Estandarizar todas las casuísticas vistas. | Álvaro Montero | abierto |

#### Concepto 24. Rentabilidad

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-120 | duda | Alcance de la fase 2: rentabilidad, informes de directoras y criterios de reparto. | sin responsable | parcial: tratada en IV (1:03:32 a 1:10:56) y V, sin cerrar |
| P-121 | duda | Si la sección del cliente es siempre su centro de coste o su directora. | sin responsable | parcial: II y III la identifican con la directora; V muestra que un cliente puede estar en varios centros de coste y tiene una sola sección |
| P-122 | tarea | Confirmar con David el criterio de reparto de clientes entre secciones (porcentual, fijo o "un fijo que pueda cambiar"). | Fátima Sánchez de Pazos y Josep Zoppetti | abierto: V 20:53 a 21:24 muestra que hoy el reparto está como importe en los ficheros de las directoras |
| P-123 | tarea | Confirmar la propuesta de reparto por porcentaje, con opción de introducir importes que se conviertan en porcentaje. | Fátima Sánchez de Pazos y Josep Zoppetti | abierto |
| P-124 | requisito | Registrar desde el principio por qué un cliente se reparte entre secciones. | sin responsable | abierto |
| P-125 | requisito | Rentabilidad por directora aunque el cliente esté repartido entre secciones, sin que cada directora se asigne más de lo que le corresponde. | sin responsable | abierto |
| P-126 | tarea | Hablar con Fátima sobre su correo del 21/04 y renombrar la sección de los clientes afectados por la división de un departamento. | Josep Zoppetti | abierto: V 17:02 a 18:10 menciona una separación de clientes en MMS, sin que conste que sea el mismo cambio |
| P-127 | tarea | Responder a la propuesta de secciones combinadas (por ejemplo, "MP/CS"). | Josep Zoppetti | abierto |
| P-134 | duda | Código del centro genérico del que se reparte la nómina al cierre (transcrito "SP Uno"). | sin responsable | abierto |
| P-137 | requisito | Rentabilidad de cliente con margen bruto y overheads (Captio y otros por directora; globales por porcentaje de facturación); propuesta sin cerrar. | sin responsable | abierto |
| P-138 | tarea | Apuntar Captio en la lista de temas, para ver de dónde salen sus asientos. | sin responsable | abierto |
| P-139 | requisito | Rentabilidad mensual por cliente con honorarios y producción por separado (el presupuesto no los separa). | sin responsable | abierto |
| P-140 | requisito | Cruzar automáticamente contabilidad con presupuesto por cliente y mostrar las diferencias. | sin responsable | abierto |
| P-141 | duda | Regla exacta de las refacturaciones de un cliente entre sociedades en la rentabilidad, y cómo se recalcula cada año la refacturación incluida en fees. | sin responsable | abierto |
| P-142 | tarea | Mostrar en la sesión del 27/04 los ficheros de rentabilidad de directora y de presupuesto, aunque estén en construcción. | Fátima Sánchez de Pazos | cerrado en IV (28:34; 1:08:55) |
| P-143 | duda | Si Docenteo necesita copia del fichero de rentabilidad, que se enseñó en pantalla sin acordar su envío. | sin responsable | parcial: en V 1:05:03 Fátima se compromete a subir los ficheros de todas las directoras |
| P-144 | tarea | Preparar la revisión con las directoras de julio (o de finales de junio), con el fichero de rentabilidad mensualizado y por directora. | sin responsable | abierto |
| P-145 | requisito | Resumen por directora con honorarios, gross income, personal, Contribution y su porcentaje, y por cliente la facturación de cierre de 2025 y la estimación de 2026. | sin responsable | abierto |
| P-146 | duda | Por qué en el resumen de la directora a veces difieren el total de honorarios y el de gross income. | sin responsable | abierto |
| P-147 | tarea | Definir el reparto del gross income por persona según su dedicación y qué hacer con las dedicaciones que las directoras no rellenan. | sin responsable | abierto |
| P-148 | tarea | Subir a la carpeta los ficheros de todas las directoras, incluido el más ordenado y los que tienen el reparto de clientes entre equipos. | Fátima Sánchez de Pazos | abierto |
| P-149 | tarea | Revisar y validar los ficheros de las directoras. | Álvaro Montero | abierto |
| P-165 | requisito | Coste imputado: dedicación por coste de la persona, distribuido por porcentajes, para la rentabilidad por cliente. | sin responsable | abierto |
| P-166 | requisito | Ver la rentabilidad por equipo y por cliente. | sin responsable | abierto |
| P-167 | requisito | Ver el equipo de cada directora con su coste. | sin responsable | abierto |

#### Concepto 25. Agings y riesgo de crédito

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-172 | tarea | Ver los agings de clientes y proveedores en una sesión. | sin responsable | cerrado en IV (1:09 a 24:09) |
| P-173 | requisito | Cuadrar las cuentas 4000 y 430 con los agings de proveedores y clientes. | sin responsable | abierto |
| P-174 | requisito | Aging mensual de clientes y proveedores en Power BI, con los tramos del Grupo y fecha de cálculo elegible (al menos dos veces al mes). | sin responsable | abierto |
| P-175 | tarea | Obtener la fecha de vencimiento de los módulos de cuentas a pagar y a cobrar y decidir cómo llega al modelo. | sin responsable | abierto |
| P-176 | requisito | Añadir al extracto de proveedores la fecha de factura, la de vencimiento y la contable. | sin responsable | abierto |
| P-177 | requisito | Consolidado por fecha de vencimiento con filtro por sociedad. | sin responsable | abierto |
| P-178 | duda | Si el Grupo pedirá el aging de proveedores y revisar sus tramos. | sin responsable | abierto |
| P-179 | requisito | Control del riesgo de crédito en el aging de clientes: límite, saldo y alerta de riesgo excedido. | sin responsable | abierto |
| P-180 | decisión | Dónde viven los límites de crédito: maestro de clientes, Excel o ficha de cliente en Power BI. | sin responsable | abierto |
| P-181 | duda | Quién fija y revisa los límites de crédito y con qué frecuencia cambian. | sin responsable | abierto |
| P-182 | tarea | Guardar sin modificar y subir el extracto bruto de aging de clientes descargado de Oracle. | Fátima Sánchez de Pazos | abierto |
| P-183 | tarea | Enviar el extracto de proveedores de Databox en Excel y en CSV. | Fátima Sánchez de Pazos | abierto |
| P-184 | tarea | Facilitar un aging de referencia, que Álvaro no encuentra en lo cargado. | sin responsable | parcial: en IV Fátima muestra la descarga y se compromete a subir los extractos |
| P-185 | tarea | Mirar si Databox tiene también aging de clientes. | Josep Zoppetti o Fátima Sánchez de Pazos (no queda claro) | abierto |
| P-186 | tarea | Enseñar cómo se extraen los agings. | Josep Zoppetti | parcial: Fátima mostró la descarga de Oracle y de Databox (9:07, 15:58) |
| P-187 | duda | Si la pestaña de resumen del aging se usa o no (frase ambigua). | sin responsable | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| N10 | Media | Las tablas snapshot del modelo `Agings` usan un calendario fijo del 2026-01-01 al 2027-12-31. A partir de 2028 el informe no tendrá fechas de corte. | Abierto desde la auditoría de septiembre |

#### Concepto 26. Accesos por usuario y datos salariales

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-188 | tarea | Definir por escrito los roles y quién ve qué, con un inventario de procesos y de acceso a datos, en un correo a David. | Álvaro Montero | abierto |
| P-189 | tarea | Contestar el correo sobre usuarios y accesos (sin urgencia). | David Marin | abierto |
| P-190 | tarea | Convocar una reunión con David, con él presente, para decidir los accesos. | sin responsable | abierto |
| P-191 | duda | Cuántos usuarios hay en financiero y qué acceso necesita cada uno. | sin responsable | abierto |
| P-192 | requisito | Que cada directora solo vea sus clientes y su equipo, y no el fichero de forecast con todos los clientes. | sin responsable | abierto |
| P-193 | requisito | Datos de MMS: cada persona ve solo sus clientes y los ejecutivos no ven los de otros equipos; falta concretar el alcance ("le caparía ahí"). | sin responsable | abierto |
| P-194 | requisito | Nóminas visibles solo para finanzas, con control por rol a nivel de fila y columna. | sin responsable | abierto |
| P-195 | requisito | Fichero de nóminas como entrada del presupuesto y de la rentabilidad de directora, con una estructura aún por definir. | sin responsable | abierto |
| P-196 | decisión | Vía para el fichero de nóminas: anonimizar, pedir permiso a David u otra. | sin responsable (Tinkle decide; Álvaro ofrece preguntar a David) | abierto |
| P-197 | tarea | Hacer una copia del fichero de nóminas sin el campo de nombre. | sin responsable | abierto |
| P-198 | tarea | Enseñar el fichero de punto de partida de nóminas, si se puede. | sin responsable | abierto |
| P-199 | duda | Cómo tratar el nombre del tercero cuando es un empleado (cuentas 460 y liquidaciones de gastos), que Josep necesita ver. | sin responsable | abierto |
| P-200 | requisito | Usar nombres funcionales, sin nombres de sociedades ni terceros, en lo que pueda compartirse. | sin responsable | abierto |
| P-201 | duda | Si Docenteo puede acceder al fichero del servidor con la sección de los clientes. | sin responsable | abierto |

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| S3 | Alta | `Dim_RRHH` contiene salarios y costes por empleado (§2.3) y se carga en `Financial Model`, que alimenta varios informes y la app. El documento no indica ninguna restricción (RLS, OLS, permisos). | Confirmado: Ni `Financial Model` ni `Agings` tienen roles RLS u OLS. Los datos salariales de `Dim_RRHH` son visibles para cualquiera con acceso a los informes de `Financial Model`. |
| S4 | Alta | La tabla `RLS` (esquema `100`) no figura entre las tablas de `Financial Model` (§6.1) ni se mencionan roles. Todo indica que la seguridad por centro de coste no se aplica en los informes. | Confirmado: Ni `Financial Model` ni `Agings` tienen roles RLS u OLS. Los datos salariales de `Dim_RRHH` son visibles para cualquiera con acceso a los informes de `Financial Model`. |
| N3 | Alta | `Seguridad_CDC` no tiene destino activo: `100.RLS` no se actualiza y los cambios de usuarios o CDC no llegan a la tabla. | Contradicho: La consulta `RLS` de `Seguridad_CDC` sí tiene destino: escribe en `100.RLS` (consulta `RLS_DataDestination`). La tabla tiene datos (13 filas el 2026-10-26). Sigue sin enlazarse a ningún modelo, así que S3 y S4 se mantienen. |

#### Concepto 27. Seguridad técnica

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| S1 | Alta | `CLIENT_SECRET` en texto plano en `function_app.py` de las dos UDF (§9.4), marcado como "pendiente de decisión". | Confirmado: Secreto incrustado; las UDF no usan Key Vault ni conexión gestionada (§9.2). |
| S2 | Alta | Endpoints públicos de las UDF sin parámetros ni control adicional (§9.3): cualquiera con permiso de invocación puede lanzar los pipelines repetidamente. | Parcial: Endpoints públicos confirmados; permiso exacto de invocación no disponible. |
| S8 | Baja | No se documentan roles del workspace, propietarios de items, audiencias reales de la app ni integración con git. | Resuelto en parte: Roles documentados en §11.1. Git y deployment pipelines no verificables. |
| N5 | Media | Dos entidades de servicio con rol Member y ningún grupo de Entra ID (§11.1). Si el secreto de S1 pertenece a una de ellas, quien lo lea puede modificar cualquier item del workspace. | Abierto desde la auditoría de septiembre |

#### Concepto 28. Orquestación y operación

**Riesgos técnicos**

| Id | Prioridad | Problema | Situación |
|---|---|---|---|
| O1 | Alta | En `Generar Reporting` los refrescos de modelos dependen de la condición `Completed` (§8.1, pasos 6 y 7): se refrescan aunque `TRANS_Gold` falle, publicando datos incompletos o inconsistentes. | Abierto desde la auditoría de septiembre |
| O2 | Alta | No hay dependencia entre `Generar Reporting` y `Grabar salidas` (§8.2). Las UDF solo comprueban el HTTP 202 (§9.1), es decir, que el job se ha encolado, no que haya terminado. Se puede generar el TXT antes de que termine la actualización. | Abierto desde la auditoría de septiembre |
| O3 | Alta | Doble productor de `Oracle_historico`, `Aging_Clientes` y `Aging_Proveedores` (§5.4). El documento no indica el modo de escritura (reemplazar o anexar) de ningún dataflow. Relanzar un `INICIAL_*` o `TRANS_Silver` en modo reemplazo puede borrar el histórico. | Confirmado: Todo es Replace y hay cuatro tablas con dos productores (§5.5). |
| O4 | Media | `INGESTA_Maestros`, `Seguridad_CDC`, `INICIAL_Carga_budget_fct`, `INICIAL_Carga_Revenues` e `INICIAL_Carga_Rentabilidades` no están en ningún pipeline. No se sabe cómo ni cuándo se actualizan maestros, presupuesto, RRHH y dedicaciones. | Confirmado: No se han encontrado programaciones para los dataflows fuera de pipelines. |
| O5 | Media | `Grabar salidas` lee las vistas vía SQL endpoint (§7) sin refrescar antes los metadatos del endpoint, a diferencia de `Generar Reporting`. | Abierto desde la auditoría de septiembre |
| O6 | Media | Timeout de 12 min y sin reintentos en la carga (§8.1); sin reintentos en ninguna actividad. | Corregido: El timeout de las actividades de los pipelines es de 12 h, no de 12 min. Ninguna tiene reintentos. |
| O8 | Media | El documento dice que no hay programación en la definición (§8.1, §8.2), pero las programaciones de Fabric se guardan fuera de la definición. | Pendiente: Programaciones, historial y medidas de Planning no se han revisado. |
| O9 | Baja | Nombres de actividades por defecto (`RefreshSqlEndpoint1_copy1`, `Semantic model refresh1_copy1`, `Notebook1`). | Abierto desde la auditoría de septiembre |
| N1 | Alta | El workspace está en una capacidad de prueba (`FTL64`, creada el 2026-08-17 según su nombre, §11.2). Al caducar, pipelines, dataflows, modelos e informes dejan de funcionar. | Cambiado: El workspace ya no está en la capacidad de prueba (§11.2); falta confirmar el tipo de la nueva. |
| N4 | Media | Cuatro tablas con dos productores en Replace (`Oracle_historico`, `Aging_Clientes`, `Aging_Proveedores`, `Dim_CDC`). | Corregido: En `INICIAL_Carga_Rentabilidades` la consulta `Dim_CDC` no tiene destino: solo lee `300.Dim_CDC`. El único productor de `Dim_CDC` es `INGESTA_Maestros`. Las tablas con dos productores son tres: `Oracle_historico`, `Aging_Clientes` y `Aging_Proveedores`. |

#### Concepto 29. Gobierno y adopción

**Puntos del registro**

| Id | Tipo | Descripción | Responsable | Estado |
|---|---|---|---|---|
| P-203 | tarea | Tratar el 22/04 los temas del correo: cuentas X, reclasificaciones de centros de coste, HAPA, amortizaciones y 480, presupuestos y ficheros del Grupo. | Fátima Sánchez de Pazos y Josep Zoppetti (explicar); Álvaro Montero (agenda) | cerrado en II salvo presupuestos (II 1:55:34), que se tratan en IV |
| P-204 | tarea | Revisar lo explicado para plantear dudas en la sesión del 22/04. | Álvaro Montero | parcial: la sesión II se celebró; no consta la revisión |
| P-205 | tarea | Repasar lo visto antes de la sesión del 24/04. | Álvaro Montero | parcial: la sesión III se celebró; no consta el repaso |
| P-206 | tarea | Avisar a David al terminar la sesión del 21/04 para comentarla. | Alejandro Peris | abierto: no consta |
| P-207 | tarea | Avisar en el grupo cada vez que se suba documentación a Teams, porque Docenteo no recibe notificaciones. | Josep Zoppetti | abierto (recurrente) |
| P-208 | tarea | Cerrar una tercera o cuarta reunión si queda algo pendiente tras el 22/04. | Álvaro Montero | cerrado: sesiones III, IV y V |
| P-209 | tarea | Enviar la invitación de la sesión del 24/04 a los tres participantes. | Álvaro Montero | cerrado en III |
| P-210 | tarea | Enviar la convocatoria de la sesión del 27/04. | Álvaro Montero | cerrado en IV |
| P-211 | tarea | Programar al menos otra sesión y decidir cuándo se ven cash flow, nóminas y el resto de "cositas". | sin responsable | parcial: hubo sesiones IV y V, pero cash flow y nóminas no se han tratado |
| P-212 | tarea | Siguiente sesión para cerrar presupuesto; Fátima avisa cuando lo tenga validado con David. | Fátima Sánchez de Pazos | cerrado en V (07/05) |
| P-218 | tarea | Enseñar a Tinkle qué ofrece la herramienta (presentación o vista) antes de comunicar nada a las directoras, en mayo. | Álvaro Montero | abierto |
| P-219 | tarea | Responder las dudas de Álvaro durante el diseño. | Josep Zoppetti y Fátima Sánchez de Pazos | abierto |
| P-220 | requisito | Que la herramienta sirva para reporting, presupuestación y análisis de rentabilidad para dirección y directoras. | sin responsable | abierto |
| P-221 | requisito | Flexibilidad para absorber nuevas fuentes y sociedades (sociedad nueva como HAPA o un posible cambio de ERP de Tinkle, del que no se sabe si ni cuándo). | sin responsable | abierto |
| P-222 | duda | Papel exacto de David en el presupuesto y en el visto bueno del cierre. | sin responsable | abierto |
| P-223 | duda | Si "lo tendremos ya la semana que viene" (David) es una broma o una expectativa real. | sin responsable | abierto |
| P-224 | tarea | Hablar sobre una factura que ya no entra a final de mes (tema comercial entre Tinkle y Docenteo). | Alejandro Peris | abierto: no consta |
| P-225 | duda | Qué le pasó Fátima a Josep durante la reunión ("te lo acabo de pasar"). | sin responsable | abierto |
| P-226 | duda | Qué es "la respuesta de Aras" que menciona Josep y si afecta al proyecto. | sin responsable | abierto |

<!-- anexo:fin -->
