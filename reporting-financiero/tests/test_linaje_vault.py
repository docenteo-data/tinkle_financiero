"""Cobertura del documento de linaje del vault (vault/repos/rf-fabric/lineage.md).

El vault solo se marca como desactualizado cuando cambia un fichero que vigila, y
al resincronizar se reescribe el documento: nada garantiza que una consulta o una
tabla nueva acaben en él. Este test cierra ese hueco.

Modos de fallo cubiertos:
- Un dataflow tiene una consulta que no aparece en la sección de su dataflow.
- Una tabla de lakehouse/esquema.tsv no aparece en "Lectores por tabla".
- En fabric/ aparece un tipo de item (o una carpeta suelta) que el documento no contempla.
"""

import re
import shutil
from pathlib import Path

PROYECTO = Path(__file__).resolve().parents[1]
FABRIC = PROYECTO / "fabric"
LINAJE = PROYECTO.parent / "vault" / "repos" / "rf-fabric" / "lineage.md"

CONSULTA = re.compile(r'^shared\s+(#"[^"]+"|[A-Za-z_][\w.]*)\s*=', re.M)
OCULTAS = re.compile(r"(_DataDestination|^DefaultDestination)$")


def seccion(texto, titulo, nivel="## "):
    """Texto desde el encabezado `titulo` hasta el siguiente del mismo nivel o superior."""
    partes = re.split(r"(?m)^(#{2,3} .*)$", texto)
    salida, dentro = [], False
    for trozo in partes:
        if re.match(r"#{2,3} ", trozo):
            if dentro and len(trozo) - len(trozo.lstrip("#")) <= len(nivel) - 1:
                break
            if trozo.startswith(nivel + titulo):
                dentro = True
                continue
        if dentro:
            salida.append(trozo)
    return "".join(salida)


def aparece(nombre, texto):
    return re.search(r"(?<![\w.])" + re.escape(nombre) + r"(?![\w.])", texto) is not None


def consultas(fabric):
    res = {}
    for pq in sorted(fabric.glob("*.Dataflow/mashup.pq")):
        nombres = [n[2:-1] if n.startswith('#"') else n for n in CONSULTA.findall(pq.read_text(encoding="utf-8"))]
        res[pq.parent.name.removesuffix(".Dataflow")] = [n for n in nombres if not OCULTAS.search(n)]
    return res


def faltan_consultas(fabric, doc):
    bloque = seccion(doc, "Consultas por dataflow")
    faltan = []
    for df, nombres in consultas(fabric).items():
        propio = seccion(bloque, df, "### ") + "\n".join(
            l for l in bloque.splitlines() if l.startswith(f"| {df} |")
        )
        faltan += [f"{df}: {n}" for n in nombres if not aparece(n, propio)]
    return faltan


def faltan_tablas(fabric, doc):
    bloque = seccion(doc, "Lectores por tabla")
    filas = (fabric / "lakehouse" / "esquema.tsv").read_text(encoding="utf-8").splitlines()[1:]
    tablas = sorted({".".join(f.split("\t")[:2]) for f in filas if f.strip()})
    return [t for t in tablas if not aparece(t, bloque)]


def tipos_no_contemplados(fabric, doc):
    bloque = seccion(doc, "Tipos de item contemplados")
    tipos = {p.suffix[1:] if p.suffix else p.name for p in fabric.iterdir() if p.is_dir()}
    return sorted(t for t in tipos if t not in bloque)


def test_repositorio_cubierto():
    doc = LINAJE.read_text(encoding="utf-8")
    assert faltan_consultas(FABRIC, doc) == []
    assert faltan_tablas(FABRIC, doc) == []
    assert tipos_no_contemplados(FABRIC, doc) == []


def copia(tmp_path):
    destino = tmp_path / "fabric"
    shutil.copytree(FABRIC, destino, ignore=shutil.ignore_patterns("*.Report", "*.SemanticModel"))
    return destino


def test_detecta_consulta_nueva(tmp_path):
    fabric = copia(tmp_path)
    pq = fabric / "TRANS_Gold.Dataflow" / "mashup.pq"
    pq.write_text(pq.read_text(encoding="utf-8") + '\nshared #"Consulta nueva" = let\n  a = 1\nin\n  a;\n', encoding="utf-8")
    assert faltan_consultas(fabric, LINAJE.read_text(encoding="utf-8")) == ["TRANS_Gold: Consulta nueva"]


def test_consulta_de_otro_dataflow_no_cuenta(tmp_path):
    fabric = copia(tmp_path)
    pq = fabric / "Seguridad_CDC.Dataflow" / "mashup.pq"
    pq.write_text(pq.read_text(encoding="utf-8") + "\nshared Fact_Actuals = let\n  a = 1\nin\n  a;\n", encoding="utf-8")
    assert faltan_consultas(fabric, LINAJE.read_text(encoding="utf-8")) == ["Seguridad_CDC: Fact_Actuals"]


def test_detecta_tabla_nueva(tmp_path):
    fabric = copia(tmp_path)
    tsv = fabric / "lakehouse" / "esquema.tsv"
    tsv.write_text(tsv.read_text(encoding="utf-8") + "300\tFact_Nueva\tId\t1\tint\tYES\t\t\t\n", encoding="utf-8")
    assert faltan_tablas(fabric, LINAJE.read_text(encoding="utf-8")) == ["300.Fact_Nueva"]


def test_detecta_tipo_de_item_nuevo(tmp_path):
    fabric = copia(tmp_path)
    (fabric / "Almacen.Warehouse").mkdir()
    (fabric / "suelta").mkdir()
    assert tipos_no_contemplados(fabric, LINAJE.read_text(encoding="utf-8")) == ["Warehouse", "suelta"]
