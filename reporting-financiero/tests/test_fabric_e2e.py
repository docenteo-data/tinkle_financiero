"""Test E2E contra el workspace de Fabric (solo lectura).

Se ejecuta solo con FABRIC_E2E=1 y Azure CLI en la cuenta de Tinkle:
    FABRIC_E2E=1 reporting-financiero/.venv/Scripts/python.exe -m pytest reporting-financiero/tests

Comprueba la sincronía de main con Fabric y una consulta SQL real.
"""

import os
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
pytestmark = pytest.mark.skipif(os.environ.get("FABRIC_E2E") != "1", reason="requiere FABRIC_E2E=1 y acceso a Fabric")


def ejecutar(*args):
    return subprocess.run([sys.executable, *args], capture_output=True, text=True, encoding="utf-8", errors="replace")


def test_main_sincronizado_con_fabric():
    r = ejecutar(str(SCRIPTS / "exportar_fabric.py"), "--comprobar", "main")
    assert r.returncode == 0, r.stdout + r.stderr


def test_consulta_sql_de_lectura():
    r = ejecutar(str(SCRIPTS / "consultar_sql.py"),
                 "SELECT TABLE_SCHEMA, COUNT(*) AS n FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = '300' GROUP BY TABLE_SCHEMA")
    assert r.returncode == 0, r.stderr
    assert "300" in r.stdout


def test_consulta_sql_rechaza_escritura():
    r = ejecutar(str(SCRIPTS / "consultar_sql.py"), "DELETE FROM [300].Dim_CDC")
    assert r.returncode == 2
