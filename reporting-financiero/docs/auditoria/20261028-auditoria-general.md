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

## 1. Resumen

1. **La herramienta está parada desde el cierre de marzo de 2026.** Los datos reales llegan hasta marzo (Oracle y Portugal) y HAPA solo tiene enero. Desde abril no se ha cargado ningún cierre: son siete cierres sin cargar (abril a octubre). Los ficheros de Grupo solo se han generado para marzo, en pruebas de julio y agosto. Lo que Tinkle ha visto en las presentaciones es, por tanto, una herramienta con datos de hace siete meses.
2. **Hay más construido de lo que Tinkle ha visto, pero nada está validado ni en uso.** Existen la comparativa del real con el presupuesto, el informe de rentabilidad por cliente y centro de coste, los agings y los TXT de Balance y Saldos 4_7. Sin embargo, se alimentan de cargas iniciales únicas o están a medias, y no se han revisado con Tinkle.
3. **Faltan piezas que Tinkle considera el valor del proyecto:** la confección del presupuesto, el reparto de gastos de personal, cinco de los siete tipos de ficheros de Grupo, los accesos por usuario y los controles de veracidad.
4. **El bloqueo principal es de definición, no técnico.** De los 226 puntos pendientes de las reuniones, 155 no tienen responsable. Las decisiones que desbloquean el presupuesto, el reparto de personal y la rentabilidad por directora están en manos de Tinkle (sobre todo de David Marin) y llevan abiertas desde mayo.
5. **Hay riesgos que el correo no menciona y que conviene resolver antes de abrir la herramienta a más gente:**
   - Ningún modelo tiene seguridad por usuario, así que los datos salariales son visibles para cualquiera con acceso a los informes.
   - Las funciones de usuario tienen un secreto en el código.
   - La entrada de ficheros depende de un OneDrive personal.
6. **Plazo:** hasta finales de enero quedan unas 13 semanas, que se quedan en unas 11 descontando Navidad. Caben tres cierres reales (octubre, noviembre y diciembre), que son la mejor ocasión para validar la herramienta en paralelo con el Excel. Para el presupuesto, el objetivo realista es el FT3 de 2027 (abril), porque según el calendario de Tinkle el presupuesto del año siguiente se prepara en septiembre (pendiente de confirmar que el de 2027 ya está hecho).

## 2. Estado real de la herramienta (medido el 27 y 28/10/2026)

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

## 3. Respuesta punto por punto al correo de Tinkle

### 3.1 Carga de información

- **Lo que dice Tinkle:** cargar en una carpeta en vez de en una pestaña es la misma tarea; no ahorra tiempo.
- **Situación:** es cierto. Todas las fuentes llegan como ficheros que alguien deposita a mano en `1. Entrada de Datos` (documento técnico, sección 3). No hay conexión con Oracle, Databox, MMS ni la gestoría de Portugal. Además, el flujo de ficheros no está definido: qué fichero, de qué sistema, en qué formato, quién lo sube y cuándo (notas de la reunión; P-016, P-214, P-215, P-216).
- **Qué falta:**
  1. Un procedimiento de carga escrito: lista cerrada de ficheros por cierre con origen, formato bruto sin retocar (P-016), carpeta definitiva (P-214) y responsable.
  2. Valorar la automatización real: exportación programada de Databox o de Oracle (P-202, depende de IT del Grupo), lectura directa de MMS, y que el modelo haga el formato que hoy se hace a mano (ordenar, separador de miles, quitar totales).
  3. Mover la carpeta de entrada del OneDrive personal de la cuenta de reporting a un sitio de equipo (S6).
- **Valoración de Docenteo:** el ahorro no estará en la carga, sino en lo que viene después: cuadres automáticos, ficheros de Grupo sin macros ni IT, comparativas y rentabilidad sin tocar el Excel. Hay que decirlo así y medirlo en un cierre real.

### 3.2 Análisis de información

- **Lo que dice Tinkle:** se han visto el balance y el P&L, pero no la comparativa con presupuestos ni la rentabilidad por cliente y centro de coste.
- **Situación:**
  - La comparativa existe en el informe Checklist (página de P&L, medidas `FCT`, `Budget Reporting Cuentas` y `DIF_ASOC01_FCT`), pero solo con el B1 y el FT3 de 2026 y el real hasta marzo.
  - El informe de Rentabilidad existe (cliente, cliente por centro de coste, rentabilidad avanzada y salarios), pero se alimenta de una carga única de dedicaciones y su contribución usa el gross income de MMS, no el real (`CONTEXT.md`, Contribución).
