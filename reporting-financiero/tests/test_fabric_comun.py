"""Tests de la lógica de los scripts de Fabric que no necesita conexión.

Modos de fallo cubiertos:
- La comprobación de sincronía no detecta un fichero nuevo, cambiado o borrado en Fabric.
- La publicación sube el .platform (metadatos) o ficheros de otro item.
- La publicación pide a Fabric un formato distinto del que se exportó.
- El script de SQL deja pasar una sentencia que escribe, aunque vaya detrás de un SELECT.

El test E2E contra Fabric está en test_fabric_e2e.py.
"""

import base64
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))

import fabric_comun as fc  # noqa: E402


def test_comparar_detecta_nuevos_cambiados_y_borrados():
    fabric = {"A.Report/x.json": b"1", "A.Report/nuevo.json": b"n", "B.Dataflow/m.pq": b"igual"}
    repo = {"A.Report/x.json": b"2", "B.Dataflow/m.pq": b"igual", "C.Notebook/c.ipynb": b"c"}
    nuevos, cambiados, borrados = fc.comparar(fabric, repo)
    assert nuevos == ["A.Report/nuevo.json"]
    assert cambiados == ["A.Report/x.json"]
    assert borrados == ["C.Notebook/c.ipynb"]


def test_comparar_sin_diferencias():
    ficheros = {"A.Report/x.json": b"1"}
    assert fc.comparar(ficheros, dict(ficheros)) == ([], [], [])


def test_partes_excluye_platform_y_codifica_en_base64():
    ficheros = {
        ".platform": b"{}",
        "definition/model.tmdl": b"model Model",
        "definition.pbism": b"{\"version\": \"4.0\"}",
    }
    partes = fc.partes_para_publicar(ficheros)
    rutas = sorted(p["path"] for p in partes)
    assert rutas == ["definition.pbism", "definition/model.tmdl"]
    modelo = next(p for p in partes if p["path"] == "definition/model.tmdl")
    assert base64.b64decode(modelo["payload"]) == b"model Model"
    assert modelo["payloadType"] == "InlineBase64"


def test_formato_de_definicion_igual_en_exportar_y_publicar():
    assert fc.FORMATOS["SemanticModel"] == "TMDL"
    assert fc.FORMATOS["Report"] == "PBIR"
    assert fc.FORMATOS["Notebook"] == "ipynb"
    assert fc.FORMATOS["Dataflow"] is None
    assert fc.FORMATOS["DataPipeline"] is None
    assert "UserDataFunction" not in fc.FORMATOS


def test_solo_items_incluye_lo_exportado_del_lakehouse_y_excluye_lo_manual():
    ficheros = {
        "TRANS_Gold.Dataflow/mashup.pq": b"m",
        "sql/200.vw_Export_Grupo.sql": b"v",
        "lakehouse/esquema.tsv": b"t",
        "temas/TemaTinkle.json": b"j",
        "Ejecucion.UserDataFunction/function_app.py": b"secreto",
    }
    assert sorted(fc.solo_items(ficheros)) == [
        "TRANS_Gold.Dataflow/mashup.pq", "lakehouse/esquema.tsv", "sql/200.vw_Export_Grupo.sql",
    ]


def test_ficheros_sql_de_vistas_y_esquema():
    vistas = [("200", "vw_Export_Grupo", "CREATE VIEW x AS SELECT 1")]
    columnas = [("300", "Dim_CDC", "Nombre", 1, "varchar", "YES", 8000, None, None)]
    ficheros = fc.ficheros_sql(vistas, columnas)
    assert ficheros["sql/200.vw_Export_Grupo.sql"] == "CREATE VIEW x AS SELECT 1".encode("utf-8")
    tsv = ficheros["lakehouse/esquema.tsv"].decode("utf-8").splitlines()
    assert tsv[0].split("\t")[:3] == ["esquema", "tabla", "columna"]
    assert tsv[1] == "300\tDim_CDC\tNombre\t1\tvarchar\tYES\t8000\t\t"


def test_separar_item():
    assert fc.separar_item("Financial Model.SemanticModel") == ("Financial Model", "SemanticModel")
    assert fc.separar_item("Checklist (Oracle).Report") == ("Checklist (Oracle)", "Report")


def test_consulta_de_lectura_acepta_select_y_with():
    assert fc.es_consulta_de_lectura("SELECT TOP 10 * FROM [300].Fact_Actuals")
    assert fc.es_consulta_de_lectura("  with t as (select 1 as a) select a from t")


def test_consulta_de_lectura_rechaza_escrituras():
    for sql in [
        "DELETE FROM [300].Fact_Actuals",
        "SELECT 1; DROP TABLE [300].Dim_CDC",
        "UPDATE [300].Dim_CDC SET Nombre = 'x'",
        "INSERT INTO t SELECT 1",
        "EXEC sp_who",
        "SELECT * INTO nueva FROM [300].Dim_CDC",
        "WITH t AS (SELECT 1 AS a) MERGE INTO x USING t ON 1=1 WHEN MATCHED THEN DELETE;",
        "CREATE VIEW v AS SELECT 1",
    ]:
        assert not fc.es_consulta_de_lectura(sql), sql


def test_consulta_de_lectura_ignora_palabras_dentro_de_textos_y_nombres():
    assert fc.es_consulta_de_lectura("SELECT * FROM [300].Dim_Report_Line WHERE Etiqueta = 'Update fees'")
    assert fc.es_consulta_de_lectura("SELECT [Created], Deleted_flag FROM [200].MMS")
