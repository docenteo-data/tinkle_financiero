"""Convierte un documento Markdown del proyecto a Word con la plantilla de Docenteo.

Parte de `docenteo-documento.dotx` de la skill docenteo-design (brand-word.md) y solo usa sus
estilos: portada, Heading1 a Heading3, Normal, ListBullet, ListNumber, Antettulo, Nota,
Énfasis Docenteo y Tabla Docenteo. La plantilla se busca en la versión más alta instalada
del plugin docenteo-skills, salvo que se indique con --plantilla.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/md_a_docx.py ENTRADA.md SALIDA.docx \
        --titulo "Auditoría general del proyecto" --subtitulo "..." --antetitulo "28 oct 2026 · Tinkle"

Convenciones del Markdown que entiende:
- La primera línea "# ..." no se pinta (el título va en la portada); lo que haya hasta el primer
  "## " se pinta como "Ficha del documento".
- "## n. Título" es capítulo, "### n.m Título" o "### Título" es apartado (numeración automática)
  y "#### Título" es subapartado sin número. Una línea que solo tiene "**texto**" es una etiqueta
  (estilo Antetítulo). Las líneas de comentario "<!-- ... -->" se ignoran.
- Listas con "- " y "1. ", anidadas de dos en dos espacios; "**texto**" es Énfasis Docenteo.
- Tablas Markdown. Una tabla de 8 columnas cuya cabecera empieza por "Nº" se parte en una tabla
  por bloque (filas con la primera celda vacía) y su última columna pasa a una nota.

Después, revisa el resultado con el verificador de la skill (scripts/comprobar-tokens.sh).
"""

import argparse
import glob
import io
import os
import re
import sys
import zipfile
from xml.sax.saxutils import escape

ANCHO = 9412  # ancho útil de la plantilla en dxa (A4 con márgenes de 22 mm)


def plantilla_por_defecto():
    patron = os.path.join(
        os.path.expanduser("~"), ".claude", "plugins", "cache", "docenteo-org-tools", "docenteo-skills",
        "*", "skills", "docenteo-design", "marca", "plantillas", "word", "docenteo-documento.dotx",
    )
    candidatas = glob.glob(patron)

    def version(ruta):
        partes = ruta.split(os.sep)
        v = partes[partes.index("docenteo-skills") + 1]
        return tuple(int(x) if x.isdigit() else 0 for x in v.split("."))

    if not candidatas:
        print("ERROR: no se encuentra la plantilla de Docenteo; indica --plantilla.")
        sys.exit(2)
    return max(candidatas, key=version)


argumentos = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
argumentos.add_argument("entrada")
argumentos.add_argument("salida")
argumentos.add_argument("--titulo", required=True)
argumentos.add_argument("--subtitulo", default="")
argumentos.add_argument("--antetitulo", default="", help="fecha y cliente, por ejemplo: 28 oct 2026 · Tinkle")
argumentos.add_argument("--plantilla", default=None)
args = argumentos.parse_args()

MD, SALIDA = args.entrada, args.salida
PLANTILLA = args.plantilla or plantilla_por_defecto()
TITULO, SUBTITULO, ANTETITULO = args.titulo, args.subtitulo, args.antetitulo

texto = io.open(MD, encoding="utf-8").read()
plantilla = zipfile.ZipFile(PLANTILLA)
numbering = plantilla.read("word/numbering.xml").decode("utf-8")

# Instancias nuevas de numeración para reiniciar cada lista numerada.
abstract_lista_num = re.search(r'<w:num w:numId="3"[^>]*>\s*<w:abstractNumId w:val="(\d+)"/>', numbering).group(1)
nums_nuevos = []
siguiente_num = [100]


def nueva_numeracion():
    n = siguiente_num[0]
    siguiente_num[0] += 1
    nums_nuevos.append(
        f'<w:num w:numId="{n}"><w:abstractNumId w:val="{abstract_lista_num}"/>'
        f'<w:lvlOverride w:ilvl="0"><w:startOverride w:val="1"/></w:lvlOverride>'
        f'<w:lvlOverride w:ilvl="1"><w:startOverride w:val="1"/></w:lvlOverride></w:num>'
    )
    return n


# --- Texto en línea --------------------------------------------------------

