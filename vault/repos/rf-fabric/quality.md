---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-11-04T12:00:00Z
stack: generic
source_globs: ["*.Notebook/**", "Generar_salidas.DataPipeline/**", "Flujo_*.DataPipeline/**"]
tags: [rf-fabric, quality]
---

# rf-fabric - Quality

> Cuándo cargar: necesitas saber qué valida el notebook Generar_txt_Balance_Saldos antes de generar los TXT de Grupo, cómo comprobar que el repositorio coincide con Fabric o qué riesgos de calidad siguen abiertos.

## Validaciones del notebook Generar_txt_Balance_Saldos

Las validaciones se ejecutan dentro del notebook antes de generar ningún fichero de Grupo. Son comprobaciones de datos en tiempo de ejecución, no tests. Si una falla, el notebook se detiene con error y no genera ficheros. La excepción es el control de cierre, que se ejecuta después de escribir.

Parámetros de entrada (celda inicial):

- `ficheros`: si está vacío o solo tiene espacios, se generan Balance y Saldos_4_7. Ageing se genera solo si se pide expresamente: puede pedirse sola, junto a uno de los otros o con ellos separados por coma. Un nombre desconocido detiene el notebook antes de escribir ningún fichero.
- `periodo_esperado`: formato AAAA.MM. Si tiene otro formato, el notebook se detiene. Si está vacío, no se comprueba el periodo.

Sobre la vista de datos de Grupo:

- Campos obligatorios: ninguna columna de la lista `COLUMNAS_OBLIGATORIAS` (celda "ESTRUCTURA ESPERADA DEL TXT") puede estar vacía (nula o solo con espacios). El importe solo se considera vacío si es nulo, así que un cero es válido.
- Formato de periodo: los campos de periodo de datos y de periodo de posteo deben tener el formato AAAA.MM.
- Coherencia de periodos: el periodo de datos y el de posteo de cada fila deben coincidir.
- Coherencia de sociedad: el código de sociedad de cada fila y su equivalente de origen deben coincidir.
- Duplicados: no puede haber dos filas con la misma combinación de periodo, sociedad y cuenta.
- Unicidad de periodo por sociedad: una sociedad no puede aparecer con más de un periodo en la vista.

Antes de las validaciones se normalizan los campos de texto nulos a cadena vacía.

Sobre Saldos 4_7, que tiene su propia celda de preparación:

- Columnas requeridas: la vista debe contener todas las columnas esperadas, si no se detiene.
- Vista no vacía.
- Filas válidas: sociedad, código de fichero, texto de periodo, periodo y cuenta no vacíos, y saldo no nulo.
- Un único periodo por código de fichero.

Sobre Ageing, solo si se pide (vista `vw_Export_Ageing`):

- Columnas requeridas: la vista debe contener las columnas del TXT de Ageing y `sin_codigo`, si no se detiene.
- Campos obligatorios: ninguna de las columnas `COLUMNAS_AGEING_OBLIGATORIAS` (d_ca, d_dp, d_ru, d_client, d_pe, d_ac, d_fl, d_au, d_cu y p_amount) puede estar vacía. Un `d_ru` vacío indica una sociedad sin mapeo y detiene el notebook.
- Formato de periodo: `d_dp` con formato AAAA.M, y `d_dp` igual a `d_pe`.
- Tramos: `d_fl` solo puede ser GR0, GR1, GR2, GR3, GR4, GR5, GR8C, GR9C o GRICFLAG.
- Duplicados: no puede haber dos líneas con la misma sociedad, cliente y tramo.
- Unicidad de periodo por sociedad: una sociedad no puede aparecer con más de un periodo en Ageing.
- Código de cliente: no bloquea. Las líneas sin código Magnitude (`sin_codigo` a 1, salvo GRICFLAG) se cuentan y el notebook imprime un aviso con su número y su importe en miles.

Control de periodo antes de escribir: el periodo de los datos de Balance, de Saldos 4_7 y de Ageing (convertido a AAAA.MM) se reúne en un único conjunto. Si `periodo_esperado` tiene valor, ese conjunto debe ser exactamente ese periodo; si no, el notebook falla y no escribe ningún fichero.

Control de cierre (después de escribir), dos comprobaciones independientes. Ageing: siempre que se pide Ageing, deben generarse 5 ficheros de Ageing, uno por sociedad; si no, el notebook termina con error. Total: solo si se piden Balance y Saldos_4_7 y hay 5 sociedades de Balance y 5 de Saldos_4_7, el total de ficheros generados debe ser 10, o 15 si también se pide Ageing; con otro número de sociedades o sin los dos tipos, esta comprobación del total no se aplica. Si alguna falla, el notebook termina con error, pero los ficheros ya están escritos en Files.

## Comprobación de coincidencia con Fabric

Que el repositorio coincida con el workspace de Fabric se comprueba con `exportar_fabric.py --comprobar`. El flujo completo está en `reporting-financiero/docs/flujo-fabric.md`; este documento no lo describe.

