# Tinkle

Repositorio del cliente Tinkle en la organización `docenteo-data`.

## Áreas

    CLAUDE.md        reglas para la sesión principal del agente
    AGENTS.md        reglas para subagentes y Codex
    .claude/         plugins del equipo y subagente por defecto en Haiku
    vault/           conocimiento del cliente y de sus proyectos, escrito para el agente
    reporting-financiero/   Reporting financiero

El proyecto tiene su README y su `CONTEXT.md` en `reporting-financiero/`. Para entender el cliente, empieza por `vault/README.md`.

## Convenciones de git

- Una rama por línea de trabajo (`feature/<nombre-corto>`), creada desde `main`.
- En `main` directamente solo van el refresco del vault y las convenciones (CLAUDE.md, AGENTS.md, `.claude/`).
- `main` refleja lo publicado en Fabric y recibe las líneas de trabajo cerradas con merge `--no-ff`; después se refresca el vault.
- Commits convencionales en español: `feat(<trabajo>): ...`, `fix(...)`, `docs(...)`.
