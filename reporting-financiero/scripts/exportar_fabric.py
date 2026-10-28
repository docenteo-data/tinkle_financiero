"""Exporta las definiciones del workspace de Fabric a reporting-financiero/fabric/ o comprueba la sincronía.

Solo lectura sobre Fabric: lista los items y llama a getDefinition.
Requisito: Azure CLI con la cuenta de Tinkle por defecto (el script lo comprueba).

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/exportar_fabric.py
        Escribe fabric/<Nombre>.<Tipo>/ para cada item, fabric/sql/<esquema>.<vista>.sql con las
        vistas del SQL endpoint y fabric/lakehouse/esquema.tsv con las columnas de las capas
        100, 200 y 300. Todo eso se regenera entero; temas/ no se toca.
    python reporting-financiero/scripts/exportar_fabric.py --comprobar [REF]
        No escribe nada. Compara Fabric con fabric/ en el commit REF (por defecto main).

Códigos de salida: 0 sincronizado o exportado, 1 hay diferencias, 2 cuenta incorrecta o error.
"""

import argparse
import shutil
import sys
import urllib.error

import fabric_comun as fc


def descargar_todo(tok):
    ficheros, errores = {}, []
    for item in sorted(fc.items(tok), key=lambda i: (i["type"], i["displayName"])):
        if not fc.es_exportable(item):
            continue
        carpeta = fc.nombre_carpeta(item)
        try:
            for ruta, contenido in fc.descargar_definicion(item, tok).items():
                ficheros[carpeta + "/" + ruta] = contenido
            print("OK", fc.ascii(carpeta))
        except (urllib.error.HTTPError, RuntimeError, TimeoutError) as error:
            errores.append(carpeta)
            print("ERROR", fc.ascii(carpeta), fc.ascii(error))
    try:
        ficheros.update(fc.descargar_sql())
        print("OK vistas y esquema del lakehouse")
    except Exception as error:  # noqa: BLE001 - cualquier fallo del driver SQL impide comparar
        errores.append("lakehouse")
        print("ERROR vistas y esquema del lakehouse", fc.ascii(error))
    return ficheros, errores


def exportar(ficheros):
    destino = fc.RAIZ_REPO / fc.CARPETA_FABRIC
    for tipo in fc.FORMATOS:
        for carpeta in destino.glob(f"*.{tipo}"):
            shutil.rmtree(carpeta)
    for carpeta in fc.CARPETAS_LAKEHOUSE:
        shutil.rmtree(destino / carpeta, ignore_errors=True)
    for ruta, contenido in ficheros.items():
        fichero = destino / ruta
        fichero.parent.mkdir(parents=True, exist_ok=True)
        fichero.write_bytes(contenido)
    print("Ficheros exportados:", len(ficheros))


def comprobar(ficheros, ref):
    repo = fc.solo_items(fc.ficheros_en_git(ref))
    nuevos, cambiados, borrados = fc.comparar(ficheros, repo)
    for etiqueta, lista in (("SOLO EN FABRIC", nuevos), ("DISTINTO", cambiados), ("SOLO EN EL REPO", borrados)):
        for ruta in lista:
            print(etiqueta + ":", fc.ascii(ruta))
    if nuevos or cambiados or borrados:
        print(f"Fabric NO coincide con {fc.ascii(ref)}: {len(nuevos)} solo en Fabric, "
              f"{len(cambiados)} distintos, {len(borrados)} solo en el repo.")
        return 1
    print(f"Fabric coincide con {fc.ascii(ref)}.")
    return 0


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--comprobar", nargs="?", const="main", metavar="REF",
                        help="compara Fabric con fabric/ en el commit REF (por defecto main) sin escribir")
    args = parser.parse_args()

    fc.comprobar_cuenta()
    tok = fc.token()
    ficheros, errores = descargar_todo(tok)
    if errores:
        print("No se han podido leer", len(errores), "items; no se escribe ni se compara nada.")
        return 2
    if args.comprobar:
        return comprobar(ficheros, args.comprobar)
    exportar(ficheros)
    return 0


if __name__ == "__main__":
    sys.exit(main())