- **Qué falta:**
  1. Cargar los cierres de abril a septiembre y el FT8 de 2026 para enseñar la comparativa con datos actuales.
  2. Vista mensual y acumulada, comparación con la última edición publicada y selector de edición (P-003, P-004).
  3. Rentabilidad por cliente y por centro de coste con un proceso mantenido, no una carga única (ver 3.4).
  4. Desgloses y auxiliares del checklist que aún no tienen página: provisiones 4007, 4009 y 4309, gastos de las cuentas 62 y alquileres, fianzas, intercompany y el resto de la tabla del correo (P-006 a P-012).

### 3.3 Confección de presupuestos

- **Lo que dice Tinkle:** es lo que más valor aportaría y falta desarrollarlo. Exigiría tiempo suyo. Falta definir la asignación por cuentas, centros de coste, repartos de gastos comunes y porcentajes.
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

### 3.4 Gastos de personal

- **Lo que dice Tinkle:** falta definir las asignaciones presupuestarias con sus repartos entre departamentos o centros de coste, y los criterios de uso para presupuesto y rentabilidad.
- **Situación:** hoy la dedicación de cada persona no está en ningún maestro. Vive en los Excel de cada directora como importe, el organigrama por equipos no existe y el centro de coste de MMS no se usa (P-151, P-157, P-158, P-082). En la reunión V se plantearon la matriz de dedicación y los subcentros de coste, sin decisión. Está pendiente:
  - registrar el reparto por cliente, por equipo o por centro de coste (P-156);
  - que la dedicación sume exactamente el 100 % (P-154);
  - repartir los gastos generales y los que no van por centro de coste (P-135, P-136);
  - tratar el nuevo negocio (P-103).
- **Bloqueante:** el fichero de nóminas es la entrada de todo esto. Falta decidir cómo se comparte (anonimizado o con permiso de David) y quién lo ve (P-194 a P-198). Ver 3.7.

### 3.5 Reporting de Grupo

- **Lo que dice Tinkle:** no han visto la conversión a TXT para Magnitude ni la carga de presupuestos.
- **Situación:** el notebook genera Balance y Saldos 4_7, con validaciones de formato, solo para las cinco sociedades españolas y solo se ha ejecutado para marzo. Faltan:
  - Portugal (PTE019) y HAPA (ESP073), que son justo los que Tinkle sube hoy a mano (P-057);
  - los otros cinco tipos: Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow (las preguntas 1 a 15 de `PREGUNTAS_PARA_TINKLE.md` siguen sin respuesta y el cash flow no se ha explicado, P-064);
  - la salida del presupuesto en formato Magnitude (P-065).
- **Riesgos:** la sustitución anunciada de Magnitude (probablemente por Tagetik) puede cambiar el formato a mitad de proyecto (P-058). La copia a SharePoint lleva siempre todo el histórico (O7), y el pipeline que genera los ficheros no está encadenado con el de carga (O2).
- **Prueba de valor:** generar los TXT de octubre, noviembre y diciembre de las siete unidades en paralelo con el proceso actual y compararlos línea a línea con los que se suben a Magnitude.

### 3.6 Agings

- **Situación:** el informe y el modelo existen, con carga inicial hasta marzo. Falta lo pedido en la reunión IV:
  - fecha de vencimiento desde cuentas a pagar y a cobrar (P-175, P-176);
  - consolidado por vencimiento con filtro por sociedad (P-177);
  - control de riesgo de crédito con límite y alerta, y su maestro (P-179 a P-181);
  - cuadre con las cuentas 4000 y 430 (P-173).

  Además, el modelo usa un calendario fijo de 2026 a 2027 (N10), y los extractos brutos prometidos no constan como subidos (P-182, P-183).

### 3.7 Accesos y restricciones por usuario

- **Situación:** ni `Financial Model` ni `Agings` tienen roles de seguridad. Cualquiera con acceso a un informe ve todos los datos, incluidos los salarios de `Dim_RRHH` (S3, S4). La tabla `RLS` existe y se carga, pero no está enlazada a ningún modelo (N3).
- **Requisitos de las reuniones:** las directoras solo ven sus clientes y su equipo (P-192); las nóminas, solo finanzas (P-194); en MMS, cada persona ve solo lo suyo (P-193).
- **Pendientes:**
  - el correo de Docenteo a David con roles e inventario de accesos (P-188);
  - la respuesta de David (P-189);
  - una reunión con él (P-190);
  - el número de usuarios y el acceso de cada uno (P-191).
