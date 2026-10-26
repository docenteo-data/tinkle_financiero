---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-fabric
source: reporting-financiero/fabric
commit: fb5c2b5
last_sync: 2026-10-26T22:45:58Z
stack: generic
source_globs: ["*.Notebook/**"]
tags: [rf-fabric, quality]
---

# rf-fabric - Quality

> Cuándo cargar: necesitas saber qué valida el notebook Generar_txt_Balance_Saldos antes de generar los TXT de Grupo, cómo comprobar que el repositorio coincide con Fabric o qué riesgos de calidad siguen abiertos.

## Validaciones del notebook Generar_txt_Balance_Saldos

Las validaciones se ejecutan dentro del notebook antes de generar ningún fichero de Grupo. Son comprobaciones de datos en tiempo de ejecución, no tests. Si una falla, el notebook se detiene con error y no genera ficheros.

Sobre la vista de datos de Grupo:

- Campos obligatorios: ninguna columna de la lista obligatoria puede estar vacía (nula o solo con espacios). El importe solo se considera vacío si es nulo, así que un cero es válido.
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

## Comprobación de coincidencia con Fabric

Que el repositorio coincida con el workspace de Fabric se comprueba con `exportar_fabric.py --comprobar`. El flujo completo está en `reporting-financiero/docs/flujo-fabric.md`; este documento no lo describe.

## Riesgos de calidad conocidos

Identificadores de la auditoría de `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md`, sección 13:

- Sin roles RLS ni OLS (S3, S4, confirmados en 13.7). Los datos salariales de Dim_RRHH son visibles para quien acceda a los informes de Financial Model. La auditoría (N3) decía que el dataflow Seguridad_CDC no tenía destino activo, así que la tabla RLS no se actualizaba; la definición exportada lo contradice, ver [[data-model]]. Falta comprobar en el workspace que se ejecuta.
- Condiciones Completed en el pipeline (O1). Los refrescos de modelos se ejecutan aunque falle la carga previa, lo que puede publicar datos incompletos.
- Sin reintentos (O6). Ninguna actividad del pipeline tiene reintentos configurados.
- Confirmación solo de encolado (O2). Las UDF comprueban el HTTP 202, es decir, que el job se ha encolado, no que haya terminado.
- Tablas con dos productores (O3). Oracle_historico, Aging_Clientes y Aging_Proveedores tienen dos productores en modo Replace. La auditoría (N4) decía que eran cuatro, incluido Dim_CDC; la definición exportada lo contradice, ver [[data-model]]. Relanzar un INICIAL_* puede borrar el histórico.
- Calendario fijo en el modelo Agings (N10). Las tablas snapshot dejarán de tener fechas de corte al terminar el calendario.
- Mapeo de sociedades fijo en el notebook (M8). Una sociedad nueva quedaría fuera sin aviso explícito.

No hay tests automáticos dentro de Fabric. La calidad depende de las validaciones del notebook y de las comprobaciones manuales del repositorio.

## Evidence

- `reporting-financiero/fabric/Generar_txt_Balance_Saldos.Notebook/notebook-content.ipynb` - celdas de validaciones previas y de preparación y validación de Saldos 4_7.
- `reporting-financiero/docs/contexto/Documentacion_Tinkle_Financiero.md` - sección 13 (13.1, 13.2, 13.3, 13.6 y 13.7).
- `reporting-financiero/fabric/Seguridad_CDC.Dataflow/mashup.pq` - destino de la consulta RLS (contraste con la auditoría N3).
- `reporting-financiero/docs/flujo-fabric.md` - citado para la comprobación con `exportar_fabric.py --comprobar`; no leído en esta sección.

## Open questions

- TBD: lista exacta de columnas obligatorias, definida fuera de las celdas de validación revisadas.
- TBD: procedimiento detallado y frecuencia de `exportar_fabric.py --comprobar`, según `reporting-financiero/docs/flujo-fabric.md`.
