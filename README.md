# Tinkle

Repositorio del cliente Tinkle en la organización `docenteo-data`.

## Áreas

    CLAUDE.md        reglas para la sesión principal del agente
    AGENTS.md        reglas para subagentes y Codex
    .claude/         plugins del equipo y subagente por defecto en Haiku
    vault/           conocimiento del cliente y de sus proyectos, escrito para el agente
    reporting-financiero/   Reporting financiero

Cada proyecto tiene su README y su `CONTEXT.md`. Para entender el cliente, empieza por `vault/README.md`.

## Convenciones de git

- Una rama permanente por proyecto, con el nombre de su carpeta (`reporting-financiero`).
- Lo transversal (vault, CLAUDE.md, AGENTS.md) va directo a `main`.
- `main` recibe los ciclos cerrados de cada proyecto con merge `--no-ff`.
- Commits convencionales en español: `feat(<trabajo>): ...`, `fix(...)`, `docs(...)`.