- **Valoración de Docenteo:** debe resolverse antes de dar acceso a las directoras o a cualquier persona fuera de finanzas, incluida la sesión con Josep si se usa la app con datos salariales.

### 3.8 Controles de veracidad de la información

- **Situación:** solo hay validaciones de formato en el notebook de ficheros de Grupo. No existen en la herramienta los controles que hoy hace el checklist:
  - sumas y saldos que cuadran a cero (BSS OF);
  - resultado por sociedad contra Oracle (PL OF);
  - intercompany que da cero (P-012);
  - 4000 y 430 contra agings (P-173);
  - descuadres por redondeo hacia Magnitude (P-002);
  - cuentas sin mapear en el cierre (P-050).

  Tampoco hay alertas de fallo en los pipelines. Además, los refrescos de los modelos se lanzan aunque falle la transformación (O1).
- **Qué falta:** una página de controles del cierre con semáforo por control y sociedad, y que la generación de TXT no se permita si un control falla.

## 4. Pendientes que el correo no menciona

| Tema | Riesgo | Ids |
|---|---|---|
| Secreto de Entra ID en el código de las dos funciones de usuario | Alto: cualquiera con lectura del item puede ejecutar como esa aplicación | S1, S2 |
| Carpeta de entrada en el OneDrive personal de la cuenta de reporting | Medio: si la cuenta se desactiva se rompe la ingesta | S6 |
| HAPA sin diario de movimientos, solo saldos, y solo enero cargado | Alto para trazabilidad y para su TXT | P-022 a P-027, N2 |
| Portugal: impuesto de sociedades al 21 %, detalle de asientos y facturación por cliente | Medio | P-031 a P-039 |
| Mapeos sin histórico ni fecha de vigencia; cuentas nuevas cada mes | Alto: un cambio de mapeo altera cierres ya reportados | P-050 a P-053 |
| Cuentas X: exclusiones y si el detalle por cliente llega a Magnitude | Medio | P-041 a P-049 |
| Maestro de clientes Oracle y MMS, secciones y límite de crédito | Medio: base de rentabilidad y de agings | P-128 a P-133, P-130 |
| Tablas con dos productores en modo Replace (relanzar una carga inicial pisa el histórico) | Medio | O3, N4 |
| Dataflows de maestros, presupuesto y rentabilidad fuera de cualquier pipeline | Medio | O4 |
| Capacidad nueva sin confirmar (tipo, coste y quién la administra) | Medio | N1 |
| Vista `300.vw_Reporting_Actuals` sin uso | Bajo | N9 |
| Calendario y plazos del Grupo no compartidos; plazo real de cierre sin aclarar | Medio para planificar | P-018, P-019 |

## 5. Decisiones que solo puede tomar Tinkle

Sin ellas no se puede avanzar en el presupuesto, el personal ni la rentabilidad. Conviene pedirlas por escrito, con fecha.

| Decisión | Quién | Ids |
|---|---|---|
| Modelo de atribución de gastos: cuentas, centros de coste, comunes, compartidos y porcentajes | David Marin y Fátima Sánchez de Pazos | P-135, P-136, P-091 |
| Regla de reparto mensual de los meses abiertos del presupuesto y del forecast | David Marin | P-091, P-092 |
| Registro de la dedicación: por cliente, equipo o centro de coste; organigrama con subcentros | Fátima Sánchez de Pazos, con validación de David | P-151, P-154, P-156 |
| Criterio de reparto de un cliente entre secciones | David Marin | P-122, P-123 |
| Herramienta para las directoras (formulario o Excel) y quién la gestiona | David Marin | P-117, P-119 |
| Roles y accesos por usuario; tratamiento del fichero de nóminas | David Marin | P-188 a P-196 |
| Lista de ficheros por cierre, formato y responsable de subirlos | Josep Zoppetti | P-016, P-214 a P-216 |
| Diario de HAPA y presentación de HAPA separada o agregada | Josep Zoppetti | P-022, P-026 |
| Consolidados del cierre (todas, España, España con Portugal, con o sin HAPA) | Fátima Sánchez de Pazos | P-001 |

## 6. Diagnóstico

Valoración de Docenteo, a partir de las actas, las notas internas de septiembre y la reunión de seguimiento:

