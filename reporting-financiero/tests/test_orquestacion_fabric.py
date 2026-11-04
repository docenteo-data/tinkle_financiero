"""Cobertura de la orquestación de Fabric descrita en vault/adrs/0001-orquestacion-y-vistas-de-salida.md.

Este fichero irá creciendo con una prueba por pipeline: cada pipeline que cambie de
vistas de salida o de orquestación añade aquí sus comprobaciones.

Modos de fallo cubiertos:
- El notebook de ficheros sigue leyendo las vistas del esquema 200 en lugar de las del 300.
- Las vistas de salida no están en el esquema 300, o siguen existiendo las del 200.
"""

from pathlib import Path

PROYECTO = Path(__file__).resolve().parents[1]
FABRIC = PROYECTO / "fabric"
NOTEBOOK = FABRIC / "Generar_txt_Balance_Saldos.Notebook" / "notebook-content.ipynb"


def test_ficheros_leen_vistas_de_300():
    texto = NOTEBOOK.read_text(encoding="utf-8")
    assert "300.vw_Export_Grupo" in texto
    assert "300.vw_Export_Saldos_4_7" in texto
    assert "200.vw_Export" not in texto


def test_vistas_de_salida_en_300():
    assert (FABRIC / "sql" / "300.vw_Export_Grupo.sql").exists()
    assert (FABRIC / "sql" / "300.vw_Export_Saldos_4_7.sql").exists()
    assert not (FABRIC / "sql" / "200.vw_Export_Grupo.sql").exists()
    assert not (FABRIC / "sql" / "200.vw_Export_Saldos_4_7.sql").exists()
