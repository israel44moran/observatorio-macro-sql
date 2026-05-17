"""Ejecuta los 15 archivos .sql sobre analisis.duckdb y genera reporte.

Por cada query produce un bloque markdown en resultados/<nombre>.md con:
  - El SQL completo (formato bloque ```sql)
  - La tabla del resultado (limitada a 15 filas para legibilidad)
  - Una pequena nota tecnica sobre que demuestra

Luego concatena todos los resultados en RESULTADOS.md, un documento
unico que el README puede referenciar.
"""
from __future__ import annotations

from pathlib import Path

import duckdb

DIR = Path(__file__).parent
DIR_QUERIES = DIR / "queries"
DIR_RESULTADOS = DIR / "resultados"
RUTA_DB = DIR / "analisis.duckdb"
RUTA_RESUMEN = DIR / "RESULTADOS.md"

MAX_FILAS_TABLA = 15  # Para que el markdown sea legible


def cargar_query(ruta: Path) -> tuple[str, str, str]:
    """Devuelve (titulo, comentario, sql_limpio) parseando el header."""
    texto = ruta.read_text(encoding="utf-8")
    lineas = texto.split("\n")
    titulo = ruta.stem
    comentario_lineas = []
    sql_lineas = []
    en_header = True
    for ln in lineas:
        ln_strip = ln.strip()
        if en_header and ln_strip.startswith("--"):
            limpio = ln_strip.lstrip("-").strip()
            if limpio.startswith("==="):
                continue
            if limpio:
                comentario_lineas.append(limpio)
            continue
        if ln_strip == "":
            if en_header:
                continue
        en_header = False
        sql_lineas.append(ln)

    # El primer comentario suele ser el titulo
    titulo_legible = comentario_lineas[0] if comentario_lineas else titulo
    if "." in titulo_legible[:4]:
        titulo_legible = titulo_legible.split(".", 1)[1].strip()
    comentario = "\n".join(comentario_lineas[1:]).strip()
    sql_limpio = "\n".join(sql_lineas).strip()
    return titulo_legible, comentario, sql_limpio


def formato_celda(v) -> str:
    if v is None:
        return "—"
    if isinstance(v, float):
        # Anios sin separador de miles
        if v.is_integer() and 1900 <= v <= 2100:
            return str(int(v))
        if v.is_integer():
            return f"{int(v):,}"
        return f"{v:,.3f}".rstrip("0").rstrip(".")
    if isinstance(v, int):
        if 1900 <= v <= 2100:
            return str(v)
        return f"{v:,}"
    return str(v)


def df_a_markdown(rows, columns) -> str:
    if not rows:
        return "_(sin resultados)_"
    rows = rows[:MAX_FILAS_TABLA]
    header = "| " + " | ".join(columns) + " |"
    separator = "| " + " | ".join(["---"] * len(columns)) + " |"
    body = "\n".join(
        "| " + " | ".join(formato_celda(c) for c in r) + " |"
        for r in rows
    )
    return f"{header}\n{separator}\n{body}"


def main() -> None:
    if not RUTA_DB.exists():
        raise SystemExit(f"Falta {RUTA_DB}. Corre primero: python cargar_db.py")

    DIR_RESULTADOS.mkdir(exist_ok=True)

    con = duckdb.connect(str(RUTA_DB), read_only=True)
    queries = sorted(DIR_QUERIES.glob("*.sql"))
    if not queries:
        raise SystemExit("Sin archivos .sql en queries/")

    resumen_lineas = [
        "# Resultados de las 15 queries",
        "",
        f"Generado automaticamente por `correr_analisis.py` sobre `analisis.duckdb`.",
        f"Total de queries: **{len(queries)}**.",
        "",
        "---",
        "",
    ]

    for i, ruta in enumerate(queries, 1):
        print(f"  [{i:>2}/{len(queries)}] {ruta.name}")
        titulo, comentario, sql = cargar_query(ruta)
        try:
            res = con.execute(sql)
            rows = res.fetchall()
            columns = [d[0] for d in res.description]
        except Exception as e:
            rows = []
            columns = ["ERROR"]
            rows = [(str(e),)]
            print(f"      ERROR: {e}")

        # Bloque por query
        bloque = [
            f"## {ruta.stem} — {titulo}",
            "",
        ]
        if comentario:
            bloque.append(f"_{comentario.splitlines()[0]}_  ")
            for ln in comentario.splitlines()[1:]:
                bloque.append(ln)
            bloque.append("")
        bloque.append("**SQL:**")
        bloque.append("")
        bloque.append("```sql")
        bloque.append(sql)
        bloque.append("```")
        bloque.append("")
        nota_filas = f" (mostrando primeras {MAX_FILAS_TABLA})" if len(rows) > MAX_FILAS_TABLA else ""
        bloque.append(f"**Resultado** — {len(rows)} filas{nota_filas}:")
        bloque.append("")
        bloque.append(df_a_markdown(rows, columns))
        bloque.append("")
        bloque.append("---")
        bloque.append("")

        contenido = "\n".join(bloque)
        (DIR_RESULTADOS / f"{ruta.stem}.md").write_text(contenido, encoding="utf-8")
        resumen_lineas.append(contenido)

    RUTA_RESUMEN.write_text("\n".join(resumen_lineas), encoding="utf-8")
    con.close()

    tam = RUTA_RESUMEN.stat().st_size / 1024
    print(f"\nGenerado {RUTA_RESUMEN.name} ({tam:.1f} KB) con {len(queries)} secciones.")
    print(f"Resultados individuales en {DIR_RESULTADOS.name}/")


if __name__ == "__main__":
    main()
