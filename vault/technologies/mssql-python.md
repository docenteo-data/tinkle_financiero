---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, mssql-python]
---

# mssql-python

**Responsabilidad:** driver de Python de Microsoft para SQL Server y el SQL endpoint de Fabric. Permite a los scripts leer el lakehouse con consultas T-SQL y, en `rf-scripts`, crear o reemplazar las vistas de exportación.

## Repos that use it

- [[repos/rf-scripts/README|rf-scripts]] - conexión, descarga de vistas, consulta de solo lectura y publicación de vistas (`reporting-financiero/scripts/fabric_comun.py#conectar_sql`, `reporting-financiero/scripts/fabric_comun.py#ficheros_sql`, `reporting-financiero/scripts/fabric_comun.py#descargar_sql`, `reporting-financiero/scripts/fabric_comun.py#publicar_vista`, `reporting-financiero/scripts/publicar_fabric.py`, `reporting-financiero/scripts/consultar_sql.py`, y las dos consultas fijas de solo lectura de `reporting-financiero/scripts/validar_ficheros_grupo.py#consultar`); versión fijada en `reporting-financiero/requirements.txt`

## Integration surface

- **Access**: biblioteca de Python instalada con pip, versión 1.16.0 fijada. Conecta con el SQL endpoint del lakehouse con cifrado activado.
- **Auth**: token de Entra pasado al driver como atributo de conexión. La cadena de conexión solo lleva servidor, base de datos y cifrado; no hay usuario, contraseña ni DSN.

## Notes

- `descargar_sql` lee las vistas de los esquemas 100, 200 y 300 y el esquema de información del lakehouse.
- Escritura: `publicar_vista` ejecuta una sentencia `CREATE VIEW` (o `CREATE OR ALTER VIEW` si la vista ya existe) y confirma el cambio. Solo se ejecuta con `publicar_fabric.py ... --confirmar`; sin esa opción, la simulación no toca el SQL endpoint. No borra vistas ni admite líneas `GO`.
- Vistas de exportación actuales: `300.vw_Export_Grupo` y `300.vw_Export_Saldos_4_7` (`reporting-financiero/fabric/sql/`). Las del esquema 200 ya no están en Fabric.
- `consultar_sql.py` solo admite sentencias que empiezan por SELECT o WITH y filtra palabras de escritura; es un filtro por palabras clave, no un analizador SQL.
- Los tests de extremo a extremo (`FABRIC_E2E=1`) también leen del SQL endpoint.
- Motivo del driver: los equipos solo tienen instalado el driver ODBC antiguo "SQL Server", que no admite tokens de Entra ID; mssql-python trae su propio driver y se instala en el entorno del proyecto sin tocar Windows (decisión del 2026-10-26, ver `reporting-financiero/docs/flujo-fabric.md`).
- TBD: confirmar qué permisos tiene la identidad sobre el SQL endpoint. La lectura la garantiza el filtro de `consultar_sql.py`, no un permiso, y la identidad puede crear vistas (lo hace `publicar_vista`).
