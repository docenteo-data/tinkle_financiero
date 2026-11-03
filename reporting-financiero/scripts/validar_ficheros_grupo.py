"""Valida los ficheros de Grupo de Ageing y Revenue contra los TXT de Magnitude de marzo de 2026.

Reproduce cada fichero desde las fuentes y lo compara con el TXT real:
- ageing: importes por sociedad y tramo desde el aging de clientes del 31-03-2026 (cifra de
  control) y, aparte, el código de cliente Magnitude cruzando factura -> MMS -> Revenue FT3.
- revenue: total por sociedad desde Fact_Actuals con la medida REAL (Fees & other) (cifra de
  control) y, aparte, el código de cliente Magnitude cruzando Dim_Clientes -> Revenue FT3.

El código de cliente es informativo: el Excel Revenue FT3 no es el maestro de Magnitude.

Uso, desde la raíz del repositorio:
    python reporting-financiero/scripts/validar_ficheros_grupo.py ageing
    python reporting-financiero/scripts/validar_ficheros_grupo.py revenue --fuentes "RUTA a 3.Fuentes"

Lee la carpeta 3.Fuentes de OneDrive y consulta Fabric en solo lectura con la cuenta de Tinkle.
Salida en ASCII. Códigos: 0 las cifras de control cuadran, 1 no cuadran, 2 cuenta o ficheros.
"""

import argparse
import datetime as dt
import sys
from collections import defaultdict
from pathlib import Path

import openpyxl

import fabric_comun as fc

FUENTES = (Path.home() / "OneDrive - Docenteo" / "DOCENTEO - General" / "02.Clientes" / "04.Tinkle"
           / "Reporting financiero" / "3.Fuentes")
CORTE = dt.datetime(2026, 3, 31)
# Cada línea de Revenue va redondeada a 2 decimales: la suma por sociedad puede desviarse unos céntimos.
TOLERANCIA_SOCIEDAD = 0.05

SOC_AGING = {"ES TINKLE COMMUNICATIONS": "ESP066", "ES TINKLE EUROPEAN": "ESP067", "ES TINKLE JAZZ": "ESP068",
             "ES TINKLE ONION": "ESP069", "ES TINKLE CONSULTANTS": "ESP070"}
SOC_MMS = {"TINKLE COMMUNICATIONS, S.L.": "ESP066", "EUROPEAN PUBLIC RELATIONS SERVICES SLU": "ESP067",
           "JAZZ ALTERNATIVE THINKING S.L.": "ESP068", "ONION DIGITAL SERVICES S.L.U.": "ESP069",
           "TINKLE CONSULTANTS, S.L.": "ESP070"}
SOC_CODIGO = {"COMM": "ESP066", "EURO": "ESP067", "JAZZ": "ESP068", "ONION": "ESP069", "CONS": "ESP070"}

# Límites del DAX AgingBucket del modelo Agings y códigos de la plantilla de Grupo.
TRAMOS = [(30, "GR1"), (60, "GR2"), (90, "GR3"), (120, "GR4"), (180, "GR5"), (365, "GR8C")]

CONSULTA_MMS = """
SELECT DISTINCT [Compañia], [Nº Factura Cli.], [Cod. Cliente], [Nif. Empresa/Cliente]
FROM [200].[MMS]
WHERE [Nº Factura Cli.] IS NOT NULL
"""

CONSULTA_REVENUE = """
SELECT f.[CodigoSociedad], f.[Cliente], d.[Cliente ORACLE], d.[Cliente MMS], -SUM(f.[Saldo]) / 1000.0
FROM [300].[Fact_Actuals] f
JOIN [300].[Dim_Cuentas] c ON c.[ID_Account] = f.[ID_Account]
LEFT JOIN [300].[Dim_Clientes] d ON d.[ClienteKey_Oracle] = f.[ClienteKey_Oracle]
WHERE c.[Cuenta_magnitude] IN ('X60000', 'X70000')
  AND CAST(f.[Periodo] AS date) BETWEEN '2026-01-01' AND '2026-03-31'
GROUP BY f.[CodigoSociedad], f.[Cliente], d.[Cliente ORACLE], d.[Cliente MMS]
"""


def limpio(valor):
    texto = "" if valor is None else str(valor).strip()
    return texto[:-2] if texto.endswith(".0") else texto


