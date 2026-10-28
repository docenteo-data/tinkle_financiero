"""Utilidades comunes de los scripts de Fabric: cuenta, API REST, git y comprobaciones.

Ningún script imprime tokens ni los escribe en ficheros: los pide a Azure CLI en cada ejecución.
La salida por consola va en ASCII (la consola de Windows es cp1252).
"""

import base64
import io
import json
import re
import subprocess
import sys
import tarfile
import time
import urllib.error
import urllib.request
from pathlib import Path

WORKSPACE_ID = "b31820dc-4b4f-4696-9a96-bbee438e9306"
TENANT_ID = "74ab7d37-cd81-40fd-82e4-cd9c35f4345a"
CUENTA = "reporting@likuit.com"
API = "https://api.fabric.microsoft.com/v1"
SQL_SERVIDOR = "g562w5ebzx6ubaxezwodl5buli-3qqbrm2pjolenguwxpxehdutay.datawarehouse.fabric.microsoft.com"
SQL_BASE_DATOS = "lh_tinkle_financiero"

RAIZ_REPO = Path(__file__).resolve().parents[2]
CARPETA_FABRIC = "reporting-financiero/fabric"

# Tipos que se exportan y publican, con el formato de definición que se pide a la API.
# Las User Data Functions no están: su código lleva un secreto incrustado.
FORMATOS = {
    "SemanticModel": "TMDL",
    "Report": "PBIR",
    "Dataflow": None,
    "DataPipeline": None,
    "Notebook": "ipynb",
}

# Items que Power BI crea solo al abrir las métricas de uso de un informe: no son parte de la
# solución y la API no permite exportarlos.
ITEMS_DE_SISTEMA = {"Report Usage Metrics Report", "Report Usage Metrics Model", "Usage Metrics Report"}


def es_exportable(item):
    return item["type"] in FORMATOS and item["displayName"] not in ITEMS_DE_SISTEMA


# Ficheros que la API devuelve pero que no forman parte de la definición que se publica.
NO_PUBLICABLES = {".platform"}

ESCRITURA_SQL = {
    "INSERT", "UPDATE", "DELETE", "MERGE", "DROP", "ALTER", "CREATE", "TRUNCATE",
    "EXEC", "EXECUTE", "GRANT", "REVOKE", "DENY", "INTO", "BULK", "DBCC", "BACKUP", "RESTORE",
}


def ascii(texto):
    return str(texto).encode("ascii", "replace").decode()


# --- Cuenta y tokens -------------------------------------------------------

def _az(comando):
    r = subprocess.run("az " + comando, capture_output=True, text=True, shell=True)
    if r.returncode != 0:
        print("ERROR: fallo en Azure CLI (az " + comando.split()[0] + "). Ejecuta az login.")
        sys.exit(2)
    return r.stdout.strip()


def comprobar_cuenta():
    """Para el script con código 2 si Azure CLI no está en la cuenta de Tinkle."""
    tenant, usuario = _az("account show --query \"[tenantId, user.name]\" -o tsv").split()
    if tenant != TENANT_ID:
        print("ERROR: Azure CLI apunta a la cuenta " + ascii(usuario) + ", no a la de Tinkle.")
        print("Ejecuta: az account set --subscription " + TENANT_ID)
        sys.exit(2)
    return usuario


def token(recurso="https://api.fabric.microsoft.com"):
    return _az("account get-access-token --resource " + recurso + " --query accessToken -o tsv")


# --- API REST de Fabric ----------------------------------------------------

