# Reporting financiero

Proyecto de Tinkle. Arrancado el 2026-10-26. Estado: activo.

## Cómo empezar

- Trabaja en la rama `reporting-financiero` (`git branch --show-current`).
- El glosario del cliente va en `CONTEXT.md`: pídele a Claude que lo rellene con la skill grill-with-docs antes de escribir código.
- Los planes van en `docs/planes/AAAAMMDD-nombre.md`.

## Qué es

Sustituir el reporting financiero de Tinkle basado en Excel (Oracle, Portugal, HAPA, MMS y auxiliares) por un modelo central en Microsoft Fabric con informes en Power BI. Fase 1: P&L, balance, P&L por centro de coste y por directora, ficheros de Grupo. Fase 2: presupuesto y desviaciones. Fase 3: rentabilidad, aging y periodo medio de pago. Contexto completo en `docs/contexto/contexto-inicial.md` y arquitectura en `docs/contexto/Documentacion_Tinkle_Financiero.md`.

## Carpetas

    fabric/<Nombre>.<Tipo>/   definiciones de los items del workspace "Tinkle - Financiero", exportadas
                              con scripts/exportar_fabric.py: modelos semánticos (TMDL), informes (PBIR),
                              dataflows (Power Query M), pipelines y el notebook de ficheros de Grupo
    fabric/sql/               vistas del lakehouse para los ficheros de Grupo (Balance y Saldos 4_7)
    fabric/temas/             temas de Power BI
    fabric/esquema_lh_...tsv  esquema de las capas 100 y 200 del lakehouse lh_tinkle_financiero
    notebooks/                borradores locales (Ageing), aún no publicados en Fabric
    scripts/                  exportación, publicación y consultas SQL de Fabric
    tests/                    tests de los scripts (los de Fabric, con FABRIC_E2E=1)
    docs/contexto/            documentación técnica, manual funcional, preguntas abiertas y apuntes
    docs/prompts/             prompts de análisis por fichero de Grupo y de Copilot
    docs/diagramas/           flujo de datos, arquitectura y orquestación
    docs/planes/              planes de trabajo (AAAAMMDD-nombre.md)

## Fabric

`main` refleja lo publicado en el workspace y `fabric/` es su copia en texto. Qué vía usar para leer, consultar datos o publicar, cómo se valida la cuenta, los flujos de cambio y el rollback están en [docs/flujo-fabric.md](docs/flujo-fabric.md).

| Script | Para qué | Escribe en Fabric |
|---|---|---|
| `scripts/exportar_fabric.py` | Traer las definiciones de Fabric a `fabric/`; con `--comprobar main`, ver si coinciden | No |
| `scripts/consultar_sql.py` | Consultas SELECT al SQL endpoint del lakehouse | No |
| `scripts/publicar_fabric.py` | Publicar items desde un commit (flujo B y rollback); simulación salvo `--confirmar` | Sí |

Requisitos: Azure CLI con la cuenta de Tinkle por defecto y el entorno del proyecto (`pip install -r requirements.txt` en `.venv`). Las User Data Functions no se exportan ni se publican porque llevan un secreto incrustado.

## Datos y documentos del cliente (no se versionan)

- Fuentes (extractos de Oracle, MMS, HAPA, agings, presupuestos y ficheros de Grupo de marzo): `OneDrive - Docenteo/DOCENTEO - General/02.Clientes/04.Tinkle/Reporting financiero/3.Fuentes`.
- Propuestas, reuniones (actas y grabaciones), entregables `.pbix` y manual funcional: misma carpeta, en `1.Propuesta`, `3.Reuniones` y `6.Entregables`.
- Transcripciones de reuniones en texto: `OneDrive - Docenteo/Escritorio/Tinkle/otros/extraido`.
- Si un script necesita datos en local, van en `reporting-financiero/data/`, que está excluida por `.gitignore`.
