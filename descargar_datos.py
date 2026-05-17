"""Descarga indicadores macroeconomicos de Mexico (1960-2024).

Fuente: World Bank Indicators API
  - URL base: https://api.worldbank.org/v2/country/MEX/indicator/<CODE>
  - Sin token, sin auth, URLs estables, 100% publico
  - Mantenido por el Banco Mundial con datos oficiales reportados por cada pais

Se descargan 15 indicadores en formato JSON y se consolidan en un solo CSV
ancho-a-largo que cargara_db.py cargara a DuckDB.

Salida: data/wb_mexico_indicadores.csv
        (~30 KB, 15 indicadores x ~64 anios)
"""
from __future__ import annotations

import csv
import json
import sys
import time
from pathlib import Path
from urllib.request import Request, urlopen

DIR_DATA = Path(__file__).parent / "data"
DIR_DATA.mkdir(exist_ok=True)
SALIDA = DIR_DATA / "wb_mexico_indicadores.csv"

INDICADORES = [
    # (codigo_wb, columna_amigable, descripcion_corta)
    ("NY.GDP.MKTP.CD",   "pib_nominal_usd",         "PIB nominal en USD corrientes"),
    ("NY.GDP.MKTP.KD.ZG","pib_crecimiento_pct",     "Crecimiento anual del PIB (%)"),
    ("NY.GDP.PCAP.CD",   "pib_per_capita_usd",      "PIB per capita USD"),
    ("FP.CPI.TOTL.ZG",   "inflacion_pct",           "Inflacion anual (CPI %)"),
    ("FR.INR.RINR",      "tasa_interes_real_pct",   "Tasa de interes real (%)"),
    ("SL.UEM.TOTL.ZS",   "desempleo_pct",           "Tasa de desempleo (% PEA)"),
    ("NE.EXP.GNFS.CD",   "exportaciones_usd",       "Exportaciones de bienes y servicios USD"),
    ("NE.IMP.GNFS.CD",   "importaciones_usd",       "Importaciones de bienes y servicios USD"),
    ("BX.KLT.DINV.CD.WD","ied_usd",                 "Inversion extranjera directa neta USD"),
    ("DT.DOD.DECT.CD",   "deuda_externa_usd",       "Deuda externa total USD"),
    ("SP.POP.TOTL",      "poblacion",               "Poblacion total"),
    ("SE.XPD.TOTL.GD.ZS","gasto_educacion_pct_pib", "Gasto en educacion (% PIB)"),
    ("SH.XPD.CHEX.GD.ZS","gasto_salud_pct_pib",     "Gasto en salud (% PIB)"),
    ("EN.GHG.CO2.PC.CE.AR5", "co2_per_capita_ton",  "Emisiones CO2 per capita (toneladas)"),
    ("SI.POV.GINI",      "gini",                    "Indice de Gini (desigualdad)"),
]

URL_BASE = "https://api.worldbank.org/v2/country/MEX/indicator/{code}?format=json&per_page=200"
USER_AGENT = "Mozilla/5.0 (compatible; PortfolioSQL/1.0)"


def descargar_indicador(code: str) -> list[dict]:
    """Devuelve lista de {ano, valor} para un indicador."""
    url = URL_BASE.format(code=code)
    req = Request(url, headers={"User-Agent": USER_AGENT})
    with urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    if not isinstance(data, list) or len(data) < 2 or data[1] is None:
        return []
    out = []
    for fila in data[1]:
        if fila.get("value") is None:
            continue
        try:
            out.append({"anio": int(fila["date"]), "valor": float(fila["value"])})
        except (TypeError, ValueError):
            continue
    return out


def main() -> None:
    print(f"Descargando {len(INDICADORES)} indicadores del Banco Mundial...")
    print()

    # series[code] = {anio: valor}
    series = {}
    for code, columna, desc in INDICADORES:
        print(f"  {columna:30s} ({code})")
        try:
            datos = descargar_indicador(code)
            if not datos:
                print(f"    sin datos disponibles")
                series[columna] = {}
                continue
            series[columna] = {d["anio"]: d["valor"] for d in datos}
            anos = sorted(series[columna].keys())
            print(f"    {len(datos)} observaciones, {anos[0]} - {anos[-1]}")
        except Exception as e:
            print(f"    ERROR: {e}", file=sys.stderr)
            series[columna] = {}
        time.sleep(0.2)  # cortesia con la API publica

    # Consolidar en formato wide: una fila por anio, una columna por indicador
    todos_anios = set()
    for d in series.values():
        todos_anios.update(d.keys())
    anios_ordenados = sorted(todos_anios)
    columnas = ["anio"] + [c for _, c, _ in INDICADORES]

    print()
    print(f"Escribiendo CSV consolidado: {SALIDA.name}")
    with SALIDA.open("w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(columnas)
        for a in anios_ordenados:
            fila = [a]
            for _, c, _ in INDICADORES:
                v = series[c].get(a)
                fila.append("" if v is None else f"{v:.6f}")
            w.writerow(fila)

    tam = SALIDA.stat().st_size / 1024
    print(f"  OK -> {len(anios_ordenados)} anios, {len(columnas)} columnas, {tam:.1f} KB")


if __name__ == "__main__":
    main()