def tramo(vencimiento):
    dias = (CORTE - vencimiento).days
    if dias <= 0:
        return "GR0"
    for limite, codigo in TRAMOS:
        if dias <= limite:
            return codigo
    return "GR9C"


def leer_txt(carpeta):
    """Filas de datos (campos separados) de los TXT de una carpeta de marzo."""
    filas = []
    for ruta in sorted(carpeta.glob("*.txt")):
        for linea in ruta.read_text(encoding="utf-8").splitlines()[1:]:
            campos = linea.split(";")
            if len(campos) > 25:
                filas.append(campos)
    return filas


def mapeo_magnitude(ruta_excel):
    """(sociedad, cliente Oracle) y (sociedad, 'MMS' + código MMS) -> código de cliente Magnitude.

    La hoja FT3 2026 tiene prioridad; el resto de hojas solo completa huecos. Los códigos
    numéricos se rellenan a 8 dígitos porque Excel pierde el cero inicial.
    """
    libro = openpyxl.load_workbook(ruta_excel, read_only=True, data_only=True)
    hojas = sorted(libro.worksheets, key=lambda h: h.title != "Revenue by client FT3 2026")
    mapeo = {}
    for hoja in hojas:
        cabecera = [limpio(v).lower() for v in next(hoja.iter_rows(min_row=1, max_row=1, values_only=True), ())]
        nombres = ("codigo cliente magnitude", "codigo mms", "code magnitude", "cliente")
        if not set(nombres) <= set(cabecera):
            continue
        i_codigo, i_mms, i_soc, i_oracle = (cabecera.index(n) for n in nombres)
        for fila in hoja.iter_rows(min_row=2, values_only=True):
            if len(fila) <= max(i_codigo, i_mms, i_soc, i_oracle):
                continue
            codigo, soc = limpio(fila[i_codigo]), limpio(fila[i_soc])
            if not codigo or codigo == "#N/A":
                continue
            if codigo.isdigit() and len(codigo) < 8:
                codigo = codigo.zfill(8)
            mapeo.setdefault((soc, limpio(fila[i_oracle])), codigo)
            mapeo.setdefault((soc, "MMS" + limpio(fila[i_mms])), codigo)
    return mapeo


def consultar(sql):
    con = fc.conectar_sql()
    cursor = con.cursor()
    cursor.execute(sql)
    filas = cursor.fetchall()
    con.close()
    return filas


def comparar_lineas(txt, calculado, tolerancia):
    exactas = sum(1 for k in txt if k in calculado and abs(txt[k] - calculado[k]) < tolerancia)
    distintas = sum(1 for k in txt if k in calculado and abs(txt[k] - calculado[k]) >= tolerancia)
    solo_txt = sum(1 for k in txt if k not in calculado)
    solo_calculadas = sum(1 for k in calculado if k not in txt and abs(calculado[k]) >= tolerancia)
    print(f"CLIENTES lineas_txt={len(txt)} exactas={exactas} distintas={distintas} "
          f"solo_txt={solo_txt} solo_calculadas={solo_calculadas}")


