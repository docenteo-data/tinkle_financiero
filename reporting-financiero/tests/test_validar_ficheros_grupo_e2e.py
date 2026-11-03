"""Test E2E de la validación de los ficheros de Grupo (scripts/validar_ficheros_grupo.py).

Se ejecuta solo con FABRIC_E2E=1, Azure CLI en la cuenta de Tinkle y la carpeta 3.Fuentes de
OneDrive sincronizada (ficheros de marzo de 2026: TXT de Magnitude, aging de clientes y Revenue FT3).

Modos de fallo cubiertos:
- El cálculo de Ageing (tramos de días, corte a 31-03-2026, importe en miles) deja de reproducir
  los importes por sociedad y tramo del TXT de marzo.
- El cálculo de Revenue (medida REAL (Fees & other), acumulado del año, signo invertido, en miles)
  deja de reproducir el total por sociedad del TXT de marzo.
- El informe deja de dar la cobertura del código de cliente Magnitude (líneas reproducidas).

COMM en Revenue tiene una diferencia conocida de 6,82 sin explicar: se marca como xfail.
"""

import os
import re
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "validar_ficheros_grupo.py"
FUENTES = (Path.home() / "OneDrive - Docenteo" / "DOCENTEO - General" / "02.Clientes" / "04.Tinkle"
           / "Reporting financiero" / "3.Fuentes")

pytestmark = pytest.mark.skipif(
    os.environ.get("FABRIC_E2E") != "1" or not FUENTES.exists(),
    reason="requiere FABRIC_E2E=1, acceso a Fabric y la carpeta 3.Fuentes sincronizada",
)


def ejecutar(fichero):
    r = subprocess.run([sys.executable, str(SCRIPT), fichero], capture_output=True, text=True,
                       encoding="utf-8", errors="replace")
    assert r.returncode in (0, 1), r.stdout + r.stderr
    return r


@pytest.fixture(scope="module")
def ageing():
    return ejecutar("ageing")


@pytest.fixture(scope="module")
def revenue():
    return ejecutar("revenue")


def diferencias_por_sociedad(salida):
    return {m.group(1): float(m.group(2))
            for m in re.finditer(r"^SOCIEDAD (ESP\d{3}) .* dif=(-?\d+\.\d+)$", salida, re.M)}


def test_ageing_importes_por_tramo_cuadran(ageing):
    assert ageing.returncode == 0, ageing.stdout
    maxima = float(re.search(r"^TRAMOS combinaciones=\d+ diferencia_maxima=(\d+\.\d+)$", ageing.stdout, re.M).group(1))
    assert maxima < 0.001


def test_ageing_informa_cobertura_de_clientes(ageing):
    assert re.search(r"^CLIENTES lineas_txt=\d+ exactas=\d+", ageing.stdout, re.M)


# Cada línea del TXT va redondeada a 2 decimales: el total por sociedad admite unos céntimos.
TOLERANCIA = 0.05


@pytest.mark.parametrize("sociedad", ["ESP067", "ESP068", "ESP069", "ESP070"])
def test_revenue_total_por_sociedad_cuadra(revenue, sociedad):
    assert abs(diferencias_por_sociedad(revenue.stdout)[sociedad]) < TOLERANCIA


@pytest.mark.xfail(reason="COMM: diferencia conocida de 6,82 (0,24%) pendiente de explicar", strict=True)
def test_revenue_total_comm_cuadra(revenue):
    assert abs(diferencias_por_sociedad(revenue.stdout)["ESP066"]) < TOLERANCIA


def test_revenue_informa_cobertura_de_clientes(revenue):
    assert re.search(r"^CLIENTES lineas_txt=\d+ exactas=\d+", revenue.stdout, re.M)
