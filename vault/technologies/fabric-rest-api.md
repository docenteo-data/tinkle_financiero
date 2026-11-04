---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, fabric-rest-api]
---

# API REST de Microsoft Fabric

**Responsabilidad:** API REST v1 de Microsoft Fabric. Los scripts la usan para listar los items del workspace, descargar definiciones (getDefinition), actualizar definiciones de items existentes (updateDefinition), crear items nuevos, lanzar jobs de pipeline y seguir operaciones asíncronas y jobs.

## Repos that use it

- [[repos/rf-scripts/README|rf-scripts]] - capa común de llamadas HTTP y de operaciones asíncronas (`reporting-financiero/scripts/fabric_comun.py#peticion`, `reporting-financiero/scripts/fabric_comun.py#esperar_operacion`, `reporting-financiero/scripts/fabric_comun.py#items`, `reporting-financiero/scripts/fabric_comun.py#descargar_definicion`, `reporting-financiero/scripts/fabric_comun.py#publicar_definicion`, `reporting-financiero/scripts/fabric_comun.py#crear_item`); lanzamiento y seguimiento de jobs de pipeline (`reporting-financiero/scripts/fabric_comun.py#lanzar_pipeline`, `reporting-financiero/scripts/fabric_comun.py#esperar_job`; `reporting-financiero/scripts/ejecutar_fabric.py`); exportación y publicación (`reporting-financiero/scripts/exportar_fabric.py`, `reporting-financiero/scripts/publicar_fabric.py`)

## Integration surface

- **Access**: HTTP REST sobre la versión 1 de la API, desde Python con la biblioteca estándar. Siempre sobre un único workspace, fijado en una constante.
- **Auth**: token de Entra para el recurso de Fabric, obtenido con Azure CLI en cada ejecución. No hay claves de API en el repositorio.

## Notes

- getDefinition: los tipos con formato (modelo semántico en TMDL, informe en PBIR y notebook en ipynb) piden el formato en la consulta; dataflow y pipeline no. Si la respuesta no es 200 se trata como operación asíncrona.
- updateDefinition: envía las partes en base64, ordenadas por ruta y sin el fichero de metadatos `.platform`. Una respuesta 202 implica operación asíncrona. Solo actualiza items existentes; no borra.
- Creación de items: POST sobre los items del workspace con nombre, tipo y definición en base64 (`reporting-financiero/scripts/fabric_comun.py#crear_item`). Una respuesta 202 implica operación asíncrona. Solo se usa con `publicar_fabric.py --crear --confirmar`; sin `--confirmar` no se crea nada.
- Lanzamiento de jobs de pipeline: POST sobre `jobs/instances?jobType=Pipeline` del item, con los parámetros en `executionData`. Una respuesta 202 trae en la cabecera `Location` la URL del job; sin 202 o sin esa cabecera, lanza `RuntimeError` (`reporting-financiero/scripts/fabric_comun.py#lanzar_pipeline`).
- Seguimiento de jobs: `esperar_job` consulta la URL del job cada 20 segundos hasta `Completed`, `Failed`, `Cancelled` o `Deduped`. Si el tiempo máximo se agota, lanza `TimeoutError` y el job sigue en Fabric (`reporting-financiero/scripts/fabric_comun.py#esperar_job`, `reporting-financiero/scripts/ejecutar_fabric.py`).
- Historial de jobs: `GET` sobre `jobs/instances` de un pipeline no lista las ejecuciones que otro pipeline lanza con `ExecutePipeline`; solo lista las lanzadas directamente (`reporting-financiero/docs/flujo-fabric.md`, sección 2).
- Sondeo de operaciones: el identificador llega en una cabecera, se espera según el intervalo indicado por el servidor (3 segundos por defecto) y se consulta el estado hasta 120 veces.
- Excluido: User Data Functions, por llevar un secreto incrustado.
- TBD: límites de frecuencia y tiempos de la API; no se documentan en el repositorio y no se han investigado fuera de él.
