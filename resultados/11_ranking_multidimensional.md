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

**Resultado** — 12 filas:

| anio | pib_pct | inflacion | desempleo | ied_bn | score | cuartil_global | clasificacion |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2024 | 1.43 | 4.72 | 2.68 | 45.5 | 46 | 1 | Excelente |
| 2022 | 3.71 | 7.9 | 3.26 | 39.2 | 47 | 1 | Excelente |
| 2006 | 4.81 | 3.63 | 3.57 | 22.1 | 48 | 1 | Excelente |
| 2016 | 1.77 | 2.82 | 3.85 | 38.9 | 49 | 1 | Excelente |
| 2015 | 2.7 | 2.72 | 4.31 | 36.3 | 49 | 1 | Excelente |
| 2023 | 3.35 | 5.53 | 2.77 | 30.7 | 51 | 1 | Excelente |
| 2018 | 1.97 | 4.9 | 3.28 | 37.9 | 53 | 1 | Excelente |
| 2021 | 6.05 | 5.69 | 4.02 | 35.6 | 54 | 1 | Excelente |
| 2007 | 2.08 | 3.97 | 3.63 | 31 | 56 | 1 | Excelente |
| 2000 | 5.03 | 9.49 | 2.65 | 18.4 | 57 | 2 | Bueno |
| 2010 | 4.97 | 4.16 | 5.3 | 30.5 | 61 | 2 | Bueno |
| 2005 | 2.11 | 3.99 | 3.56 | 25.2 | 61 | 2 | Bueno |

---
