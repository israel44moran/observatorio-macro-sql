"""Carga el CSV consolidado a DuckDB con tres tablas:

  1. indicadores_wide     (1 fila por anio, 15 columnas de indicadores)
  2. indicadores_long     (1 fila por anio+indicador, formato tall)
  3. catalogo_indicadores (codigo, nombre, descripcion, unidad)
  4. eventos_macro        (anio, evento, categoria)  -- para queries segmentadas

DuckDB es ideal: lee CSV directo, sin servidor, persistencia en archivo,
SQL estandar 2023 con todas las window functions y CTEs.

Salida: analisis.duckdb (~50 KB)
"""
from __future__ import annotations

from pathlib import Path

import duckdb

DIR = Path(__file__).parent
RUTA_CSV = DIR / "data" / "wb_mexico_indicadores.csv"
RUTA_DB = DIR / "analisis.duckdb"

CATALOGO = [
    # (columna, codigo_wb, nombre, unidad)
    ("pib_nominal_usd",         "NY.GDP.MKTP.CD",      "PIB nominal",                "USD corrientes"),
    ("pib_crecimiento_pct",     "NY.GDP.MKTP.KD.ZG",   "Crecimiento del PIB",        "% anual"),
    ("pib_per_capita_usd",      "NY.GDP.PCAP.CD",      "PIB per capita",             "USD corrientes"),
    ("inflacion_pct",           "FP.CPI.TOTL.ZG",      "Inflacion",                  "% anual"),
    ("tasa_interes_real_pct",   "FR.INR.RINR",         "Tasa de interes real",       "% anual"),
    ("desempleo_pct",           "SL.UEM.TOTL.ZS",      "Tasa de desempleo",          "% de la PEA"),
    ("exportaciones_usd",       "NE.EXP.GNFS.CD",      "Exportaciones",              "USD corrientes"),
    ("importaciones_usd",       "NE.IMP.GNFS.CD",      "Importaciones",              "USD corrientes"),
    ("ied_usd",                 "BX.KLT.DINV.CD.WD",   "Inversion extranjera directa","USD corrientes"),
    ("deuda_externa_usd",       "DT.DOD.DECT.CD",      "Deuda externa",              "USD corrientes"),
    ("poblacion",               "SP.POP.TOTL",         "Poblacion",                  "habitantes"),
    ("gasto_educacion_pct_pib", "SE.XPD.TOTL.GD.ZS",   "Gasto publico en educacion", "% del PIB"),
    ("gasto_salud_pct_pib",     "SH.XPD.CHEX.GD.ZS",   "Gasto en salud",             "% del PIB"),
    ("co2_per_capita_ton",      "EN.GHG.CO2.PC.CE.AR5","Emisiones CO2 per capita",   "toneladas"),
    ("gini",                    "SI.POV.GINI",         "Indice de Gini",             "0-100"),
]

EVENTOS = [
    (1976, "Devaluacion del peso",                    "crisis"),
    (1982, "Crisis de la deuda externa",              "crisis"),
    (1988, "Inicio del periodo de Salinas",           "regimen"),
    (1994, "Entrada en vigor del TLCAN",              "tratado"),
    (1995, "Crisis del Tequila",                      "crisis"),
    (2000, "Alternancia politica: Fox / PAN",         "regimen"),
    (2001, "Recesion EUA post-9/11",                  "externo"),
    (2006, "Inicio periodo de Calderon",              "regimen"),
    (2009, "Crisis financiera global",                "crisis"),
    (2012, "Inicio periodo de Pena Nieto",            "regimen"),
    (2018, "Inicio periodo de Lopez Obrador (AMLO)",  "regimen"),
    (2020, "Pandemia COVID-19",                       "crisis"),
    (2024, "Inicio periodo de Sheinbaum",             "regimen"),
]


