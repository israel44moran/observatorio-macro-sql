"""Genera 4 graficas PNG de los hallazgos mas relevantes.

Las gráficas son producto secundario: la fuente primaria sigue siendo
el SQL. Aqui solo tomamos el resultado de cada query y lo visualizamos
con matplotlib usando la paleta del portafolio (dark + ambar).

Salida: graficas/01_*.png, 02_*.png, 03_*.png, 04_*.png
"""
from __future__ import annotations

from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import matplotlib.ticker as mtick
import numpy as np

DIR = Path(__file__).parent
DIR_GRAF = DIR / "graficas"
DIR_GRAF.mkdir(exist_ok=True)
RUTA_DB = DIR / "analisis.duckdb"

# Paleta del portafolio
INK   = "#0E1218"
SURFACE = "#171C24"
BORDER = "#2A3140"
CREAM = "#F2EDE3"
COOL  = "#9AA3B5"
MUTED = "#5A6478"
AMBER = "#D4A574"
AMBER_DIM = "#8B6E47"
GREEN = "#7A9B7E"
RED   = "#C26B5E"


def aplicar_estilo(ax, fig):
    fig.patch.set_facecolor(INK)
    ax.set_facecolor(INK)
    for s in ("top", "right", "left", "bottom"):
        ax.spines[s].set_color(BORDER)
    ax.tick_params(colors=COOL, which="both", labelsize=9)
    ax.xaxis.label.set_color(MUTED)
    ax.yaxis.label.set_color(MUTED)
    # Forzamos color del titulo otra vez por si matplotlib lo resetea
    if ax.get_title():
        ax.set_title(ax.get_title(), color=CREAM,
                     fontsize=14, pad=20, loc="left", weight="medium")
    ax.grid(axis="y", color=BORDER, linewidth=0.5, linestyle="-", alpha=0.5)
    ax.set_axisbelow(True)


def titulo(ax, texto: str):
    """Helper para setear titulo siempre con el color y estilo correctos."""
    ax.set_title(texto, color=CREAM, fontsize=14,
                 pad=20, loc="left", weight="medium")


def grafica_1_inflacion_sexenal(con):
    """Bar chart horizontal: inflacion acumulada por sexenio."""
    sql = """
    WITH s AS (
        SELECT
            CASE
                WHEN anio BETWEEN 1970 AND 1976 THEN '1970-1976 Echeverría'
                WHEN anio BETWEEN 1977 AND 1982 THEN '1977-1982 López Portillo'
                WHEN anio BETWEEN 1983 AND 1988 THEN '1983-1988 De la Madrid'
                WHEN anio BETWEEN 1989 AND 1994 THEN '1989-1994 Salinas'
                WHEN anio BETWEEN 1995 AND 2000 THEN '1995-2000 Zedillo'
                WHEN anio BETWEEN 2001 AND 2006 THEN '2001-2006 Fox'
                WHEN anio BETWEEN 2007 AND 2012 THEN '2007-2012 Calderón'
                WHEN anio BETWEEN 2013 AND 2018 THEN '2013-2018 Peña Nieto'
                WHEN anio BETWEEN 2019 AND 2024 THEN '2019-2024 López Obrador'
            END AS sexenio, inflacion_pct
        FROM indicadores_wide
        WHERE inflacion_pct IS NOT NULL AND anio BETWEEN 1970 AND 2024
    )
    SELECT sexenio, ROUND((EXP(SUM(LN(1 + inflacion_pct/100))) - 1) * 100, 1) AS inf
    FROM s WHERE sexenio IS NOT NULL GROUP BY sexenio ORDER BY sexenio;
    """
    data = con.execute(sql).fetchall()
    labels = [r[0] for r in data]
    valores = [r[1] for r in data]

    fig, ax = plt.subplots(figsize=(11, 6))
    y = np.arange(len(labels))
    colores = [RED if v > 200 else AMBER if v > 50 else GREEN for v in valores]
    bars = ax.barh(y, valores, color=colores, edgecolor=INK, linewidth=1.5)
    ax.set_yticks(y)
    ax.set_yticklabels(labels, color=CREAM, fontsize=10)
    ax.set_xscale("log")
    ax.xaxis.set_major_formatter(mtick.FuncFormatter(lambda v, _: f"{v:,.0f}%"))
    ax.set_xlabel("Inflación acumulada (escala logarítmica)", fontsize=9)
    titulo(ax, "Inflación acumulada por sexenio en México  |  1970 – 2024")

    for i, (b, v) in enumerate(zip(bars, valores)):
        ax.text(v * 1.1, i, f"{v:,.0f}%", color=CREAM, fontsize=10, va="center")

    ax.invert_yaxis()
    aplicar_estilo(ax, fig)
    plt.tight_layout()
    out = DIR_GRAF / "01_inflacion_sexenal.png"
    plt.savefig(out, dpi=140, facecolor=INK, bbox_inches="tight")
    plt.close()
    print(f"  -> {out.name}")


