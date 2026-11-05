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
    python reporting-financiero/scripts/exportar_fabric.py --solo "TRANS_Gold.Dataflow" lakehouse
        Exporta (o, con --comprobar, compara) solo esos items. "lakehouse" son las vistas SQL y el
        esquema de columnas. No toca el resto de fabric/ y no lee los demás items de Fabric: sirve
        cuando un modelo semántico no se puede leer (por ejemplo, capacidad saturada) y no se ha
        modificado. Un nombre que no existe en el workspace da código 2.

Códigos de salida: 0 sincronizado o exportado, 1 hay diferencias, 2 cuenta incorrecta o error.
"""

import argparse
import shutil
import sys
import urllib.error

import fabric_comun as fc


def carpetas_solo(solo):
    """Carpetas de fabric/ que cubre --solo (None = todo). "lakehouse" son las vistas SQL y el esquema."""
    if solo is None:
        return None
    carpetas = set(solo)
    if "lakehouse" in carpetas:
        carpetas |= fc.CARPETAS_LAKEHOUSE
    return carpetas


def descargar_todo(tok, carpetas=None):
    ficheros, errores = {}, []
    items = [i for i in fc.items(tok) if fc.es_exportable(i)]
    if carpetas is not None:
        desconocidas = carpetas - {fc.nombre_carpeta(i) for i in items} - fc.CARPETAS_LAKEHOUSE
        if desconocidas:
            print("ERROR: no existen en el workspace:", ", ".join(fc.ascii(c) for c in sorted(desconocidas)))
            sys.exit(2)
    for item in sorted(items, key=lambda i: (i["type"], i["displayName"])):
        carpeta = fc.nombre_carpeta(item)
        if carpetas is not None and carpeta not in carpetas:
            continue
        try:
            for ruta, contenido in fc.descargar_definicion(item, tok).items():
                ficheros[carpeta + "/" + ruta] = contenido
            print("OK", fc.ascii(carpeta))
        except (urllib.error.HTTPError, RuntimeError, TimeoutError) as error:
            errores.append(carpeta)
            print("ERROR", fc.ascii(carpeta), fc.ascii(error))
    if carpetas is None or fc.CARPETAS_LAKEHOUSE & carpetas:
        try:
            ficheros.update(fc.descargar_sql())
            print("OK vistas y esquema del lakehouse")
        except Exception as error:  # noqa: BLE001 - cualquier fallo del driver SQL impide comparar
            errores.append("lakehouse")
            print("ERROR vistas y esquema del lakehouse", fc.ascii(error))
    return ficheros, errores


def exportar(ficheros, carpetas=None):
    """Escribe los ficheros en fabric/. Con carpetas, solo regenera esas y deja el resto como está."""
    destino = fc.RAIZ_REPO / fc.CARPETA_FABRIC
    for tipo in fc.FORMATOS:
        for carpeta in destino.glob(f"*.{tipo}"):
            if carpetas is None or carpeta.name in carpetas:
                shutil.rmtree(carpeta)
    for carpeta in fc.CARPETAS_LAKEHOUSE:
        if carpetas is None or carpeta in carpetas:
            shutil.rmtree(destino / carpeta, ignore_errors=True)
    for ruta, contenido in ficheros.items():
        fichero = destino / ruta
        fichero.parent.mkdir(parents=True, exist_ok=True)
        fichero.write_bytes(contenido)
    print("Ficheros exportados:", len(ficheros))


def comprobar(ficheros, ref, carpetas=None):
    repo = fc.solo_items(fc.ficheros_en_git(ref), carpetas)
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
    parser.add_argument("--solo", nargs="+", metavar="ITEM",
                        help='exporta o comprueba solo estos items (por ejemplo "TRANS_Gold.Dataflow") y "lakehouse" '
                             "(vistas SQL y esquema); el resto de fabric/ no se toca")
    args = parser.parse_args()
    carpetas = carpetas_solo(args.solo)

    fc.comprobar_cuenta()
    tok = fc.token()
    ficheros, errores = descargar_todo(tok, carpetas)
    if errores:
        print("No se han podido leer", len(errores), "items; no se escribe ni se compara nada.")
        return 2
    if args.comprobar:
        return comprobar(ficheros, args.comprobar, carpetas)
    exportar(ficheros, carpetas)
    return 0


if __name__ == "__main__":
    sys.exit(main())
