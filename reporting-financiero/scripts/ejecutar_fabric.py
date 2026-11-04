"""Lanza un pipeline de Fabric, espera a que termine y devuelve su estado.

Escribe en el workspace del cliente, que no tiene entorno de pruebas. Por eso --confirmar solo se usa
con la confirmación explícita de la persona justo antes de cada ejecución; sin --confirmar el script
solo simula y no lanza nada.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/ejecutar_fabric.py "Grabar salidas"
        Simulación: comprueba la cuenta y que el pipeline existe en Fabric, y dice qué lanzaría.
    python reporting-financiero/scripts/ejecutar_fabric.py "Grabar salidas" --confirmar
        Lanza el pipeline y espera a que termine.
    python reporting-financiero/scripts/ejecutar_fabric.py "Grabar salidas" --parametro ficheros=Balance --confirmar
        Lanza el pipeline con un parámetro y espera a que termine.

--parametro    parámetro del pipeline con formato clave=valor. Se puede repetir.
--confirmar    lanza de verdad (sin esto, simulación).
--max-minutos  tiempo máximo de espera antes de dar error (por defecto 180). El pipeline puede seguir en marcha.

Códigos de salida: 0 simulación correcta o pipeline Completed, 1 pipeline Failed, Cancelled o Deduped,
2 error.
"""

import argparse
import sys
import urllib.error

import fabric_comun as fc


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("pipeline", help="nombre del pipeline tal como aparece en Fabric")
    parser.add_argument(
        "--parametro",
        action="append",
        default=[],
        metavar="CLAVE=VALOR",
        help="parámetro del pipeline (se puede repetir)",
    )
    parser.add_argument("--confirmar", action="store_true", help="lanza de verdad (sin esto, simulación)")
    parser.add_argument(
        "--max-minutos", type=int, default=180, help="tiempo máximo de espera antes de dar error (por defecto 180)"
    )
    args = parser.parse_args()
    nombre = args.pipeline

    try:
        parametros = fc.leer_parametros(args.parametro)
    except ValueError as error:
        print("ERROR:", fc.ascii(str(error)))
        return 2

    usuario = fc.comprobar_cuenta()
    tok = fc.token()
    item = next((i for i in fc.items(tok) if i.get("displayName") == nombre), None)
    if item is None:
        print("ERROR: no existe en Fabric:", fc.ascii(nombre))
        return 2
    if item.get("type") != "DataPipeline":
        print("ERROR:", fc.ascii(nombre), "no es un pipeline (" + fc.ascii(str(item.get("type"))) + ")")
        return 2

    if not args.confirmar:
        print("SIMULACION: lanzaria el pipeline", fc.ascii(nombre), "con parametros", fc.ascii(str(parametros)))
        print("Simulacion: no se ha lanzado nada. Repite con --confirmar para lanzarlo.")
        return 0

    try:
        url = fc.lanzar_pipeline(item, tok, parametros)
        print("LANZADO", fc.ascii(nombre), "por", fc.ascii(usuario) + "; esperando a que termine...")
        resultado = fc.esperar_job(url, tok, max_segundos=args.max_minutos * 60)
    except TimeoutError:
        print(
            "ERROR:",
            fc.ascii(nombre),
            "sigue en marcha tras",
            args.max_minutos,
            "minutos; revisalo en Fabric",
        )
        return 2
    except (urllib.error.HTTPError, RuntimeError) as error:
        print("ERROR al ejecutar", fc.ascii(nombre) + ":", fc.ascii(str(error)))
        return 2

    estado = resultado.get("status")
    print("TERMINADO", fc.ascii(nombre) + ":", fc.ascii(str(estado)))
    if resultado.get("failureReason"):
        print("MOTIVO:", fc.ascii(str(resultado["failureReason"])))
    return 0 if estado == "Completed" else 1


if __name__ == "__main__":
    sys.exit(main())
