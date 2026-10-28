"""Test del generador del anexo de pendientes (scripts/anexo_pendientes.py).

Modos de fallo cubiertos:
- Algún punto del registro no aparece en el anexo, o aparece en dos conceptos.
- Una referencia técnica (S, O, M, D, N) o una pregunta de la tabla de conceptos queda sin explicar.
- Volver a ejecutarlo duplica el anexo en lugar de reemplazarlo.
"""

import re
import shutil
import subprocess
import sys
from pathlib import Path

PROYECTO = Path(__file__).resolve().parents[1]
SCRIPT = PROYECTO / "scripts" / "anexo_pendientes.py"
AUDITORIA = PROYECTO / "docs" / "auditoria" / "20261028-auditoria-general.md"


def ejecutar(ruta):
    r = subprocess.run([sys.executable, str(SCRIPT), str(ruta)], capture_output=True, text=True)
    assert r.returncode == 0, r.stdout + r.stderr
    return ruta.read_text(encoding="utf-8")


def anexo(texto):
    return texto.split("<!-- anexo:inicio -->", 1)[1].split("<!-- anexo:fin -->", 1)[0]


def test_todos_los_puntos_una_vez(tmp_path):
    copia = tmp_path / "auditoria.md"
    shutil.copy(AUDITORIA, copia)
    ids = re.findall(r"^\| P-(\d{3}) \|", anexo(ejecutar(copia)), re.M)
    assert sorted(map(int, ids)) == list(range(1, 227))


def test_referencias_tecnicas_y_preguntas_explicadas(tmp_path):
    copia = tmp_path / "auditoria.md"
    shutil.copy(AUDITORIA, copia)
    a = anexo(ejecutar(copia))
    for ident in ["S1", "S6", "O1", "O7", "O9", "M9", "N1", "N10"]:
        assert re.search(rf"^\| {ident} \| (Alta|Media|Baja) \|", a, re.M), ident
    preguntas = re.findall(r"^\| (\d+) \| [^|]+\|$", a, re.M)
    assert sorted(set(map(int, preguntas))) == list(range(1, 16))


def test_sin_rayas_ni_flechas(tmp_path):
    copia = tmp_path / "auditoria.md"
    shutil.copy(AUDITORIA, copia)
    a = anexo(ejecutar(copia))
    assert "—" not in a and "→" not in a


def test_idempotente(tmp_path):
    copia = tmp_path / "auditoria.md"
    shutil.copy(AUDITORIA, copia)
    primera = ejecutar(copia)
    segunda = ejecutar(copia)
    assert primera == segunda
    assert segunda.count("<!-- anexo:inicio -->") == 1