def validar_ageing(fuentes):
    facturas = []
    libro = openpyxl.load_workbook(fuentes / "AGING Clientes Tinkle 2026 03 31.xlsx", read_only=True, data_only=True)
    for fila in libro["DATOS"].iter_rows(min_row=2, values_only=True):
        if fila[0]:
            facturas.append({"soc": SOC_AGING[fila[0].strip()], "interno": limpio(fila[2]), "nombre": limpio(fila[3]),
                             "factura": limpio(fila[5]), "nif": limpio(fila[7]), "tramo": tramo(fila[10]),
                             "importe": float(fila[12] or 0)})

    txt_tramos = defaultdict(float)
    txt_lineas = defaultdict(float)
    txt_flags = set()
    for campos in leer_txt(fuentes / "2026 03 - 0001 Magnitude Marzo" / "Ageing" / "03 MAR-26"):
        if campos[12] == "GRICFLAG":
            txt_flags.add((campos[2], campos[8]))
        else:
            txt_tramos[(campos[2], campos[12])] += float(campos[25])
            txt_lineas[(campos[2], campos[8], campos[12])] += float(campos[25])

    calculado = defaultdict(float)
    for f in facturas:
        calculado[(f["soc"], f["tramo"])] += f["importe"] / 1000
    diferencias = {k: txt_tramos.get(k, 0) - calculado.get(k, 0) for k in set(txt_tramos) | set(calculado)}
    maxima = max(abs(d) for d in diferencias.values())
    print(f"TRAMOS combinaciones={len(diferencias)} diferencia_maxima={maxima:.4f}")
    for (soc, gr), d in sorted(diferencias.items()):
        if abs(d) >= 0.001:
            print(f"  DIFERENCIA {soc} {gr} txt={txt_tramos.get((soc, gr), 0):.4f} calculado={calculado.get((soc, gr), 0):.4f}")

    por_factura, por_nif = defaultdict(set), defaultdict(set)
    for compania, factura, cliente, nif in consultar(CONSULTA_MMS):
        soc = SOC_MMS.get(limpio(compania))
        if soc and limpio(cliente):
            por_factura[(soc, limpio(factura))].add(limpio(cliente))
            if limpio(nif):
                por_nif[(soc, limpio(nif))].add(limpio(cliente))
    mapeo = mapeo_magnitude(fuentes / "Presupuestos" / "Revenue 2026 FT3.xlsm")

    lineas = defaultdict(float)
    flags = set()
    sin_codigo = 0.0
    for f in facturas:
        clientes = por_factura.get((f["soc"], f["factura"])) or por_nif.get((f["soc"], f["nif"]), set())
        codigo = mapeo.get((f["soc"], "MMS" + next(iter(clientes)))) if len(clientes) == 1 else None
        if not codigo:
            sin_codigo += f["importe"]
        clave = codigo or "?" + f["nombre"]
        lineas[(f["soc"], clave, f["tramo"])] += f["importe"] / 1000
        if f["interno"] == "Y":
            flags.add((f["soc"], clave))
    comparar_lineas(txt_lineas, lineas, 0.0006)
    print(f"  importe_sin_codigo={sin_codigo:.2f}")
    print(f"GRICFLAG txt={len(txt_flags)} calculados={len(flags)} coinciden={len(txt_flags & flags)}")
    return 0 if maxima < 0.001 else 1


def validar_revenue(fuentes):
    txt_sociedad = defaultdict(float)
    txt_lineas = defaultdict(float)
    for campos in leer_txt(fuentes / "2026 03 - 0001 Magnitude Marzo" / "Revenue" / "03 MAR-26"):
        txt_sociedad[campos[2]] += float(campos[25])
        txt_lineas[(campos[2], campos[8])] += float(campos[25])

    mapeo = mapeo_magnitude(fuentes / "Presupuestos" / "Revenue 2026 FT3.xlsm")
    calc_sociedad = defaultdict(float)
    lineas = defaultdict(float)
    sin_codigo = 0.0
    for codigo_soc, cliente, cliente_oracle, cliente_mms, importe in consultar(CONSULTA_REVENUE):
        soc = SOC_CODIGO.get(limpio(codigo_soc))
        if not soc:
            continue
        importe = float(importe or 0)
        calc_sociedad[soc] += importe
        codigo = mapeo.get((soc, limpio(cliente_oracle) or limpio(cliente))) or mapeo.get((soc, "MMS" + limpio(cliente_mms)))
        if codigo:
            lineas[(soc, codigo)] += importe
        else:
            sin_codigo += importe

    resultado = 0
    for soc in sorted(set(txt_sociedad) | set(calc_sociedad)):
        diferencia = txt_sociedad.get(soc, 0) - calc_sociedad.get(soc, 0)
        print(f"SOCIEDAD {soc} txt={txt_sociedad.get(soc, 0):.2f} calculado={calc_sociedad.get(soc, 0):.2f} dif={diferencia:.4f}")
        if abs(diferencia) >= TOLERANCIA_SOCIEDAD:
            resultado = 1
    comparar_lineas(txt_lineas, {k: round(v, 2) for k, v in lineas.items()}, 0.006)
    print(f"  importe_sin_codigo={sin_codigo:.2f}")
    return resultado


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("fichero", choices=["ageing", "revenue"])
    parser.add_argument("--fuentes", default=str(FUENTES), help="carpeta 3.Fuentes de OneDrive")
    args = parser.parse_args()

    fuentes = Path(args.fuentes)
    if not (fuentes / "2026 03 - 0001 Magnitude Marzo").exists():
        print("ERROR: no se encuentra la carpeta de TXT de marzo en " + fc.ascii(fuentes))
        return 2
    fc.comprobar_cuenta()
    return validar_ageing(fuentes) if args.fichero == "ageing" else validar_revenue(fuentes)


if __name__ == "__main__":
    sys.exit(main())
