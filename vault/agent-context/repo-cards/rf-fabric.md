---
type: repo-card
load_tier: 1
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
tags: [rf-fabric, repo-card]
---

# rf-fabric - Repo Card

> Resumen tier 1, de unas 900 palabras como máximo. Cargar primero para cualquier tarea que toque el workspace de Fabric de Tinkle.

- **Qué es**: la carpeta fabric/ de reporting-financiero es la copia en texto, exportada por API, del workspace de Microsoft Fabric "Tinkle - Financiero". La rama main refleja lo publicado en Fabric; el trabajo se hace en la rama reporting-financiero. No hay código de aplicación: son definiciones de Fabric tratadas como texto.
- **Inventario por tipo** (21 items en la raíz): 2 modelos semánticos (Agings y Financial Model, en TMDL); 6 informes (Agings, Checklist (Oracle), HAPA, MMS, Presupuesto y Rentabilidad, en PBIR); 10 dataflows (ingesta, cargas iniciales, TRANS_Silver, TRANS_Gold y Seguridad_CDC); 2 pipelines (Generar Reporting y Grabar salidas); 1 notebook (Generar_txt_Balance_Saldos). Fuera de los items: tres vistas SQL en sql/, el esquema de columnas en lakehouse/ y dos temas de Power BI mantenidos a mano.
- **Capas y orquestación**: lakehouse lh_tinkle_financiero con tres esquemas. 100 bruto: ficheros que llegan de los orígenes, sobre todo los recurrentes de la carpeta Dinamicos. 200 silver e histórico: datos transformados y cargas históricas. 300 gold en estrella: hechos y dimensiones. El pipeline Generar Reporting es lineal: ingesta a 100, refresco del endpoint SQL, TRANS_Silver, refresco del endpoint, TRANS_Gold y refresco de dos modelos semánticos. Los INICIAL_*, INGESTA_Maestros y Seguridad_CDC no aparecen en ningún pipeline; cómo y cuándo se ejecutan está por confirmar. Grabar salidas genera los TXT de balance y saldos con el notebook y los copia a SharePoint.
- **Los dos modelos**:
  - Financial Model: Direct Lake sobre el lakehouse, con 15 tablas (4 de hechos: Fact_Actuals, Fact_Asignacion_RRHH, MMS y Presupuestos; 11 de dimensiones y auxiliares) y 16 relaciones activas. Unidades y _Medidas son tablas calculadas en import. No tiene roles RLS ni OLS. Las medidas van por familias: escala, reporting contable y presupuesto, real frente a MMS y Gross Income, personal, dedicación y rentabilidad, y formato.
  - Agings: modo import. Lee 200 Aging_Clientes y 200 Aging_Proveedores del SQL endpoint. Sus tablas snapshot cruzan facturas con la tabla Fechas, un calendario fijo de 2026 y 2027, distinto de Dim_Calendar.
- **Superficie de consumo**: no hay API HTTP propia. Se consume por medidas DAX (Financial Model: escala, reporting, real frente a MMS, personal y dedicación; Agings: saldo pendiente y número de facturas), por seis informes y por tres vistas SQL. Las vistas 200.vw_Export_Grupo y 200.vw_Export_Saldos_4_7 exportan el último periodo para los ficheros de Grupo, y 300.vw_Reporting_Actuals une cuentas y medidas de reporting real. Los consumidores externos de las vistas 200 no se pueden derivar del repositorio.
- **Orígenes y destinos externos**: entrada por la carpeta Reporting Financiero de Files en el lakehouse, que es un shortcut a OneDrive o SharePoint. Tiene tres subcarpetas: Arranque (cargas iniciales), Dinamicos (recurrentes, con AGINGS) y Maestros. Llegan Excel y CSV de Oracle, MMS, extractos de Portugal, asientos de HAPA, agings, maestros, checklist, forecast, revenue y rentabilidad. Salida: TXT de balance y saldos 4_7 que se copian a la biblioteca Shared Documents de SharePoint, en Reporting Financiero, Salida de ficheros, Balance. El sitio y la cuenta del shortcut de entrada no están confirmados.
- **Riesgos conocidos**:
  - Sin RLS ni OLS en Financial Model: los datos de personas de la dimensión de personal son visibles para quien abra los informes.
  - Seguridad_CDC escribe la tabla RLS (100) mediante RLS_DataDestination. La auditoría de septiembre decía que no tenía destino; falta comprobar en el workspace que se ejecuta.
  - Las condiciones son Completed: los refrescos de modelos se ejecutan aunque falle la carga previa y pueden publicar datos incompletos.
  - Sin reintentos en ninguna actividad de los pipelines; un fallo se relanza a mano. La programación del pipeline no está en la definición.
  - Tablas con dos productores en modo Replace (Oracle_historico, Aging_Clientes y Aging_Proveedores): relanzar un INICIAL_* puede sustituir el histórico. La auditoría decía cuatro, con Dim_CDC; la definición exportada da tres.
  - Calendario fijo de Agings (2026 y 2027): al terminar, las tablas snapshot dejan de tener fechas de corte.
  - Las UDF no se versionan y solo confirman que el job se ha encolado (HTTP 202), no que haya terminado.
  - Mapeo de sociedades fijo en el notebook: una sociedad nueva quedaría fuera sin aviso explícito.
  - Tabla sin productor: Budget_historico. New_HAPA sí tiene productor (INGESTA_Carga_Datos), aunque la auditoría decía que no. Mapping HAPA escribe en 200.Mapping_HAPA y Mapping Portugal en 200.Mapping Portugal, este último mediante Mapping HAPA (2)_DataDestination (nombre engañoso).
- **Dónde mirar**: en vault/repos/rf-fabric/ el README y las secciones overview, architecture, domain-model, apis, data-model, integrations, configuration y quality. Fuera del vault: reporting-financiero/docs/flujo-fabric.md (flujo de cambio, validación y rollback), reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md (documento de arquitectura: la sección 1 tiene los ids reales, que no están en los .platform, y la sección 13 la auditoría) y reporting-financiero/CONTEXT.md (glosario de términos de negocio).
