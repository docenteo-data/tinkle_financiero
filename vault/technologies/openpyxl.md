---
type: technology
load_tier: 2
schema_version: 1
tags: [technology, openpyxl]
---

# openpyxl

**Responsabilidad:** biblioteca de Python para leer libros de Excel (`.xlsx` y `.xlsm`). Permite a los scripts leer los Excel de origen de los ficheros de Grupo sin abrir Excel.

## Repos that use it

- [[repos/rf-scripts/README|rf-scripts]] - lectura del aging de clientes (hoja DATOS) y del libro Revenue 2026 FT3 (código de cliente Magnitude) en la validación de ficheros de Grupo (`reporting-financiero/scripts/validar_ficheros_grupo.py#validar_ageing`, `reporting-financiero/scripts/validar_ficheros_grupo.py#mapeo_magnitude`); versión fijada en `reporting-financiero/requirements.txt`

## Integration surface

- **Access**: biblioteca de Python instalada con pip en el `.venv` de `reporting-financiero`, versión 3.1.5 fijada. Abre los libros en modo solo lectura y con valores calculados, sin fórmulas.
- **Auth**: ninguna. Lee ficheros locales de la carpeta `3.Fuentes` sincronizada por OneDrive (ver [[infrastructure/sharepoint-online]]).

## Notes

- Excel guarda como número algunos códigos de cliente Magnitude y pierde el cero inicial (`1500400` en lugar de `01500400`): el script los rellena a 8 dígitos.
- El hook de diseño de la organización trata como visual cualquier comando que toque Excel, aunque solo lea; hay que cargar la skill `docenteo-design` antes. No se genera nada visual.
- Contexto de negocio: [[domains/ficheros-de-grupo]].