def grafica_2_pib_con_promedios(con):
    """Line chart: crecimiento anual + promedio movil 5 anos + anotaciones."""
    sql = """
    SELECT anio,
           pib_crecimiento_pct,
           AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS prom5
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL AND anio >= 1970
    ORDER BY anio;
    """
    data = con.execute(sql).fetchall()
    anios = [r[0] for r in data]
    pib = [r[1] for r in data]
    prom5 = [r[2] for r in data]

    fig, ax = plt.subplots(figsize=(12, 5.5))
    ax.axhline(0, color=COOL, linewidth=0.8, linestyle="--", alpha=0.6)
    ax.plot(anios, pib, color=AMBER, linewidth=1, alpha=0.5, label="Crecimiento anual")
    ax.fill_between(anios, pib, 0, where=[p < 0 for p in pib],
                    color=RED, alpha=0.25, label="Años recesivos")
    ax.plot(anios, prom5, color=CREAM, linewidth=2.5, label="Promedio móvil 5 años")

    eventos = [
        (1982, "Crisis de\nla deuda"),
        (1995, "Crisis del\nTequila"),
        (2009, "Crisis\nfinanciera"),
        (2020, "COVID-19"),
    ]
    for ev_anio, ev_label in eventos:
        idx = anios.index(ev_anio)
        ax.scatter(ev_anio, pib[idx], color=RED, s=70, zorder=5,
                   edgecolor=INK, linewidth=2)
        ax.annotate(ev_label, xy=(ev_anio, pib[idx]),
                    xytext=(ev_anio, pib[idx] - 4),
                    color=CREAM, fontsize=8.5, ha="center",
                    bbox=dict(boxstyle="round,pad=0.3", facecolor=SURFACE,
                              edgecolor=AMBER_DIM, alpha=0.95))

    titulo(ax, "Crecimiento del PIB de México  |  promedio móvil 5 años y eventos macro")
    ax.set_xlabel("Año", fontsize=9)
    ax.set_ylabel("Crecimiento del PIB (%)", fontsize=9)
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    leg = ax.legend(loc="lower left", frameon=False, fontsize=9, labelcolor=CREAM)
    aplicar_estilo(ax, fig)
    plt.tight_layout()
    out = DIR_GRAF / "02_pib_promedios_moviles.png"
    plt.savefig(out, dpi=140, facecolor=INK, bbox_inches="tight")
    plt.close()
    print(f"  -> {out.name}")


