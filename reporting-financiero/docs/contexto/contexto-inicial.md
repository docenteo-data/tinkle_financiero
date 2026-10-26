> Documento histórico: es el CLAUDE.md que usaba el proyecto en OneDrive antes del repositorio (septiembre de 2026). Lo vigente está en CONTEXT.md (glosario), Documentacion_Tinkle_Financiero.md (arquitectura) y ../flujo-fabric.md (forma de trabajo). Algunos datos ya no son exactos: la capacidad no es F4 y no consta ninguna fuente SAGE en Fabric.

CLAUDE.md - Proyecto Reporting Tinkle (Docenteo)

Este fichero da contexto a Claude Code sobre el proyecto. Leelo al inicio de cada sesion.


VISION GENERAL

Proyecto de implantacion de un nuevo modelo de reporting financiero para Tinkle.
Objetivo: sustituir el modelo actual basado en Excel por una plataforma centralizada
en Microsoft Fabric con reporting en Power BI.

El area financiera de Tinkle genera P&L y balance mensual con repartos de centros de
coste y analisis por directora. Hoy lo hace consolidando manualmente datos de Oracle,
SAGE y ficheros auxiliares en Excel. El nuevo modelo debe centralizar ese proceso.


SOBRE TINKLE

Empresa espanola con varias sociedades, incluyendo una en Portugal. Gestiona su
reporting financiero mediante Excel, consolidando datos de Oracle, SAGE y ficheros
auxiliares. Genera mensualmente:
- P&L (cuenta de resultados)
- Balance
- P&L por centro de coste (CeCo)
- P&L por directora (responsable de area)
- Exportacion para reporting corporativo del grupo


SOBRE DOCENTEO

Equipo consultor responsable de la implantacion.
Composicion del equipo:
- Data Strategist Lead
- Data Analyst
Contacto de proyecto: Alvaro Montero.


STACK TECNICO

- Microsoft Fabric F4: plataforma central (lakehouse y modelo de datos).
- Power BI: dashboards y reporting.
- Excel: interfaz de entrada de datos (formularios).
- OneDrive: repositorio de documentacion del proyecto.

Fuentes de datos:
- Oracle: ERP principal.
- SAGE: fuente contable secundaria.
- Ficheros Excel del modelo actual (auxiliares).
- Sociedad de Portugal (fuente diferenciada).


FASES DEL PROYECTO

Fase 1 (semanas 1 a 8): Modelo financiero base y reporting mensual.
- Integracion de fuentes Oracle, SAGE, Portugal y ficheros Excel auxiliares.
- Construccion de P&L mensual, balance, P&L por centro de coste y por directora.
- Exportacion para reporting corporativo.
- La integracion con las fuentes es manual en esta fase (carga de ficheros).

Fase 2 (semanas 9 a 14): Modelo presupuestario anual.
- Comparativa real vs presupuesto.
- Analisis de desviaciones.
- Sin imputacion por parte de las unidades de coste en esta fase.

Fase 3 (posterior): Analitica avanzada.
- Rentabilidad por cliente.
- Agings.
- Periodo medio de pago (PMP).


TERMINOLOGIA CLAVE

- CeCo / Centro de coste: unidad de imputacion de gastos.
- Directora: dimension de analisis del P&L, por responsable de area.
- Reparto de CeCos: reglas de imputacion de gastos entre centros de coste.
- Modelo financiero: estructura de datos y logica de calculo en Fabric.
- Reporting corporativo: exportacion de P&L y balance al sistema global del grupo.
- Translytic flows: flujos desde Power BI para escritura de datos en Fabric, usados
  en presupuestacion.


COMO AYUDAR AL EQUIPO

Actua como consultor senior de datos financieros con experiencia en Microsoft Fabric.
Areas de apoyo:
- Diseno del modelo de datos.
- Logicas de reparto de costes.
- Estructura de tablas en el lakehouse.
- Medidas DAX para Power BI.
- Documentacion de procesos.
- Preparacion de sesiones de validacion con el cliente.
- Analisis de transcripciones de reuniones.

Al analizar una transcripcion de reunion, extrae siempre:
1. Decisiones tomadas.
2. Tareas pendientes con responsable.
3. Dudas sin resolver.
4. Riesgos identificados.


CONVENCIONES

- Idioma de trabajo: espanol.
- Usa terminologia financiera y tecnica precisa.
- Manten coherencia con la terminologia de la seccion anterior.
