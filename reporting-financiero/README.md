# Reporting financiero

Proyecto de Tinkle. Arrancado el 2026-10-26. Estado: activo.

## Cómo empezar

- Trabaja en la rama `reporting-financiero` (`git branch --show-current`).
- El glosario del cliente va en `CONTEXT.md`: pídele a Claude que lo rellene con la skill grill-with-docs antes de escribir código.
- Los planes van en `docs/planes/AAAAMMDD-nombre.md`.

## Qué es

Sustituir el reporting financiero de Tinkle basado en Excel (Oracle, SAGE, Portugal y auxiliares) por un modelo central en Microsoft Fabric con informes en Power BI. Fase 1: P&L, balance, P&L por CeCo y por directora, exportación al grupo. Fase 2: presupuesto y desviaciones. Fase 3: rentabilidad, agings y PMP. Contexto completo en `docs/contexto/contexto-inicial.md`.

## Carpetas

    powerbi/          informes y modelo semántico en formato PBIP (texto, versionable) y temas
    fabric/sql/       vistas del lakehouse (exportación al grupo, saldos 4 y 7)
    fabric/           esquema del lakehouse lh_tinkle_financiero
    notebooks/        notebooks de generación de ficheros (Ageing)
    docs/contexto/    documentación técnica, manual, preguntas abiertas y apuntes
    docs/prompts/     prompts de análisis por informe (Ageing, CashFlow, Revenue...) y de Copilot
    docs/diagramas/   flujo de datos, arquitectura y orquestación
    docs/planes/      planes de trabajo (AAAAMMDD-nombre.md)

## Datos y documentos del cliente (no se versionan)

- Fuentes (extractos de Magnitude, Oracle, MMS, HAPA, agings, presupuestos): `OneDrive - Docenteo/DOCENTEO - General/02.Clientes/04.Tinkle/Reporting financiero/3.Fuentes`.
- Propuestas, reuniones (actas y grabaciones), entregables `.pbix` y manual funcional: misma carpeta, en `1.Propuesta`, `3.Reuniones` y `6.Entregables`.
- Si un script necesita datos en local, van en `reporting-financiero/data/`, que está excluida por `.gitignore`.

## Power BI

Abre los informes desde la carpeta `powerbi/` con Power BI Desktop (formato PBIP). `Reporting Financiero Tinkle.Report` usa el modelo `Reporting Financiero Tinkle.SemanticModel` por ruta relativa. La fuente de verdad de lo publicado sigue siendo el workspace de Fabric: tras publicar, vuelve a exportar aquí.
