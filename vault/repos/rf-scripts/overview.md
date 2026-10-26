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
tags: [rf-scripts, overview]
---

# rf-scripts - Overview

> Cuándo cargar: necesitas saber qué script usar para exportar, comprobar, publicar o consultar el workspace de Fabric del cliente Tinkle, y qué puede escribir cada uno.

## Propósito

Unidad de scripts Python para trabajar con el workspace de Fabric "Tinkle - Financiero". El repositorio `main` refleja lo publicado en Fabric y `reporting-financiero/fabric/` es su copia en texto. Los scripts leen definiciones de Fabric, las comparan con el repo y, solo cuando se les pide, publican definiciones desde un commit.

El procedimiento completo (cómo leer, consultar, publicar, validar la cuenta, flujos de cambio y rollback) está en `reporting-financiero/docs/flujo-fabric.md`. Este overview no lo repite.

## Scripts

- `fabric_comun.py`: utilidades compartidas. Define el workspace, la cuenta esperada y el endpoint SQL, los tipos de item exportables y sus formatos, y las comprobaciones de cuenta. Obtiene los tokens de Azure CLI en cada ejecución y no los guarda. Contiene también la validación de que una consulta SQL sea de solo lectura. No es un punto de entrada.
- `exportar_fabric.py`: exporta las definiciones de los items a `fabric/` (modelos semánticos, informes, dataflows, pipelines y notebooks), las vistas del SQL endpoint y el esquema de columnas del lakehouse. Con `--comprobar [REF]` no escribe nada y dice si Fabric coincide con un commit (por defecto `main`).
- `publicar_fabric.py`: publica en Fabric la definición de uno o varios items tal como está en un commit. Sirve para el flujo de cambio preparado en el repo y para el rollback. Sin `--confirmar` solo simula. Antes de publicar comprueba que Fabric coincide con la referencia base (por defecto `main`) y se detiene si no coincide, salvo `--forzar`.
- `consultar_sql.py`: consulta de solo lectura al SQL endpoint del lakehouse `lh_tinkle_financiero`. Acepta solo sentencias SELECT o WITH sin palabras de escritura. Imprime un máximo de filas o escribe el resultado completo en un CSV dentro de `reporting-financiero/data/`, que no se versiona.

## Cuándo usar cada uno

- Comprobar sincronía o traer cambios de Fabric al repo: `exportar_fabric.py --comprobar main`, y después `exportar_fabric.py` si hay que regenerar `fabric/`.
- Publicar un cambio ya commiteado, o hacer rollback de un item a un commit anterior: `publicar_fabric.py`, primero en simulación y después con `--confirmar`. Lo ejecuta una persona del equipo, o el agente solo con confirmación explícita en ese momento, porque el workspace del cliente no tiene entorno de pruebas.
- Leer datos del lakehouse para validar o analizar: `consultar_sql.py`.

## Qué escribe en Fabric y qué no

- `exportar_fabric.py` y `consultar_sql.py` no escriben en Fabric. Solo listan items, piden definiciones y ejecutan SELECT.
- `publicar_fabric.py` es el único que escribe. Solo actualiza items que ya existen: no crea ni borra items. No publica las User Data Functions, porque su código lleva un secreto incrustado.
- Los scripts no imprimen tokens ni los escriben en ficheros.

## Por qué no hay domain-model ni data-model

Esta unidad no define entidades, esquemas ni modelos propios. Manipula definiciones ya existentes del workspace (TMDL, PBIR, dataflows, pipelines, notebooks, vistas SQL) tratándolas como texto. El modelo de datos vive en los items de Fabric y en la copia de `reporting-financiero/fabric/`, no en el código de estos scripts. Por eso no se documentan secciones `domain-model` ni `data-model` en este vault.

## Evidence

- `fabric_comun.py` - constantes de workspace, cuenta y endpoint SQL, formatos exportables, exclusiones y lista de sentencias de escritura.
- `exportar_fabric.py#descargar_todo` - descarga de items, vistas y esquema, sin escritura en Fabric.
- `exportar_fabric.py#exportar` - regeneración de `fabric/`.
- `publicar_fabric.py#main` - simulación por defecto, comprobación contra la base y publicación con `--confirmar`.
- `consultar_sql.py#main` - validación de solo lectura y salida en CSV dentro de `data/`.

## Open questions

- Flujo A (cambio en el portal de Fabric): exportar, commit en `reporting-financiero`, merge `--no-ff` en `main`; `exportar_fabric.py --comprobar main` debe dar 0.
- Flujo B (cambio commiteado en el repo): commit en `reporting-financiero`, simular con `publicar_fabric.py "<Item>" --ref reporting-financiero`, publicar con `--confirmar` solo con confirmación explícita de la persona, item a item; validar en Fabric, exportar, commit, merge en `main` y comprobar.
- Rollback: localizar el commit con `git log` del item, simular con `--ref <commit>`, publicar con `--confirmar`, validar, exportar y commit `revert(fabric): ...`.

Procedimiento completo en `reporting-financiero/docs/flujo-fabric.md`.
- Tests: `test_fabric_comun.py` (unitarios, sin conexión) y `test_fabric_e2e.py` (solo lectura, con `FABRIC_E2E=1`). Detalle en [[quality]].