def limpiar(t):
    t = re.sub(r"\[([^\]]+)\]\([^)]+\)", r"\1", t)  # enlaces: solo el texto
    t = t.replace("../../CONTEXT.md", "reporting-financiero/CONTEXT.md").replace("../", "reporting-financiero/docs/")
    return t.replace("`", "")


def runs(t, negrita=False):
    """Devuelve los w:r de un texto con **énfasis**."""
    t = limpiar(t)
    salida = []
    for i, trozo in enumerate(re.split(r"\*\*", t)):
        if not trozo:
            continue
        enfasis = negrita or i % 2 == 1
        rpr = '<w:rPr><w:rStyle w:val="nfasis"/></w:rPr>' if enfasis else ""
        salida.append(f'<w:r>{rpr}<w:t xml:space="preserve">{escape(trozo)}</w:t></w:r>')
    return "".join(salida)


def parrafo(t, estilo=None, ppr_extra="", negrita=False):
    estilo_xml = f'<w:pStyle w:val="{estilo}"/>' if estilo else ""
    return f"<w:p><w:pPr>{estilo_xml}{ppr_extra}</w:pPr>{runs(t, negrita)}</w:p>"


# --- Tablas -----------------------------------------------------------------

NUMERICO = re.compile(r"^\**[\d.,]+\**$|^sin estimar$")


def tabla(filas, anchos=None):
    cab, *cuerpo = filas
    ncol = len(cab)
    if anchos is None:
        largos = [max([len(limpiar(f[c])) for f in cuerpo] + [int(len(cab[c]) * 1.4)]) for c in range(ncol)]
        pesos = [max(8, min(l, 60)) ** 0.8 for l in largos]
        anchos = [int(ANCHO * p / sum(pesos)) for p in pesos]
    anchos[-1] += ANCHO - sum(anchos)
    derecha = [
        all(NUMERICO.match(limpiar(f[c]).strip()) or not f[c].strip() for f in cuerpo) and any(f[c].strip() for f in cuerpo)
        for c in range(ncol)
    ]
    xml = [
        '<w:tbl><w:tblPr><w:tblStyle w:val="TablaDocenteo"/>'
        f'<w:tblW w:w="{ANCHO}" w:type="dxa"/><w:tblLayout w:type="fixed"/>'
        '<w:tblLook w:val="0420" w:firstRow="1" w:lastRow="0" w:firstColumn="0" w:lastColumn="0" w:noHBand="1" w:noVBand="1"/>'
        "</w:tblPr><w:tblGrid>" + "".join(f'<w:gridCol w:w="{a}"/>' for a in anchos) + "</w:tblGrid>"
    ]
    for i, fila in enumerate(filas):
        total = i > 0 and fila[0].strip().startswith("**") or (i > 0 and fila[1].strip().startswith("**Total"))
        xml.append("<w:tr>" + ("<w:trPr><w:tblHeader/><w:cantSplit/></w:trPr>" if i == 0 else "<w:trPr><w:cantSplit/></w:trPr>"))
        for c, celda in enumerate(fila):
            jc = '<w:jc w:val="right"/>' if derecha[c] else ""
            xml.append(
                f'<w:tc><w:tcPr><w:tcW w:w="{anchos[c]}" w:type="dxa"/></w:tcPr>'
                f"<w:p><w:pPr>{jc}</w:pPr>{runs(celda.strip(), negrita=bool(total))}</w:p></w:tc>"
            )
        xml.append("</w:tr>")
    xml.append("</w:tbl>")
    return "".join(xml)


def celdas(linea):
    return [c for c in linea.strip().strip("|").split("|")]


# --- Tabla de conceptos de la sección 1: una tabla por bloque ----------------

def tablas_de_conceptos(filas):
    cab, *cuerpo = filas
    salida = []
    bloque, filas_bloque, notas = None, [], []

    def cerrar():
        if not filas_bloque:
            return
        salida.append(parrafo(bloque, "Heading3"))
        salida.append(tabla(
            [["Nº", "Concepto y qué falta", "Prior.", "Tradicional", "Con IA", "Tinkle"]] + filas_bloque,
            anchos=[450, 3900, 800, 1350, 1000, 1912],
        ))
        salida.append(parrafo("Pendientes del registro: " + "; ".join(notas) + ".", "Nota"))

    for f in cuerpo:
        if not f[0].strip():  # fila de bloque
            cerrar()
            bloque, filas_bloque, notas = f[1].strip().strip("*"), [], []
            continue
        n, concepto, falta, prio, trad, ia, tinkle, pend = [x.strip() for x in f]
        filas_bloque.append([n, f"**{concepto}.** {falta}", prio, trad, ia, tinkle])
        notas.append(f"{n}: {limpiar(pend)}")
    cerrar()
    return "".join(salida)


