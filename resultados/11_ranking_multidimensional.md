## 11_ranking_multidimensional — RANKING MULTIDIMENSIONAL DE ANIOS

_DEMUESTRA: multiples RANK() OVER, NTILE para quartiles,_  
agregacion ponderada con CASE WHEN.
Cada anio se evalua en 4 dimensiones (crecimiento, inflacion,
desempleo, IED). Se le asigna un "rank" en cada una y se
calcula un score compuesto para identificar los anios
"mas buenos" o "mas malos" macroeconomicamente.

**SQL:**

```sql
WITH ranked AS (
    SELECT
        anio,
        ROUND(pib_crecimiento_pct, 2) AS pib_pct,
        ROUND(inflacion_pct, 2)       AS inflacion,
        ROUND(desempleo_pct, 2)       AS desempleo,
        ROUND(ied_usd / 1e9, 1)       AS ied_bn,
        -- Mejor = mayor crecimiento => DESC
        RANK() OVER (ORDER BY pib_crecimiento_pct DESC NULLS LAST) AS rank_crecimiento,
        -- Mejor = menor inflacion => ASC
        RANK() OVER (ORDER BY inflacion_pct ASC NULLS LAST)        AS rank_inflacion,
        -- Mejor = menor desempleo => ASC
        RANK() OVER (ORDER BY desempleo_pct ASC NULLS LAST)        AS rank_desempleo,
        -- Mejor = mayor IED => DESC
        RANK() OVER (ORDER BY ied_usd DESC NULLS LAST)             AS rank_ied
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
      AND inflacion_pct IS NOT NULL
      AND desempleo_pct IS NOT NULL
      AND ied_usd IS NOT NULL
),
con_score AS (
    SELECT *,
        rank_crecimiento + rank_inflacion + rank_desempleo + rank_ied AS score
    FROM ranked
)
SELECT
    anio, pib_pct, inflacion, desempleo, ied_bn,
    score,
    NTILE(4) OVER (ORDER BY score)                                  AS cuartil_global,
    CASE NTILE(4) OVER (ORDER BY score)
        WHEN 1 THEN 'Excelente'
        WHEN 2 THEN 'Bueno'
        WHEN 3 THEN 'Regular'
        WHEN 4 THEN 'Dificil'
    END                                                             AS clasificacion
FROM con_score
ORDER BY score
LIMIT 12;
```

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types 'round(VARCHAR, INTEGER_LITERAL)'. You might need to add explicit type casts.
	Candidate functions:
	round(TINYINT) -> TINYINT
	round(TINYINT, INTEGER) -> TINYINT
	round(SMALLINT) -> SMALLINT
	round(SMALLINT, INTEGER) -> SMALLINT
	round(INTEGER) -> INTEGER
	round(INTEGER, INTEGER) -> INTEGER
	round(BIGINT) -> BIGINT
	round(BIGINT, INTEGER) -> BIGINT
	round(HUGEINT) -> HUGEINT
	round(HUGEINT, INTEGER) -> HUGEINT
	round(FLOAT) -> FLOAT
	round(FLOAT, INTEGER) -> FLOAT
	round(DOUBLE) -> DOUBLE
	round(DOUBLE, INTEGER) -> DOUBLE
	round(DECIMAL) -> DECIMAL
	round(DECIMAL, INTEGER) -> DECIMAL


LINE 6:         ROUND(desempleo_pct, 2)       AS desempleo,
                ^ |

---
