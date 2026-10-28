"""Genera el anexo de la auditoría con todos los pendientes de cada concepto.

Lee la tabla de conceptos (sección 1) de la auditoría y, para cada concepto, copia de sus fuentes
la descripción completa de lo que agrupa:
- los puntos P-nnn del registro de reuniones (`docs/reuniones/README.md`);
- los riesgos técnicos S, O, M, D y N de la sección 13 de `docs/contexto/Documentacion_Tinkle_Financiero.md`,
  con su estado más reciente (13.7, si no 13.6);
- las preguntas de `docs/contexto/PREGUNTAS_PARA_TINKLE.md`.

Escribe el anexo entre las marcas `<!-- anexo:inicio -->` y `<!-- anexo:fin -->` del final de la auditoría;
si no existen, las añade. Volver a ejecutarlo deja el mismo resultado.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/anexo_pendientes.py reporting-financiero/docs/auditoria/20261028-auditoria-general.md
"""

import io
import re
import sys
from pathlib import Path

INICIO, FIN = "<!-- anexo:inicio -->", "<!-- anexo:fin -->"
PROYECTO = Path(__file__).resolve().parents[1]
REGISTRO = PROYECTO / "docs" / "reuniones" / "README.md"
TECNICA = PROYECTO / "docs" / "contexto" / "Documentacion_Tinkle_Financiero.md"
PREGUNTAS = PROYECTO / "docs" / "contexto" / "PREGUNTAS_PARA_TINKLE.md"


def celdas(linea):
    return [c.strip() for c in linea.strip().strip("|").split("|")]


def expandir(texto, prefijo):
    """'P-013, P-067 a P-069' con prefijo 'P-' da [13, 67, 68, 69]."""
    numeros = []
    for a, b in re.findall(re.escape(prefijo) + r"(\d+)(?: a " + re.escape(prefijo) + r"(\d+))?", texto):
        numeros.extend(range(int(a), int(b or a) + 1))
    return numeros


def leer_conceptos(auditoria):
    s1 = auditoria.split("## 1.", 1)[1].split("### Totales", 1)[0]
    conceptos, bloque = [], None
    for linea in s1.splitlines():
        if not linea.startswith("| "):
            continue
        c = celdas(linea)
        if len(c) != 8 or c[0] in ("Nº",) or set(c[0]) <= {"-"}:
            continue
        if not c[0]:
            bloque = c[1].strip("*")
            continue
        conceptos.append({"n": int(c[0]), "nombre": c[1], "bloque": bloque, "pendientes": c[7]})
    return conceptos


def leer_registro():
    puntos = {}
    for linea in io.open(REGISTRO, encoding="utf-8"):
        if linea.startswith("| P-"):
            c = celdas(linea)
            puntos[int(c[0][2:])] = {"id": c[0], "tipo": c[1], "desc": c[2], "resp": c[3], "estado": c[5]}
    return puntos


def leer_tecnica():
    riesgos, estados = {}, {}
    texto = io.open(TECNICA, encoding="utf-8").read()
    for linea in texto.splitlines():
        m = re.match(r"^\| ([SOMDN]\d+) \| (Alta|Media|Baja) \| ([^|]+) \|", linea)
        if m:
            riesgos[m.group(1)] = {"id": m.group(1), "prio": m.group(2), "desc": m.group(3).strip()}
    # Estados: 13.6 y después 13.7, que manda.
    for seccion in ("### 13.6", "### 13.7"):
        if seccion not in texto:
            continue
        parte = texto.split(seccion, 1)[1].split("\n### ", 1)[0].split("**Hallazgos nuevos**", 1)[0]
        for linea in parte.splitlines():
            c = celdas(linea) if linea.startswith("| ") else []
            if len(c) == 3 and c[0] not in ("#",) and not set(c[0]) <= {"-"}:
                for ident in re.findall(r"[SOMDN]\d+", c[0]):
                    estados[ident] = f"{c[1]}: {c[2]}"
    return riesgos, estados


def leer_preguntas():
    preguntas = {}
    for linea in io.open(PREGUNTAS, encoding="utf-8"):
        m = re.match(r"^(\d+)\. (.*)$", linea.strip())
        if m:
            preguntas[int(m.group(1))] = m.group(2).strip()
    return preguntas


