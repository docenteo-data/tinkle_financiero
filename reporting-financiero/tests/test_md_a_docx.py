"""Test del conversor de Markdown a Word (scripts/md_a_docx.py).

Modos de fallo cubiertos:
- El .docx sale como plantilla (.dotx) y Word no lo abre como documento.
- El título no llega a la portada ni al encabezado (propiedad Título del documento).
- Se usan formatos a mano en lugar de los estilos de la plantilla.
- La segunda lista numerada continúa la numeración de la primera.
- La tabla de conceptos no se parte por bloques o pierde la columna de pendientes.
- Dos tablas seguidas se funden en una (Word las une si no hay un párrafo entre ellas).
- Una etiqueta de bloque se queda sola al pie de página, separada de su tabla.

Necesita la plantilla de la skill docenteo-design instalada; si no está, se salta.
"""

import glob
import os
import re
import subprocess
import sys
import zipfile
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "md_a_docx.py"
PLANTILLAS = glob.glob(os.path.join(
    os.path.expanduser("~"), ".claude", "plugins", "cache", "docenteo-org-tools", "docenteo-skills",
    "*", "skills", "docenteo-design", "marca", "plantillas", "word", "docenteo-documento.dotx",
))
pytestmark = pytest.mark.skipif(not PLANTILLAS, reason="falta la plantilla de Docenteo")

MD = """# Documento de prueba

- Fecha: 28/10/2026.

## 1. Primer capítulo

Texto con **énfasis** y `código`.

1. Paso uno.
2. Paso dos.

### 1.1 Apartado

<!-- marca que no se pinta -->

#### Subapartado sin número

1. Otro paso uno.

| Nº | Concepto | Qué falta | Prior. | Docenteo tradicional | Docenteo con IA | Tinkle | Pendientes |
|---|---|---|---|---|---|---|---|
| | **Bloque A** | | | | | | |
| 1 | Uno | Algo | 1 | 3 | 1,5 | J 1 | P-001 |
| | **Bloque B** | | | | | | |
| 2 | Dos | Otra cosa | 2 | 4 | 2 | F 1 | P-002 a P-004 |

| Nº | Pregunta pendiente para Tinkle |
|---|---|
| 1 | ¿Pregunta de prueba? |
"""

MD_DOS_TABLAS = """# Dos tablas

## 1. Capítulo

**Etiqueta de bloque**

| A | B |
|---|---|
| 1 | 2 |

| C | D |
|---|---|
| 3 | 4 |
"""


@pytest.fixture(scope="module")
def docx(tmp_path_factory):
    carpeta = tmp_path_factory.mktemp("docx")
    entrada = carpeta / "prueba.md"
    entrada.write_text(MD, encoding="utf-8")
    salida = carpeta / "prueba.docx"
    r = subprocess.run(
        [sys.executable, str(SCRIPT), str(entrada), str(salida), "--titulo", "Título de prueba",
         "--antetitulo", "28 oct 2026 · Cliente"],
        capture_output=True, text=True,
    )
    assert r.returncode == 0, r.stdout + r.stderr
    return zipfile.ZipFile(salida)


def test_es_documento_y_no_plantilla(docx):
    tipos = docx.read("[Content_Types].xml").decode()
    assert "wordprocessingml.document.main+xml" in tipos
    assert "template.main+xml" not in tipos


def test_titulo_en_portada_y_propiedades(docx):
    assert "<dc:title>Título de prueba</dc:title>" in docx.read("docProps/core.xml").decode()
    assert "Título de prueba" in docx.read("word/document.xml").decode()


def test_solo_estilos_de_la_plantilla(docx):
    doc = docx.read("word/document.xml").decode()
    for estilo in ["Heading1", "Heading2", "Heading3", "ListBullet", "ListNumber", "nfasis", "TablaDocenteo", "Nota"]:
        assert f'w:val="{estilo}"' in doc, estilo
    assert "<!--" not in doc and "marca que no se pinta" not in doc
    assert "<w:color " not in doc and "<w:sz " not in doc and "<w:rFonts " not in doc


def test_cada_lista_numerada_reinicia(docx):
    doc = docx.read("word/document.xml").decode()
    numeradas = re.findall(r'<w:pStyle w:val="ListNumber"/><w:numPr><w:ilvl w:val="0"/><w:numId w:val="(\d+)"/>', doc)
    assert len(numeradas) == 3 and len(set(numeradas)) == 2
    numbering = docx.read("word/numbering.xml").decode()
    for n in set(numeradas):
        assert f'<w:num w:numId="{n}">' in numbering and "<w:startOverride w:val=\"1\"/>" in numbering


def test_tabla_de_conceptos_por_bloques_con_pendientes_en_nota(docx):
    doc = docx.read("word/document.xml").decode()
    assert doc.count('<w:tblStyle w:val="TablaDocenteo"/>') == 3  # dos bloques y la tabla de preguntas
    assert "Bloque A" in doc and "Bloque B" in doc
    assert "Pendientes del registro: 1: P-001." in doc
    assert "Pendientes del registro: 2: P-002 a P-004." in doc


def test_tablas_seguidas_no_se_unen_y_etiqueta(tmp_path):
    entrada = tmp_path / "dos.md"
    entrada.write_text(MD_DOS_TABLAS, encoding="utf-8")
    salida = tmp_path / "dos.docx"
    r = subprocess.run([sys.executable, str(SCRIPT), str(entrada), str(salida), "--titulo", "Dos"],
                       capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    doc = zipfile.ZipFile(salida).read("word/document.xml").decode()
    assert "</w:tbl><w:tbl>" not in doc
    assert doc.count("<w:tbl>") == 2
    assert re.search(r'<w:pStyle w:val="Antettulo"/><w:keepNext/></w:pPr><w:r><w:t xml:space="preserve">Etiqueta de bloque', doc)
