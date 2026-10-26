"""Exporta las definiciones de los items del workspace de Fabric a reporting-financiero/fabric/.

Solo lectura: lista los items y llama a getDefinition. No ejecuta ni modifica nada en Fabric.
Requisito: Azure CLI con la cuenta de Tinkle por defecto
(az account set --subscription 74ab7d37-cd81-40fd-82e4-cd9c35f4345a).

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/exportar_fabric.py

Cada item se escribe en fabric/<Nombre>.<Tipo>/ con las mismas rutas que da la API
(el formato de la integración con git de Fabric). Las carpetas de los tipos exportados
se regeneran enteras en cada ejecución.
"""

import base64
import json
import pathlib
import shutil
import subprocess
import sys
import time
import urllib.error
import urllib.request

WORKSPACE_ID = "b31820dc-4b4f-4696-9a96-bbee438e9306"
TENANT_ID = "74ab7d37-cd81-40fd-82e4-cd9c35f4345a"
API = "https://api.fabric.microsoft.com/v1"

# Tipo de item y formato pedido a getDefinition (None = formato por defecto).
TIPOS = {
    "SemanticModel": "TMDL",
    "Report": "PBIR",
    "Dataflow": None,
    "DataPipeline": None,
    "Notebook": "ipynb",
}
# Las UDF no se exportan: su código lleva un secreto incrustado (ver CLAUDE.md, reglas del cliente).
EXCLUIDOS = {"UserDataFunction"}

DESTINO = pathlib.Path(__file__).resolve().parents[1] / "fabric"


def token():
    cuenta = subprocess.run(
        "az account show --query tenantId -o tsv",
        capture_output=True, text=True, shell=True, check=True,
    ).stdout.strip()
    if cuenta != TENANT_ID:
        sys.exit("Azure CLI no apunta al tenant de Tinkle. Ejecuta: az account set --subscription " + TENANT_ID)
    return subprocess.run(
        "az account get-access-token --resource https://api.fabric.microsoft.com --query accessToken -o tsv",
        capture_output=True, text=True, shell=True, check=True,
    ).stdout.strip()


def peticion(metodo, url, tok, cuerpo=None):
    datos = json.dumps(cuerpo).encode() if cuerpo is not None else None
    req = urllib.request.Request(url, data=datos, method=metodo)
    req.add_header("Authorization", "Bearer " + tok)
    if datos is not None:
        req.add_header("Content-Type", "application/json")
    with urllib.request.urlopen(req) as resp:
        texto = resp.read().decode("utf-8")
        return resp.status, resp.headers, (json.loads(texto) if texto else None)


def definicion(item, tok):
    url = f"{API}/workspaces/{WORKSPACE_ID}/items/{item['id']}/getDefinition"
    formato = TIPOS[item["type"]]
    if formato:
        url += "?format=" + formato
    estado, cabeceras, cuerpo = peticion("POST", url, tok)
    if estado == 200:
        return cuerpo["definition"]
    operacion = cabeceras["x-ms-operation-id"]
    for _ in range(60):
        time.sleep(int(cabeceras.get("Retry-After", 3)))
        _, cabeceras_op, estado_op = peticion("GET", f"{API}/operations/{operacion}", tok)
        if estado_op["status"] == "Succeeded":
            return peticion("GET", f"{API}/operations/{operacion}/result", tok)[2]["definition"]
        if estado_op["status"] == "Failed":
            raise RuntimeError(json.dumps(estado_op.get("error")))
    raise TimeoutError(operacion)


def main():
    tok = token()
    items = peticion("GET", f"{API}/workspaces/{WORKSPACE_ID}/items", tok)[2]["value"]
    for tipo in TIPOS:
        for carpeta in DESTINO.glob(f"*.{tipo}"):
            shutil.rmtree(carpeta)
    exportados = 0
    for item in sorted(items, key=lambda i: (i["type"], i["displayName"])):
        if item["type"] in EXCLUIDOS or item["type"] not in TIPOS:
            continue
        nombre = f"{item['displayName']}.{item['type']}"
        try:
            partes = definicion(item, tok)["parts"]
        except (urllib.error.HTTPError, RuntimeError, TimeoutError) as error:
            print("ERROR", nombre.encode("ascii", "replace").decode(), error)
            continue
        for parte in partes:
            ruta = DESTINO / nombre / parte["path"]
            ruta.parent.mkdir(parents=True, exist_ok=True)
            ruta.write_bytes(base64.b64decode(parte["payload"]))
        exportados += 1
        print("OK", nombre.encode("ascii", "replace").decode(), len(partes), "ficheros")
    print("Items exportados:", exportados)


if __name__ == "__main__":
    main()