def main() -> None:
    if not RUTA_CSV.exists():
        raise SystemExit(f"Falta {RUTA_CSV}. Corre primero: python descargar_datos.py")

    if RUTA_DB.exists():
        RUTA_DB.unlink()

    con = duckdb.connect(str(RUTA_DB))

    # ---------------------------------------------------------------
    # 1. Tabla WIDE: 1 fila por anio (como viene en el CSV)
    # ---------------------------------------------------------------
    con.execute(f"""
        CREATE TABLE indicadores_wide AS
        SELECT * FROM read_csv('{RUTA_CSV.as_posix()}',
                               header = true,
                               auto_detect = true);
    """)
    print(f"  indicadores_wide:     {con.execute('SELECT COUNT(*) FROM indicadores_wide').fetchone()[0]} filas")

    # ---------------------------------------------------------------
    # 2. Tabla LONG: 1 fila por (anio, indicador). Mucho mas natural
    #    para queries que comparan varios indicadores.
    # ---------------------------------------------------------------
    columnas_indicadores = [c for c, _, _, _ in CATALOGO]
    union_parts = []
    for col in columnas_indicadores:
        union_parts.append(
            f"SELECT anio, '{col}' AS indicador, {col} AS valor "
            f"FROM indicadores_wide WHERE {col} IS NOT NULL"
        )
    sql_long = " UNION ALL ".join(union_parts)
    con.execute(f"CREATE TABLE indicadores_long AS {sql_long};")
    print(f"  indicadores_long:     {con.execute('SELECT COUNT(*) FROM indicadores_long').fetchone()[0]} filas")

    # ---------------------------------------------------------------
    # 3. Catalogo de indicadores
    # ---------------------------------------------------------------
    con.execute("""
        CREATE TABLE catalogo_indicadores (
            columna     VARCHAR PRIMARY KEY,
            codigo_wb   VARCHAR,
            nombre      VARCHAR,
            unidad      VARCHAR
        );
    """)
    con.executemany(
        "INSERT INTO catalogo_indicadores VALUES (?, ?, ?, ?);",
        CATALOGO,
    )
    print(f"  catalogo_indicadores: {len(CATALOGO)} filas")

    # ---------------------------------------------------------------
    # 4. Eventos macroeconomicos importantes (para segmentacion)
    # ---------------------------------------------------------------
    con.execute("""
        CREATE TABLE eventos_macro (
            anio      INTEGER,
            evento    VARCHAR,
            categoria VARCHAR
        );
    """)
    con.executemany(
        "INSERT INTO eventos_macro VALUES (?, ?, ?);",
        EVENTOS,
    )
    print(f"  eventos_macro:        {len(EVENTOS)} filas")

    # ---------------------------------------------------------------
    # 5. Vistas de conveniencia
    # ---------------------------------------------------------------
    con.execute("""
        CREATE VIEW v_indicadores_etiquetados AS
        SELECT
            l.anio,
            l.indicador,
            l.valor,
            c.nombre,
            c.unidad,
            c.codigo_wb
        FROM indicadores_long l
        LEFT JOIN catalogo_indicadores c ON c.columna = l.indicador;
    """)

    con.execute("""
        CREATE VIEW v_anio_con_eventos AS
        SELECT
            w.anio,
            w.pib_nominal_usd,
            w.pib_crecimiento_pct,
            w.inflacion_pct,
            w.desempleo_pct,
            STRING_AGG(e.evento, ' / ') AS eventos
        FROM indicadores_wide w
        LEFT JOIN eventos_macro e ON e.anio = w.anio
        GROUP BY w.anio, w.pib_nominal_usd, w.pib_crecimiento_pct,
                 w.inflacion_pct, w.desempleo_pct
        ORDER BY w.anio;
    """)
    print("  vistas v_indicadores_etiquetados, v_anio_con_eventos")

    con.close()
    tam = RUTA_DB.stat().st_size / 1024
    print(f"\nBase guardada: {RUTA_DB.name} ({tam:.1f} KB)")


if __name__ == "__main__":
    main()
