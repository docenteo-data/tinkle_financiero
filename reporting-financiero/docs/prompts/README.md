# Prompts

Los `PROMPT_nueva_conversacion_*.md` arrancan una conversación por fichero de Grupo (Ageing, Revenue, Pendiente_Facturar, Working_Capital y CashFlow). Se escribieron en septiembre de 2026 y se actualizaron el 2026-11-03 con las respuestas recibidas y las validaciones con datos: cada uno empieza por una sección 0 que prevalece sobre las hipótesis antiguas que siguen debajo. El estado resumido de las cinco líneas está en `docs/contexto/20261103-estado-ficheros-grupo.md`, y las preguntas abiertas en `docs/contexto/PREGUNTAS_PARA_TINKLE.md`.

`copilot/` guarda las preguntas y respuestas usadas con GitHub Copilot para documentar el workspace, como registro.

Rutas que citan los prompts y su equivalente actual:

- `documentacion/esquema_lh_tinkle_financiero_100_200.tsv`: hoy `fabric/lakehouse/esquema.tsv` (con la capa `300` incluida).
- `documentacion/create_vw_*.txt`: hoy `fabric/sql/`.
- `otros/2026 03 - 0001 Magnitude Marzo/`: los TXT de marzo de 2026, en la carpeta `3.Fuentes` del OneDrive del proyecto (`DOCENTEO - General/02.Clientes/04.Tinkle/Reporting financiero/3.Fuentes/2026 03 - 0001 Magnitude Marzo/`). No se versionan.
- `Generar_txt_Agings.ipynb` / `Generar_txt_Ageing.ipynb`: borrador antiguo, hoy `notebooks/Generar_txt_Ageing.ipynb`. Su lógica de columnas parte de una premisa equivocada; solo es reutilizable la parte de escritura de ficheros.
