---
type: repo-doc
load_tier: 2
schema_version: 1
repo: rf-scripts
source: reporting-financiero/scripts
commit: 7d6aa2b
last_sync: 2026-10-27T00:10:00Z
stack: python
source_globs: ["*.py"]
tags: [rf-scripts, architecture]
---

# rf-scripts - Architecture

> Cuándo cargar: necesitas entender cómo se relacionan los scripts de Fabric de Tinkle (exportar, publicar, consultar SQL) o dónde vive la lógica compartida (cuenta, API REST, git, SQL).

## Núcleo: fabric_comun.py

Módulo compartido sin punto de entrada propio. Tiene cuatro bloques:

- Cuenta y tokens: `comprobar_cuenta` verifica que Azure CLI apunta a la cuenta de Tinkle (si no, sale con código 2). `token` pide al CLI un token para Fabric o para SQL. `_az` sale con código 2 si Azure CLI falla. Ningún script guarda ni imprime tokens.
- API REST: `peticion` hace las llamadas HTTP con token Bearer. `esperar_operacion` sondea las operaciones asíncronas hasta `Succeeded` o `Failed`. `items`, `descargar_definicion` y `publicar_definicion` cubren listar, leer y escribir definiciones. `partes_para_publicar` excluye los ficheros que no son publicables (`.platform`).
- Git: `ficheros_en_git` lee la carpeta `reporting-financiero/fabric` de un commit con `git archive`, sin tocar la carpeta de trabajo. `solo_items` filtra a lo exportable y `comparar` clasifica las diferencias en nuevos, cambiados y borrados.
- SQL: `conectar_sql` abre la conexión al SQL endpoint del lakehouse con token. `descargar_sql` y `ficheros_sql` leen vistas y columnas de los esquemas 100, 200 y 300. `es_consulta_de_lectura` bloquea las sentencias de escritura.

Configuración clave en el módulo: `FORMATOS` define qué tipos de item se exportan y publican y con qué formato de definición. Las User Data Functions quedan fuera a propósito. `CARPETAS_LAKEHOUSE` marca las carpetas de vistas y esquema.

## Puntos de entrada

- `exportar_fabric.py`: lee Fabric y escribe `fabric/` o compara con un commit.
- `publicar_fabric.py`: escribe en Fabric desde un commit de git. Solo actualiza items existentes.
- `consultar_sql.py`: consulta de solo lectura al SQL endpoint.

## Flujos

### Exportar

1. Comprobar la cuenta y obtener el token de Fabric (`comprobar_cuenta`, `token`).
2. Listar los items del workspace (`items`) y quedarse con los tipos de `FORMATOS`, ordenados por tipo y nombre.
3. Descargar cada definición con `descargar_definicion`. Si la respuesta no es 200, espera la operación asíncrona (`esperar_operacion`) y lee el resultado. Un error en un item se registra y el proceso sigue.
4. Añadir las vistas y el esquema del lakehouse con `descargar_sql` (`sql/` y `lakehouse/esquema.tsv`).
5. Si hay errores en cualquier item o en SQL, no escribe ni compara y sale con código 2.
6. Modo normal: `exportar` borra las carpetas generadas y las vuelve a escribir enteras. `temas/` no se toca.
7. Modo `--comprobar [REF]`: `ficheros_en_git` lee el commit (por defecto `main`), `solo_items` filtra y `comparar` clasifica las diferencias. Sale con 0 si coincide, con 1 si no, y con 2 si la REF no existe en git.

### Publicar

1. Validar que los tipos son publicables, comprobar la cuenta y obtener el token.
2. Comprobar que los items existen en Fabric. El script no crea ni borra items.
3. Leer de git, con `--ref` (por defecto `HEAD`), las definiciones a publicar, y de git, con `--base` (por defecto `main`), la referencia esperada.
4. Descargar de Fabric el estado actual y compararlo con `--base`. Si hay diferencias, sale con código 1, salvo con `--forzar`.
5. Por cada item, calcular el resumen de cambios (nuevos, cambiados, quitados).
6. Sin `--confirmar` solo simula. Con `--confirmar` llama a `publicar_definicion`, que envía `updateDefinition` y espera la operación si la respuesta es 202.
7. Sale con 0 si todo va bien y con 2 ante un error.

### Consultar SQL

1. Leer la sentencia del argumento o de `--fichero`.
2. `es_consulta_de_lectura` quita comentarios, literales y nombres entre corchetes. Después exige que la sentencia empiece por SELECT o WITH y que no contenga palabras de escritura. Si no lo cumple, sale con código 2 sin conectar.
3. Con `--csv`, comprobar que la ruta está dentro de `reporting-financiero/data/`.
4. Comprobar la cuenta y conectar con `conectar_sql`.
5. Ejecutar. Con `--csv` escribe todas las filas en UTF-8 separadas por punto y coma. Sin él imprime como mucho `--max-filas` filas (50 por defecto) en ASCII.
6. Un error del driver sale con código 1.

## Dependencias

- Azure CLI (`az`) en el PATH, con sesión en la cuenta de Tinkle.
- Biblioteca `mssql_python`, para `consultar_sql.py` y para la exportación de vistas y esquema en `exportar_fabric.py`. El resto usa la biblioteca estándar de Python.

## Evidence

- `fabric_comun.py#comprobar_cuenta`, `#token`, `#peticion`, `#esperar_operacion`, `#descargar_definicion`, `#publicar_definicion`, `#ficheros_en_git`, `#solo_items`, `#comparar`, `#descargar_sql`, `#ficheros_sql`, `#conectar_sql`, `#es_consulta_de_lectura`.
- `exportar_fabric.py#descargar_todo`, `#exportar`, `#comprobar`, `#main`.
- `publicar_fabric.py#main`.
- `consultar_sql.py#main`.