# --- Recorrido del Markdown -------------------------------------------------

lineas = texto.splitlines()
cuerpo = []
ficha = []
i = 0
num_actual = {}
seccion = ""

# La primera línea es el título; la lista inicial es la ficha del documento.
assert lineas[0].startswith("# ")
i = 1
while i < len(lineas) and not lineas[i].startswith("## "):
    ficha.append(lineas[i])
    i += 1


def lista(bloque_lineas):
    """Convierte un bloque de líneas de lista (con anidamiento por espacios) en párrafos."""
    xml = []
    nums = {}
    for linea in bloque_lineas:
        m = re.match(r"^( *)(- |\d+\. )(.*)$", linea)
        if not m:  # continuación de un elemento (línea sangrada sin marcador)
            if linea.strip():
                xml.append(parrafo(linea.strip(), ppr_extra='<w:ind w:left="567"/>'))
            continue
        nivel = min(len(m.group(1)) // 2, 2)
        numerada = m.group(2).strip().endswith(".")
        if numerada:
            if nivel not in nums:
                nums[nivel] = nueva_numeracion()
            for k in [k for k in nums if k > nivel]:
                del nums[k]
            xml.append(parrafo(
                m.group(3), "ListNumber",
                f'<w:numPr><w:ilvl w:val="{min(nivel, 1)}"/><w:numId w:val="{nums[nivel]}"/></w:numPr>',
            ))
        else:
            for k in [k for k in nums if k >= nivel]:
                del nums[k]
            ppr = f'<w:numPr><w:ilvl w:val="{nivel}"/><w:numId w:val="2"/></w:numPr>' if nivel else ""
            xml.append(parrafo(m.group(3), "ListBullet", ppr))
    return "".join(xml)


def convertir(bloque_lineas):
    xml = []
    j = 0
    while j < len(bloque_lineas):
        l = bloque_lineas[j]
        if not l.strip() or l.startswith("<!--"):
            j += 1
            continue
        if re.match(r"^\*\*[^*]+\*\*$", l.strip()):
            xml.append(parrafo(l.strip().strip("*"), "Antettulo", "<w:keepNext/>"))  # la etiqueta va con su tabla
        elif l.startswith("#### "):
            xml.append(parrafo(l[5:].strip(), "Heading3"))
        elif l.startswith("## "):
            global seccion
            seccion = re.sub(r"^\d+\.\s*", "", l[3:].strip())
            xml.append(parrafo(seccion, "Heading1"))
        elif l.startswith("### "):
            t = l[4:].strip()
            if re.match(r"^\d+\.\d+\s", t):
                xml.append(parrafo(re.sub(r"^\d+\.\d+\s+", "", t), "Heading2"))
            else:
                xml.append(parrafo(t, "Heading2"))
        elif l.startswith("|"):
            if xml and xml[-1].endswith("</w:tbl>"):
                xml.append("<w:p/>")  # Word une dos tablas seguidas si no hay un párrafo entre ellas
            filas = []
            while j < len(bloque_lineas) and bloque_lineas[j].startswith("|"):
                if not re.match(r"^\|[-| ]+\|$", bloque_lineas[j]):
                    filas.append(celdas(bloque_lineas[j]))
                j += 1
            cortas = {"Docenteo tradicional": "Tradicional", "Docenteo con IA": "Con IA",
                      "Total tradicional": "Tradicional", "Total con IA": "Con IA"}
            filas[0] = [cortas.get(c.strip(), c) for c in filas[0]]
            if filas[0][0].strip() == "Nº" and len(filas[0]) == 8:
                xml.append(tablas_de_conceptos(filas))
            elif filas[0][0].strip() == "Nº" and len(filas[0]) >= 3 and filas[0][2].strip().startswith("Tareas"):
                filas[0][2] = "Tareas (jornadas, estimación tradicional)"
                xml.append(tabla(filas, anchos=[450, 1650, 3600, 1350, 850, 1512]))
            elif filas[0][0].strip() == "Fase":
                xml.append(tabla(filas, anchos=[2850, 1200, 1350, 850, 1450, 1712]))
            elif [c.strip() for c in filas[0]] == ["Id", "Tipo", "Descripción", "Responsable", "Estado"]:
                xml.append(tabla(filas, anchos=[750, 950, 3900, 1500, 2312]))
            elif [c.strip() for c in filas[0]] == ["Id", "Prioridad", "Problema", "Situación"]:
                xml.append(tabla(filas, anchos=[600, 1200, 3950, 3662]))
            elif len(filas[0]) == 2 and filas[0][0].strip() == "Nº":
                xml.append(tabla(filas, anchos=[500, 8912]))
            else:
                xml.append(tabla(filas))
            continue
        elif re.match(r"^ *(- |\d+\. )", l):
            bloque = []
            while j < len(bloque_lineas) and (
                re.match(r"^ *(- |\d+\. )", bloque_lineas[j])
                or (bloque_lineas[j].startswith("  ") and bloque_lineas[j].strip())
            ):
                bloque.append(bloque_lineas[j])
                j += 1
            xml.append(lista(bloque))
            continue
        else:
            xml.append(parrafo(l.strip()))
        j += 1
    return "".join(xml)


portada = (
    f'<w:p><w:pPr><w:pStyle w:val="AntettuloPortada"/></w:pPr><w:r><w:t xml:space="preserve">{escape(ANTETITULO)}</w:t></w:r></w:p>'
    '<w:p><w:pPr><w:pStyle w:val="TituloPortada"/></w:pPr><w:sdt><w:sdtPr><w:alias w:val="Título del documento"/>'
    '<w:tag w:val="titulo"/><w:id w:val="1"/><w:dataBinding w:prefixMappings="xmlns:ns0=\'http://purl.org/dc/elements/1.1/\' '
    'xmlns:ns1=\'http://schemas.openxmlformats.org/package/2006/metadata/core-properties\'" '
    'w:xpath="/ns1:coreProperties[1]/ns0:title[1]" w:storeItemID="{6C3C8BC8-F283-45AE-878A-BAB7291924A1}"/><w:text/></w:sdtPr>'
    f'<w:sdtContent><w:r><w:t xml:space="preserve">{escape(TITULO)}</w:t></w:r></w:sdtContent></w:sdt></w:p>'
    f'<w:p><w:pPr><w:pStyle w:val="Subtitle"/></w:pPr><w:r><w:t xml:space="preserve">{escape(SUBTITULO)}</w:t></w:r></w:p>'
    '<w:p><w:pPr><w:spacing w:after="0"/></w:pPr><w:r><w:br w:type="page"/></w:r></w:p>'
)

ficha_xml = parrafo("Ficha del documento", "Antettulo") + convertir(ficha)
cuerpo_xml = convertir(lineas[i:])

doc = plantilla.read("word/document.xml").decode("utf-8")
sect = re.search(r"<w:sectPr>.*?</w:sectPr>", doc, re.S).group(0)
cabecera = doc[: doc.index("<w:body>") + len("<w:body>")]
documento = cabecera + portada + ficha_xml + cuerpo_xml + sect + "</w:body></w:document>"

numbering_nuevo = numbering.replace("</w:numbering>", "".join(nums_nuevos) + "</w:numbering>")

with zipfile.ZipFile(SALIDA, "w", zipfile.ZIP_DEFLATED) as z:
    for item in plantilla.infolist():
        datos = plantilla.read(item.filename)
        if item.filename == "word/document.xml":
            datos = documento.encode("utf-8")
        elif item.filename == "word/numbering.xml":
            datos = numbering_nuevo.encode("utf-8")
        elif item.filename == "[Content_Types].xml":
            datos = datos.replace(
                b"application/vnd.openxmlformats-officedocument.wordprocessingml.template.main+xml",
                b"application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml",
            )
        elif item.filename == "docProps/core.xml":
            datos = re.sub(rb"<dc:title>.*?</dc:title>", f"<dc:title>{escape(TITULO)}</dc:title>".encode("utf-8"), datos)
        z.writestr(item, datos)
print("OK", SALIDA.encode("ascii", "replace").decode())
