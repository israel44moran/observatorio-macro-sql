"""Ejecuta los 30 ejercicios de SQL contra analisis.duckdb y verifica
que todos corran sin error. Util como CI o para validar despues de
modificar la base.

Uso:
    python verificar.py             # ejecuta todos, resume al final
    python verificar.py 21          # ejecuta solo ese ejercicio y muestra el output
"""
from __future__ import annotations

import sys
from pathlib import Path

import duckdb

DIR = Path(__file__).parent
RUTA_DB = DIR.parent / "analisis.duckdb"
DIR_SOL = DIR / "soluciones"


def cargar_query(ruta: Path) -> str:
    """Devuelve el SQL crudo del archivo (sin parseo)."""
    return ruta.read_text(encoding="utf-8")


def split_statements(sql: str) -> list[str]:
    """Divide por punto y coma, descarta comentarios y vacios."""
    stmts = []
    for part in sql.split(";"):
        part = part.strip()
        if not part:
            continue
        # Mantener solo si tiene al menos una linea de codigo (no solo comentarios)
        if any(ln.strip() and not ln.strip().startswith("--") for ln in part.splitlines()):
            stmts.append(part)
    return stmts


def ejecutar_uno(con, ruta: Path, mostrar: bool = False) -> bool:
    """Ejecuta un .sql. Devuelve True si todo OK."""
    try:
        for stmt in split_statements(cargar_query(ruta)):
            res = con.execute(stmt)
            if mostrar:
                df = res.df()
                print()
                if df.empty:
                    print("  (sin filas)")
                else:
                    print(df.head(15).to_string(index=False))
                    if len(df) > 15:
                        print(f"  ... ({len(df) - 15} filas mas)")
        return True
    except Exception as e:
        print(f"  ERROR: {e}")
        return False


def main() -> None:
    if not RUTA_DB.exists():
        print(f"Falta {RUTA_DB}. Corre antes: python cargar_db.py", file=sys.stderr)
        sys.exit(1)

    con = duckdb.connect(str(RUTA_DB), read_only=True)
    archivos = sorted(DIR_SOL.glob("*.sql"))

    # Modo "uno solo": python verificar.py 21
    if len(sys.argv) > 1:
        try:
            n = int(sys.argv[1])
        except ValueError:
            print(f"Argumento invalido: {sys.argv[1]}")
            sys.exit(2)
        match = [a for a in archivos if a.name.startswith(f"{n:02d}_")]
        if not match:
            print(f"No encuentro ejercicio {n:02d}")
            sys.exit(3)
        ruta = match[0]
        print(f"=== {ruta.name} ===")
        ok = ejecutar_uno(con, ruta, mostrar=True)
        print(f"\nResultado: {'OK' if ok else 'FAIL'}")
        sys.exit(0 if ok else 1)

    # Modo "todos": validacion rapida
    print(f"Validando {len(archivos)} ejercicios contra {RUTA_DB.name}...")
    print()
    ok_count = 0
    for ruta in archivos:
        result = ejecutar_uno(con, ruta, mostrar=False)
        marca = "OK  " if result else "FAIL"
        print(f"  [{marca}] {ruta.name}")
        if result:
            ok_count += 1

    print()
    print("=" * 60)
    if ok_count == len(archivos):
        print(f"Resultado: {ok_count}/{len(archivos)} ejercicios OK")
    else:
        print(f"Resultado: {ok_count}/{len(archivos)} OK, {len(archivos) - ok_count} fallidos")
        sys.exit(1)


if __name__ == "__main__":
    main()
