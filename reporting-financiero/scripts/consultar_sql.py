"""Consulta de solo lectura al SQL endpoint del lakehouse lh_tinkle_financiero.

Solo admite sentencias que empiezan por SELECT o WITH y no contienen palabras de escritura
(INSERT, UPDATE, DELETE, MERGE, DROP, ALTER, CREATE, EXEC, INTO...). El token lo da Azure CLI
con la cuenta de Tinkle (el script lo comprueba) y no se guarda en ningún sitio.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/consultar_sql.py "SELECT TOP 20 * FROM [300].Dim_Sociedades"
    python reporting-financiero/scripts/consultar_sql.py --fichero consulta.sql --csv reporting-financiero/data/salida.csv

Sin --csv imprime como mucho --max-filas filas (por defecto 50) en ASCII. Con --csv escribe
todas las filas en UTF-8; la ruta debe estar dentro de reporting-financiero/data/, que no se versiona.

Códigos de salida: 0 correcto, 1 error de la consulta, 2 sentencia no permitida o cuenta incorrecta.
"""

import argparse
import csv
import struct
import sys
from pathlib import Path

import mssql_python

import fabric_comun as fc

SQL_COPT_SS_ACCESS_TOKEN = 1256
CARPETA_DATOS = fc.RAIZ_REPO / "reporting-financiero" / "data"


def conectar():
    tok = fc.token("https://database.windows.net/").encode("utf-16-le")
    cadena = f"Server={fc.SQL_SERVIDOR};Database={fc.SQL_BASE_DATOS};Encrypt=yes"
    return mssql_python.connect(cadena, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: struct.pack("<i", len(tok)) + tok})


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("sql", nargs="?", help="sentencia SELECT o WITH")
    parser.add_argument("--fichero", help="lee la sentencia de un fichero .sql")
    parser.add_argument("--csv", help="escribe el resultado completo en este CSV (dentro de reporting-financiero/data/)")
    parser.add_argument("--max-filas", type=int, default=50, help="filas que se imprimen sin --csv")
    args = parser.parse_args()

    sql = Path(args.fichero).read_text(encoding="utf-8") if args.fichero else args.sql
    if not sql or not fc.es_consulta_de_lectura(sql):
        print("ERROR: solo se permiten consultas de lectura (SELECT o WITH, sin escrituras).")
        return 2
    if args.csv and CARPETA_DATOS.resolve() not in Path(args.csv).resolve().parents:
        print("ERROR: el CSV debe ir dentro de reporting-financiero/data/, que no se versiona.")
        return 2
    fc.comprobar_cuenta()

    try:
        con = conectar()
        cursor = con.cursor()
        cursor.execute(sql)
        columnas = [c[0] for c in cursor.description]
        if args.csv:
            filas = cursor.fetchall()
            Path(args.csv).parent.mkdir(parents=True, exist_ok=True)
            with open(args.csv, "w", encoding="utf-8", newline="") as f:
                escritor = csv.writer(f, delimiter=";")
                escritor.writerow(columnas)
                escritor.writerows(filas)
            print("Filas escritas:", len(filas), "en", fc.ascii(args.csv))
        else:
            filas = cursor.fetchmany(args.max_filas + 1)
            print(" | ".join(fc.ascii(c) for c in columnas))
            for fila in filas[:args.max_filas]:
                print(" | ".join(fc.ascii("" if v is None else v) for v in fila))
            if len(filas) > args.max_filas:
                print(f"(hay mas filas; se muestran {args.max_filas}. Usa --csv para el resultado completo)")
        con.close()
    except mssql_python.Error as error:
        print("ERROR en la consulta:", fc.ascii(error))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
