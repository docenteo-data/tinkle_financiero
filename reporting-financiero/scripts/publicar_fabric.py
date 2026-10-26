"""Publica en Fabric la definición de uno o varios items tal como está en un commit del repositorio.

Sirve para el flujo B (cambio preparado en el repo) y para el rollback (publicar un commit anterior).
Escribe en el workspace del cliente, que no tiene entorno de pruebas: lo ejecuta una persona del
equipo, o el agente solo con su confirmación explícita en ese momento.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/publicar_fabric.py "Financial Model.SemanticModel" --ref reporting-financiero
        Simulación: comprueba la cuenta y que Fabric coincide con main en esos items, y dice qué publicaría.
    python reporting-financiero/scripts/publicar_fabric.py "Financial Model.SemanticModel" --ref reporting-financiero --confirmar
        Publica.
    python reporting-financiero/scripts/publicar_fabric.py "TRANS_Gold.Dataflow" --ref <commit anterior> --confirmar
        Rollback de un item a un commit anterior.

--ref     commit, rama o etiqueta de donde se leen las definiciones (por defecto HEAD). Se lee de git,
          no de la carpeta de trabajo: lo que no tenga commit no se publica.
--base    referencia con la que Fabric debe coincidir antes de publicar (por defecto main). Si no
          coincide, alguien ha cambiado Fabric sin pasar al repo y publicar lo pisaría: el script para.
--forzar  publica aunque Fabric no coincida con --base. Solo con decisión explícita de la persona.

Solo actualiza items que ya existen; no crea ni borra items. Las UDF no se publican.
Códigos de salida: 0 publicado o simulación correcta, 1 Fabric no coincide con --base, 2 error.
"""

import argparse
import sys
import urllib.error

import fabric_comun as fc


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("items", nargs="+", help='carpetas de fabric/, por ejemplo "TRANS_Gold.Dataflow"')
    parser.add_argument("--ref", default="HEAD")
    parser.add_argument("--base", default="main")
    parser.add_argument("--confirmar", action="store_true", help="publica de verdad (sin esto, simulación)")
    parser.add_argument("--forzar", action="store_true", help="publica aunque Fabric no coincida con --base")
    args = parser.parse_args()

    for carpeta in args.items:
        if fc.separar_item(carpeta)[1] not in fc.FORMATOS:
            print("ERROR: tipo no publicable:", fc.ascii(carpeta))
            return 2

    usuario = fc.comprobar_cuenta()
    tok = fc.token()
    en_fabric = {fc.nombre_carpeta(i): i for i in fc.items(tok)}
    faltan = [c for c in args.items if c not in en_fabric]
    if faltan:
        print("ERROR: no existen en Fabric (este script no crea items):", fc.ascii(", ".join(faltan)))
        return 2

    a_publicar = fc.solo_items(fc.ficheros_en_git(args.ref), set(args.items))
    base = fc.solo_items(fc.ficheros_en_git(args.base), set(args.items))
    for carpeta in args.items:
        if not any(r.startswith(carpeta + "/") for r in a_publicar):
            print("ERROR:", fc.ascii(carpeta), "no está en", fc.ascii(args.ref))
            return 2

    # Fabric tiene que estar como en --base: si no, publicar perdería cambios hechos en Fabric.
    actual = {}
    try:
        for carpeta in args.items:
            for ruta, contenido in fc.descargar_definicion(en_fabric[carpeta], tok).items():
                actual[carpeta + "/" + ruta] = contenido
    except (urllib.error.HTTPError, RuntimeError, TimeoutError) as error:
        print("ERROR al leer Fabric:", fc.ascii(error))
        return 2
    nuevos, cambiados, borrados = fc.comparar(actual, base)
    if nuevos or cambiados or borrados:
        for ruta in nuevos + cambiados + borrados:
            print("FABRIC DISTINTO DE", fc.ascii(args.base) + ":", fc.ascii(ruta))
        if not args.forzar:
            print("Fabric ha cambiado respecto a " + fc.ascii(args.base) + ". Exporta, integra esos cambios y repite.")
            return 1
        print("AVISO: --forzar; los cambios anteriores se pierden en Fabric.")

    for carpeta in args.items:
        ficheros = {r[len(carpeta) + 1:]: c for r, c in a_publicar.items() if r.startswith(carpeta + "/")}
        cambios = fc.comparar(ficheros, {r[len(carpeta) + 1:]: c for r, c in actual.items() if r.startswith(carpeta + "/")})
        resumen = f"{len(cambios[0])} nuevos, {len(cambios[1])} cambiados, {len(cambios[2])} quitados"
        if not args.confirmar:
            print("SIMULACION", fc.ascii(carpeta), "desde", fc.ascii(args.ref) + ":", resumen)
            continue
        try:
            fc.publicar_definicion(en_fabric[carpeta], ficheros, tok)
        except (urllib.error.HTTPError, RuntimeError, TimeoutError) as error:
            print("ERROR al publicar", fc.ascii(carpeta) + ":", fc.ascii(error))
            return 2
        print("PUBLICADO", fc.ascii(carpeta), "desde", fc.ascii(args.ref), "por", fc.ascii(usuario) + ":", resumen)

    if not args.confirmar:
        print("Simulación: no se ha publicado nada. Repite con --confirmar para publicar.")
    else:
        print("Ahora exporta (exportar_fabric.py), revisa git diff y haz commit.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
