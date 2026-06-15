## 05_saldo_comercial — SALDO COMERCIAL Y SU EVOLUCION

_DEMUESTRA: aritmetica entre columnas, CASE para clasificacion,_  
window function SUM() OVER (ORDER BY) para acumulado y
variacion vs el promedio movil con AVG OVER (ROWS BETWEEN).
Mexico paso de un modelo cerrado a una de las economias mas
abiertas tras el TLCAN. Aqui visualizamos el efecto.

**SQL:**

```sql
WITH comercio AS (
    SELECT
        anio,
        exportaciones_usd,
        importaciones_usd,
        exportaciones_usd - importaciones_usd                                AS saldo,
        AVG(exportaciones_usd - importaciones_usd) OVER (
            ORDER BY anio
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        )                                                                    AS saldo_promedio_5a
    FROM indicadores_wide
    WHERE exportaciones_usd IS NOT NULL
      AND importaciones_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(exportaciones_usd / 1e9, 1)             AS exp_bn_usd,
    ROUND(importaciones_usd / 1e9, 1)             AS imp_bn_usd,
    ROUND(saldo / 1e9, 1)                         AS saldo_bn_usd,
    ROUND(saldo_promedio_5a / 1e9, 1)             AS saldo_prom_5a_bn,
    CASE
        WHEN saldo > 0 THEN 'Superavit'
        ELSE 'Deficit'
    END                                           AS clasificacion
FROM comercio
WHERE anio >= 1990
ORDER BY anio DESC;
```

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types '-(VARCHAR, VARCHAR)'. You might need to add explicit type casts.
	Candidate functions:
	-(TINYINT) -> TINYINT
	-(TINYINT, TINYINT) -> TINYINT
	-(SMALLINT) -> SMALLINT
	-(SMALLINT, SMALLINT) -> SMALLINT
	-(INTEGER) -> INTEGER
	-(INTEGER, INTEGER) -> INTEGER
	-(BIGINT) -> BIGINT
	-(BIGINT, BIGINT) -> BIGINT
	-(HUGEINT) -> HUGEINT
	-(HUGEINT, HUGEINT) -> HUGEINT
	-(FLOAT) -> FLOAT
	-(FLOAT, FLOAT) -> FLOAT
	-(DOUBLE) -> DOUBLE
	-(DOUBLE, DOUBLE) -> DOUBLE
	-(DECIMAL) -> DECIMAL
	-(DECIMAL, DECIMAL) -> DECIMAL
	-(UTINYINT) -> UTINYINT
	-(UTINYINT, UTINYINT) -> UTINYINT
	-(USMALLINT) -> USMALLINT
	-(USMALLINT, USMALLINT) -> USMALLINT
	-(UINTEGER) -> UINTEGER
	-(UINTEGER, UINTEGER) -> UINTEGER
	-(UBIGINT) -> UBIGINT
	-(UBIGINT, UBIGINT) -> UBIGINT
	-(UHUGEINT) -> UHUGEINT
	-(UHUGEINT, UHUGEINT) -> UHUGEINT
	-(BIGNUM) -> BIGNUM
	-(BIGNUM, BIGNUM) -> BIGNUM
	-(DATE, DATE) -> BIGINT
	-(DATE, INTEGER) -> DATE
	-(TIMESTAMP, TIMESTAMP) -> INTERVAL
	-(INTERVAL, INTERVAL) -> INTERVAL
	-(DATE, INTERVAL) -> TIMESTAMP
	-(TIME, INTERVAL) -> TIME
	-(TIMESTAMP, INTERVAL) -> TIMESTAMP
	-(TIME WITH TIME ZONE, INTERVAL) -> TIME WITH TIME ZONE
	-(INTERVAL) -> INTERVAL
	-(TIMESTAMP WITH TIME ZONE, INTERVAL) -> TIMESTAMP WITH TIME ZONE
	-(TIMESTAMP WITH TIME ZONE, TIMESTAMP WITH TIME ZONE) -> INTERVAL


LINE 6:         exportaciones_usd - importaciones_usd                                AS saldo...
                                  ^ |

---