def peticion(metodo, url, tok, cuerpo=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(url, data=datos, method=metodo)
    req.add_header("Authorization", "Bearer " + tok)
    if datos is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        texto = resp.read().decode("utf-8")
        return resp.status, resp.headers, (json.loads(texto) if texto else None)


def esperar_operacion(cabeceras, tok, con_resultado):
    operacion = cabeceras["x-ms-operation-id"]
    espera = int(cabeceras.get("Retry-After", 3))
    for _ in range(120):
        time.sleep(espera)
        _, _, estado = peticion("GET", f"{API}/operations/{operacion}", tok)
        if estado["status"] == "Succeeded":
            if con_resultado:
                return peticion("GET", f"{API}/operations/{operacion}/result", tok)[2]
            return None
        if estado["status"] == "Failed":
            raise RuntimeError(json.dumps(estado.get("error")))
    raise TimeoutError(operacion)


def items(tok):
    return peticion("GET", f"{API}/workspaces/{WORKSPACE_ID}/items", tok)[2]["value"]


def nombre_carpeta(item):
    return f"{item['displayName']}.{item['type']}"


def separar_item(carpeta):
    nombre, _, tipo = carpeta.rpartition(".")
    return nombre, tipo


def descargar_definicion(item, tok):
    """Devuelve {ruta: bytes} con la definición actual del item en Fabric."""
    url = f"{API}/workspaces/{WORKSPACE_ID}/items/{item['id']}/getDefinition"
    formato = FORMATOS[item["type"]]
    if formato:
        url += "?format=" + formato
    estado, cabeceras, cuerpo = peticion("POST", url, tok)
    if estado != 200:
        cuerpo = esperar_operacion(cabeceras, tok, con_resultado=True)
    return {p["path"]: base64.b64decode(p["payload"]) for p in cuerpo["definition"]["parts"]}


def partes_para_publicar(ficheros):
    return [
        {"path": ruta, "payload": base64.b64encode(contenido).decode(), "payloadType": "InlineBase64"}
        for ruta, contenido in sorted(ficheros.items())
        if ruta not in NO_PUBLICABLES
    ]


def publicar_definicion(item, ficheros, tok):
    definicion = {"parts": partes_para_publicar(ficheros)}
    formato = FORMATOS[item["type"]]
    if formato:
        definicion["format"] = formato
    url = f"{API}/workspaces/{WORKSPACE_ID}/items/{item['id']}/updateDefinition"
    estado, cabeceras, _ = peticion("POST", url, tok, {"definition": definicion})
    if estado == 202:
        esperar_operacion(cabeceras, tok, con_resultado=False)


# --- Git -------------------------------------------------------------------

def ficheros_en_git(ref, carpeta=CARPETA_FABRIC):
    """Devuelve {ruta relativa a carpeta: bytes} tal como están en el commit ref."""
    r = subprocess.run(
        ["git", "-c", "core.autocrlf=false", "archive", "--format=tar", ref, "--", carpeta],
        cwd=RAIZ_REPO, capture_output=True,
    )
    if r.returncode != 0:
        print("ERROR: no se puede leer " + carpeta + " en " + ascii(ref) + ": " + ascii(r.stderr.decode(errors="replace")))
        sys.exit(2)
    resultado = {}
    with tarfile.open(fileobj=io.BytesIO(r.stdout)) as tar:
        for miembro in tar.getmembers():
            if miembro.isfile():
                ruta = miembro.name[len(carpeta) + 1:]
                resultado[ruta] = tar.extractfile(miembro).read()
    return resultado


def solo_items(ficheros, carpetas=None):
    """Filtra {ruta: bytes} a lo que se exporta de Fabric (o a las carpetas indicadas).

    Se exportan las carpetas de items y las del lakehouse (vistas y esquema); temas/ es manual.
    """
    resultado = {}
    for ruta, contenido in ficheros.items():
        carpeta = ruta.split("/", 1)[0]
        if carpetas is not None:
            if carpeta in carpetas:
                resultado[ruta] = contenido
        elif separar_item(carpeta)[1] in FORMATOS or carpeta in CARPETAS_LAKEHOUSE:
            resultado[ruta] = contenido
    return resultado


def comparar(fabric, repo):
    """Compara dos {ruta: bytes}. Devuelve (nuevos en Fabric, cambiados, borrados en Fabric)."""
    nuevos = sorted(set(fabric) - set(repo))
    borrados = sorted(set(repo) - set(fabric))
    cambiados = sorted(r for r in set(fabric) & set(repo) if fabric[r] != repo[r])
    return nuevos, cambiados, borrados


# --- SQL -------------------------------------------------------------------

# Carpetas de fabric/ que salen del SQL endpoint del lakehouse (vistas y esquema de columnas).
CARPETAS_LAKEHOUSE = {"sql", "lakehouse"}
COLUMNAS_ESQUEMA = ["esquema", "tabla", "columna", "posicion", "tipo", "nulable", "longitud", "precision", "escala"]

CONSULTA_VISTAS = """
SELECT s.name, o.name, m.definition
FROM sys.sql_modules m
JOIN sys.objects o ON o.object_id = m.object_id
JOIN sys.schemas s ON s.schema_id = o.schema_id
WHERE o.type = 'V' AND s.name IN ('100', '200', '300')
ORDER BY 1, 2
"""

CONSULTA_COLUMNAS = """
SELECT c.TABLE_SCHEMA, c.TABLE_NAME, c.COLUMN_NAME, c.ORDINAL_POSITION, c.DATA_TYPE, c.IS_NULLABLE,
       c.CHARACTER_MAXIMUM_LENGTH, c.NUMERIC_PRECISION, c.NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS c
JOIN INFORMATION_SCHEMA.TABLES t ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
WHERE c.TABLE_SCHEMA IN ('100', '200', '300') AND t.TABLE_TYPE = 'BASE TABLE'
ORDER BY 1, 2, 4
"""


def conectar_sql():
    import struct

    import mssql_python

    tok = token("https://database.windows.net/").encode("utf-16-le")
    cadena = f"Server={SQL_SERVIDOR};Database={SQL_BASE_DATOS};Encrypt=yes"
    return mssql_python.connect(cadena, attrs_before={1256: struct.pack("<i", len(tok)) + tok})


def ficheros_sql(vistas, columnas):
    """Convierte las filas de CONSULTA_VISTAS y CONSULTA_COLUMNAS en {ruta: bytes} de fabric/."""
    ficheros = {f"sql/{esquema}.{vista}.sql": definicion.encode("utf-8") for esquema, vista, definicion in vistas}
    lineas = ["\t".join(COLUMNAS_ESQUEMA)]
    lineas += ["\t".join("" if v is None else str(v) for v in fila) for fila in columnas]
    ficheros["lakehouse/esquema.tsv"] = ("\n".join(lineas) + "\n").encode("utf-8")
    return ficheros


def descargar_sql():
    con = conectar_sql()
    cursor = con.cursor()
    cursor.execute(CONSULTA_VISTAS)
    vistas = cursor.fetchall()
    cursor.execute(CONSULTA_COLUMNAS)
    columnas = cursor.fetchall()
    con.close()
    return ficheros_sql(vistas, columnas)

def es_consulta_de_lectura(sql):
    """True si la sentencia empieza por SELECT o WITH y no contiene ninguna palabra de escritura.

    Antes de buscar se quitan comentarios, textos entre comillas y nombres entre corchetes,
    para que una columna o un literal no cuenten como palabra clave.
    """
    limpio = re.sub(r"--[^\n]*|/\*.*?\*/", " ", sql, flags=re.S)
    limpio = re.sub(r"'(?:[^']|'')*'|\[[^\]]*\]|\"[^\"]*\"", " ", limpio)
    palabras = [p.upper() for p in re.findall(r"[A-Za-z_][A-Za-z0-9_]*", limpio)]
    if not palabras or palabras[0] not in {"SELECT", "WITH"}:
        return False
    return not any(p in ESCRITURA_SQL for p in palabras)
