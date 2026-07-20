## 09_brecha_demografica_economica — BRECHA: CRECIMIENTO POBLACIONAL vs CRECIMIENTO ECONOMICO

_DEMUESTRA: dos CTEs encadenadas, calculo de tasas YoY con LAG,_  
diferencia entre dos tasas de crecimiento.
Si el PIB crece 2% pero la poblacion crece 1.5%, el PIB per
capita real solo crece 0.5%. Esta query muestra esa brecha.

**SQL:**

```sql
WITH crecimientos AS (
    SELECT
        anio,
        poblacion,
        pib_nominal_usd,
        LAG(poblacion)        OVER (ORDER BY anio) AS pob_prev,
        LAG(pib_nominal_usd)  OVER (ORDER BY anio) AS pib_prev
    FROM indicadores_wide
    WHERE poblacion IS NOT NULL
      AND pib_nominal_usd IS NOT NULL
),
tasas AS (
    SELECT
        anio,
        ROUND(((poblacion - pob_prev) / pob_prev) * 100, 3)        AS crec_pob_pct,
        ROUND(((pib_nominal_usd - pib_prev) / pib_prev) * 100, 2)  AS crec_pib_pct
    FROM crecimientos
    WHERE pob_prev IS NOT NULL
)
SELECT
    anio,
    crec_pob_pct,
    crec_pib_pct,
    ROUND(crec_pib_pct - crec_pob_pct, 2) AS brecha,
    CASE
        WHEN crec_pib_pct - crec_pob_pct > 3  THEN 'Mejora fuerte del bienestar'
        WHEN crec_pib_pct - crec_pob_pct > 0  THEN 'Mejora marginal'
        WHEN crec_pib_pct - crec_pob_pct > -3 THEN 'Estancamiento'
        ELSE 'Retroceso real'
    END                                   AS interpretacion
FROM tasas
WHERE anio >= 2000
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


LINE 15:         ROUND(((poblacion - pob_prev) / pob_prev) * 100, 3)        AS crec_pob_pct,
                                   ^ |

---