def limpia(texto):
    # Normas de redacción del repositorio: sin rayas ni flechas (algunas fuentes antiguas las llevan).
    texto = texto.replace(" — ", ", ").replace("—", "-").replace("→", "a")
    return texto.replace("|", "/").strip()


def generar(auditoria):
    conceptos = leer_conceptos(auditoria)
    puntos = leer_registro()
    riesgos, estados = leer_tecnica()
    preguntas = leer_preguntas()

    out = [
        "## 11. Anexo. Pendientes por concepto",
        "",
        "Todos los puntos que agrupa cada concepto de la sección 1, con su descripción. Se genera con "
        "`scripts/anexo_pendientes.py` a partir del registro de reuniones, la auditoría técnica y las "
        "preguntas de septiembre; no se edita a mano.",
        "",
        "- Puntos del registro (P-nnn): estado a 07/05/2026, fecha de la última reunión; el origen exacto "
        "(acta y minuto) está en `docs/reuniones/README.md`.",
        "- Riesgos técnicos (S, O, M, D, N): situación según la última verificación de la auditoría técnica.",
        "",
    ]
    vistos = set()
    bloque = None
    for c in conceptos:
        if c["bloque"] != bloque:
            bloque = c["bloque"]
            out += [f"### {bloque}", ""]
        out += [f"#### Concepto {c['n']}. {c['nombre']}", ""]
        ids_p = expandir(c["pendientes"], "P-")
        ids_t = []
        for letra in "SOMDN":
            ids_t += [f"{letra}{n}" for n in expandir(c["pendientes"], letra)]
        ids_preg = []
        m = re.search(r"[Pp]reguntas (\d+) a (\d+)", c["pendientes"])
        if m:
            ids_preg = list(range(int(m.group(1)), int(m.group(2)) + 1))
        if ids_p:
            out += ["**Puntos del registro**", "", "| Id | Tipo | Descripción | Responsable | Estado |", "|---|---|---|---|---|"]
            for n in ids_p:
                p = puntos[n]
                vistos.add(n)
                out.append(f"| {p['id']} | {p['tipo']} | {limpia(p['desc'])} | {limpia(p['resp'])} | {limpia(p['estado'])} |")
            out.append("")
        if ids_t:
            out += ["**Riesgos técnicos**", "", "| Id | Prioridad | Problema | Situación |", "|---|---|---|---|"]
            for t in ids_t:
                r = riesgos[t]
                out.append(f"| {t} | {r['prio']} | {limpia(r['desc'])} | {limpia(estados.get(t, 'Abierto desde la auditoría de septiembre'))} |")
            out.append("")
        if ids_preg:
            out += ["**Preguntas pendientes**", "", "| Nº | Pregunta pendiente para Tinkle |", "|---|---|"]
            for q in ids_preg:
                out.append(f"| {q} | {limpia(preguntas[q])} |")
            out.append("")
        if not (ids_p or ids_t or ids_preg):
            out += [f"No agrupa puntos del registro: sale de {limpia(c['pendientes'])}.", ""]
        elif not ids_p and not ids_t and ids_preg:
            pass
        resto = re.sub(r"P-\d+( a P-\d+)?|[SOMDN]\d+( a [SOMDN]\d+)?|[Pp]reguntas \d+ a \d+[^;]*", "", c["pendientes"])
        resto = re.sub(r"^[;,\s]+|[;,\s]+$", "", re.sub(r"[;,]\s*[;,]", ";", resto))
        if resto and (ids_p or ids_t or ids_preg):
            out += [f"Además: {resto}.", ""]
    faltan = sorted(set(puntos) - vistos)
    if faltan:
        raise SystemExit(f"ERROR: puntos del registro sin concepto: {faltan}")
    return "\n".join(out).rstrip() + "\n"


def main():
    ruta = Path(sys.argv[1])
    texto = io.open(ruta, encoding="utf-8").read()
    base = texto.split(INICIO, 1)[0].rstrip() if INICIO in texto else texto.rstrip()
    anexo = generar(texto)
    io.open(ruta, "w", encoding="utf-8", newline="\n").write(f"{base}\n\n{INICIO}\n\n{anexo}\n{FIN}\n")
    print("OK anexo con", anexo.count("\n| P-"), "puntos del registro")


if __name__ == "__main__":
    main()
