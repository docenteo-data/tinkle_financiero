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
        sys.exit("ERROR: fallo en Azure CLI (az " + comando.split()[0] + "). Ejecuta az login.")
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
        sys.exit("ERROR: no se puede leer " + carpeta + " en " + ascii(ref) + ": " + ascii(r.stderr.decode(errors="replace")))
    resultado = {}
    with tarfile.open(fileobj=io.BytesIO(r.stdout)) as tar:
        for miembro in tar.getmembers():
            if miembro.isfile():
                ruta = miembro.name[len(carpeta) + 1:]
                resultado[ruta] = tar.extractfile(miembro).read()
    return resultado


def solo_items(ficheros, carpetas=None):
    """Filtra {ruta: bytes} a las carpetas de items exportables (o a las indicadas)."""
    resultado = {}
    for ruta, contenido in ficheros.items():
        carpeta = ruta.split("/", 1)[0]
        if carpetas is not None:
            if carpeta in carpetas:
                resultado[ruta] = contenido
        elif separar_item(carpeta)[1] in FORMATOS:
            resultado[ruta] = contenido
    return resultado


def comparar(fabric, repo):
    """Compara dos {ruta: bytes}. Devuelve (nuevos en Fabric, cambiados, borrados en Fabric)."""
    nuevos = sorted(set(fabric) - set(repo))
    borrados = sorted(set(repo) - set(fabric))
    cambiados = sorted(r for r in set(fabric) & set(repo) if fabric[r] != repo[r])
    return nuevos, cambiados, borrados


# --- SQL -------------------------------------------------------------------

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