## Riesgos de calidad conocidos

Identificadores de la auditoría de `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`, sección 13:

- Sin roles RLS ni OLS (S3, S4, confirmados en 13.7). Los datos salariales de Dim_RRHH son visibles para quien acceda a los informes de Financial Model. La auditoría (N3) decía que el dataflow Seguridad_CDC no tenía destino activo, así que la tabla RLS no se actualizaba; la definición exportada lo contradice, ver [[data-model]]. Falta comprobar en el workspace que se ejecuta.
- Condiciones Completed en el pipeline anterior (O1). En Generar Reporting, los refrescos de modelos se ejecutan aunque falle la carga previa, lo que puede publicar datos incompletos. Los flujos nuevos (Flujo_total_reporting) solo ejecutan Refresco_modelos si Flujo_actualizar_datos termina con Succeeded; el riesgo sigue hasta que se retire Generar Reporting.
- Sin reintentos (O6). Ninguna actividad de los pipelines, antiguos o nuevos, tiene reintentos configurados.
- Confirmación solo de encolado (O2). Las UDF comprueban el HTTP 202, es decir, que el job se ha encolado, no que haya terminado.
- Generación de ficheros sin control de periodo (nuevo). Flujo_total_txt y la UDF `Generar_txt` (botón "Generar txt") ejecutan Generar_salidas sin pasar `ficheros` ni `periodo_esperado`: generan los diez ficheros de Balance y Saldos_4_7 (no Ageing) y no comparan el periodo con el cierre pedido. Pasar esos parámetros desde el botón está pendiente de revisar con Finanzas (ADR 0001, punto 4), no previsto; hasta entonces, el control depende de que el último periodo cargado sea el correcto.
- Ageing con códigos de cliente provisionales (nuevo). Los códigos Magnitude de `Dim_Clientes.Codigo_Magnitude` vienen de `Revenue 2026 FT3.xlsx` (consulta Mapeo_Magnitude), con las mismas reglas que el script `scripts/validar_ficheros_grupo.py`. Las líneas sin código llevan el nombre del cliente en `d_client` y el notebook solo avisa. Hasta que Finanzas confirme los códigos, el fichero de Ageing no es definitivo.
- Copia de Ageing sin filtro (nuevo). La actividad Copiar Ageing a SharePoint se ejecuta en cada Generar_salidas, aunque no se haya pedido Ageing, y copia todos los .txt de `Exportaciones/Ageing`, también los de ejecuciones anteriores, porque el nombre lleva fecha y hora. La copia de Balance funciona igual.
- Tablas con dos productores (O3). Oracle_historico, Aging_Clientes y Aging_Proveedores tienen dos productores en modo Replace. La auditoría (N4) decía que eran cuatro, incluido Dim_CDC; la definición exportada lo contradice, ver [[data-model]]. Relanzar un INICIAL_* puede borrar el histórico.
- Calendario fijo en el modelo Agings (N10). Las tablas snapshot dejarán de tener fechas de corte al terminar el calendario.
- Mapeo de sociedades fijo en el notebook (M8). Una sociedad nueva se genera igualmente, con su código D_RU como prefijo del fichero, sin aviso explícito, y no se aplica el control de cierre de 10 ficheros (solo se aplica con 5 y 5 sociedades).

No hay tests automáticos dentro de Fabric. La calidad depende de las validaciones del notebook y de las comprobaciones manuales del repositorio.

## Evidence

- `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` - parámetros, celdas de validaciones previas, preparación y validación de Saldos 4_7, validación de Ageing, control de periodo y control de cierre.
- `reporting-financiero/fabric/sql/300.vw_Export_Ageing.sql` - tramos, código de cliente provisional y origen del importe.
- `reporting-financiero/fabric/INGESTA_Maestros.Dataflow/mashup.pq#Mapeo_Magnitude` - origen provisional de los códigos Magnitude.
- `reporting-financiero/fabric/Generar_salidas.DataPipeline/pipeline-content.json` - parámetros `ficheros` y `periodo_esperado` del pipeline, y copias de Balance y Ageing a SharePoint.
- `reporting-financiero/fabric/Flujo_total_txt.DataPipeline/pipeline-content.json` - ExecutePipeline sin parámetros.
- `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md` - sección 13 (13.1, 13.2, 13.3, 13.6 y 13.7).
- `reporting-financiero/fabric/Seguridad_CDC.Dataflow/mashup.pq` - destino de la consulta RLS (contraste con la auditoría N3).
- `reporting-financiero/docs/flujo-fabric.md` - citado para la comprobación con `exportar_fabric.py --comprobar`; no leído en esta sección.
- `vault/adrs/0001-orquestacion-y-vistas-de-salida.md` - pendientes de botones y parámetros (punto 4) y de retirada de pipelines anteriores (punto 6).

## Open questions

- TBD: procedimiento detallado y frecuencia de `exportar_fabric.py --comprobar`, según `reporting-financiero/docs/flujo-fabric.md`.