def grafica_3_recesiones(con):
    """Bar chart: anios recesivos resaltados."""
    sql = """
    SELECT anio, pib_crecimiento_pct
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL AND anio >= 1970
    ORDER BY anio;
    """
    data = con.execute(sql).fetchall()
    anios = [r[0] for r in data]
    pib = [r[1] for r in data]

    colores = [RED if p < 0 else AMBER_DIM for p in pib]

    fig, ax = plt.subplots(figsize=(12, 5))
    ax.bar(anios, pib, color=colores, edgecolor=INK, linewidth=0.6, width=0.85)
    ax.axhline(0, color=COOL, linewidth=0.8)

    for a, p in zip(anios, pib):
        if p < 0:
            ax.text(a, p - 0.5, f"{p:.1f}", color=RED, fontsize=8,
                    ha="center", va="top", weight="medium")

    titulo(ax, "Recesiones de México  |  años con crecimiento del PIB negativo destacados en rojo")
    ax.set_xlabel("Año", fontsize=9)
    ax.set_ylabel("Crecimiento del PIB (%)", fontsize=9)
    ax.yaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    aplicar_estilo(ax, fig)
    plt.tight_layout()
    out = DIR_GRAF / "03_recesiones.png"
    plt.savefig(out, dpi=140, facecolor=INK, bbox_inches="tight")
    plt.close()
    print(f"  -> {out.name}")


def grafica_4_eventos_antes_despues(con):
    """Dumbbell chart: PIB 5 anios antes vs 5 anios despues por evento."""
    sql = """
    SELECT e.anio, e.evento,
        (SELECT ROUND(AVG(pib_crecimiento_pct), 2) FROM indicadores_wide
         WHERE anio BETWEEN e.anio-5 AND e.anio-1 AND pib_crecimiento_pct IS NOT NULL) AS antes,
        (SELECT ROUND(AVG(pib_crecimiento_pct), 2) FROM indicadores_wide
         WHERE anio BETWEEN e.anio+1 AND e.anio+5 AND pib_crecimiento_pct IS NOT NULL) AS despues
    FROM eventos_macro e
    WHERE e.anio <= 2020
    ORDER BY e.anio;
    """
    data = con.execute(sql).fetchall()
    data = [r for r in data if r[2] is not None and r[3] is not None]
    labels = [f"{r[0]}  {r[1][:50]}" for r in data]
    antes = [r[2] for r in data]
    despues = [r[3] for r in data]

    fig, ax = plt.subplots(figsize=(11, 7))
    y = np.arange(len(labels))

    for i in range(len(labels)):
        color_linea = RED if despues[i] < antes[i] else GREEN
        ax.plot([antes[i], despues[i]], [i, i], color=color_linea,
                linewidth=2.5, alpha=0.7, zorder=2)
        ax.scatter(antes[i], i, color=COOL, s=120, zorder=3,
                   edgecolor=INK, linewidth=1.5, label="Antes" if i == 0 else "")
        ax.scatter(despues[i], i, color=color_linea, s=140, zorder=4,
                   edgecolor=INK, linewidth=1.5, label="Después" if i == 0 else "")

    ax.axvline(0, color=COOL, linewidth=0.8, linestyle="--", alpha=0.5)
    ax.set_yticks(y)
    ax.set_yticklabels(labels, color=CREAM, fontsize=9)
    ax.set_xlabel("PIB promedio (%) en ventana de 5 años", fontsize=9)
    titulo(ax, "Crecimiento del PIB  5 años antes vs 5 años después  de cada evento macro")
    ax.legend(loc="lower right", frameon=False, labelcolor=CREAM, fontsize=9)
    ax.xaxis.set_major_formatter(mtick.PercentFormatter(decimals=0))
    ax.invert_yaxis()
    aplicar_estilo(ax, fig)
    plt.tight_layout()
    out = DIR_GRAF / "04_eventos_antes_despues.png"
    plt.savefig(out, dpi=140, facecolor=INK, bbox_inches="tight")
    plt.close()
    print(f"  -> {out.name}")


def main() -> None:
    if not RUTA_DB.exists():
        raise SystemExit("Falta analisis.duckdb. Corre primero: python cargar_db.py")
    con = duckdb.connect(str(RUTA_DB), read_only=True)
    print("Generando graficas...")
    grafica_1_inflacion_sexenal(con)
    grafica_2_pib_con_promedios(con)
    grafica_3_recesiones(con)
    grafica_4_eventos_antes_despues(con)
    con.close()
    print(f"\nListo. 4 PNGs en {DIR_GRAF.name}/")


if __name__ == "__main__":
    main()