1. La toma de requisitos terminó el 07/05 con el proceso explicado, pero con las decisiones de diseño abiertas y sin responsable. Después hubo presentaciones de la herramienta (las cita el correo de Tinkle), pero no consta, en lo documentado en el repositorio, ninguna sesión para cerrar esas decisiones.
2. La construcción se centró en replicar el checklist (balance, P&L y desgloses) y en una primera versión de rentabilidad y TXT. No hubo un ciclo de uso real: no se ha cargado ningún cierre desde marzo.
3. Tinkle preparó en primavera una ventana con su equipo y las directoras para adoptar la herramienta, y no se aprovechó. Esa es la causa directa de la pérdida de confianza.
4. En las presentaciones se enseñaron datos antiguos y piezas a medias, sin un caso de ahorro medible.
5. Las notas internas de septiembre ya recogen que los plazos se alargaron y que no hubo seguimiento.

## 7. Propuesta de plan hasta finales de enero

Orden pensado para recuperar la confianza primero con lo que ya existe y después construir lo que falta. Tamaño orientativo para Docenteo: S hasta una semana de una persona, M de dos a tres semanas, L cuatro o más. Está por calibrar con el equipo antes de comprometer fechas.

| Fase | Contenido | Docenteo | Necesita de Tinkle | Cuándo |
|---|---|---|---|---|
| 0. Recuperar el uso | Procedimiento de carga escrito; carga de los cierres de abril a octubre y del FT8 de 2026; página de controles del cierre; sesión con Josep para que use la herramienta con datos actuales | M | Josep: extractos de abril a octubre en bruto y dos sesiones de 2 horas | Noviembre, semanas 1 y 2 |
| 1. Reporting de Grupo | TXT de las siete unidades (añadir Portugal y HAPA) y de los cinco tipos que faltan; bloqueo si falla un control; comparación con lo subido a Magnitude en los cierres de octubre, noviembre y diciembre | L | Josep: respuestas a `PREGUNTAS_PARA_TINKLE.md`, sesión de cash flow, los TXT reales de cada cierre | Noviembre a enero, en paralelo con cada cierre |
| 2. Seguridad y accesos | Roles por usuario, salarios solo para finanzas, directoras solo con lo suyo; sacar el secreto de las funciones; carpeta de entrada de equipo | M | David: matriz de accesos; IT o administrador de Entra ID: rotar el secreto | Noviembre |
| 3. Modelo de atribución y personal | Sesión de trabajo para fijar el reparto de gastos y la dedicación; organigrama con subcentros; matriz de dedicación mantenida; rentabilidad por directora y cliente sobre ese modelo | L | David y Fátima: dos o tres sesiones; Fátima: ficheros de las directoras y organigrama | Noviembre (decisiones) y diciembre (construcción) |
| 4. Presupuesto y forecast | Draft por reglas configurables, captura por directora con sus clientes, comparativa con real, exportación a Magnitude; listo para el FT3 de 2027 | L | David: regla de reparto y objetivo; Fátima: validación con un caso real | Diciembre y enero |
| 5. Agings y riesgo de crédito | Fecha de vencimiento, consolidado, límites de crédito y cuadre con 4000 y 430; calendario no fijo | M | Fátima: extractos con vencimiento y fuente de los límites | Enero |

Para la estimación de tiempo por persona que ha pedido Tinkle hay que poner horas a cada fase en ambos lados: Docenteo y Tinkle (Josep, Fátima, David y las directoras). La columna "Necesita de Tinkle" es la base de su parte. Conviene presentarla junto con las decisiones de la sección 5, porque sin ellas las fases 3 y 4 no se pueden cumplir en plazo.

## 8. Próximos pasos inmediatos

1. Antes de la sesión con Josep:
   - pedirle los extractos de abril a octubre tal como salen del sistema;
   - cargarlos y comprobar que los controles cuadran;
   - no enseñar la app con datos salariales a nadie fuera de finanzas hasta tener la fase 2.
2. Enviar a David el correo de roles y accesos (P-188) y, en el mismo envío, la lista de decisiones de la sección 5 con una fecha propuesta para cada una.
3. Preparar la estimación por persona y fase a partir de la sección 7.
4. Confirmar con Tinkle el calendario del Grupo y las fechas de cierre de octubre, noviembre y diciembre (P-018, P-019) para planificar la validación en paralelo.
5. Volver a exportar Fabric después de cada cambio publicado y mantener este documento y el registro de pendientes al día.
