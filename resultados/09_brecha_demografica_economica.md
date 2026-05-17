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

**Resultado** — 25 filas (mostrando primeras 15):

| anio | crec_pob_pct | crec_pib_pct | brecha | interpretacion |
| --- | --- | --- | --- | --- |
| 2024 | 0.864 | 3.23 | 2.37 | Mejora marginal |
| 2023 | 0.876 | 22.59 | 21.71 | Mejora fuerte del bienestar |
| 2022 | 0.756 | 11.42 | 10.66 | Mejora fuerte del bienestar |
| 2021 | 0.67 | 17.44 | 16.77 | Mejora fuerte del bienestar |
| 2020 | 0.824 | -14.04 | -14.86 | Retroceso real |
| 2019 | 0.955 | 3.81 | 2.86 | Mejora marginal |
| 2018 | 0.951 | 5.51 | 4.56 | Mejora fuerte del bienestar |
| 2017 | 0.94 | 7.06 | 6.12 | Mejora fuerte del bienestar |
| 2016 | 0.974 | -8.33 | -9.3 | Retroceso real |
| 2015 | 1.075 | -11.08 | -12.16 | Retroceso real |
| 2014 | 1.217 | 2.79 | 1.57 | Mejora marginal |
| 2013 | 1.306 | 5.76 | 4.45 | Mejora fuerte del bienestar |
| 2012 | 1.366 | 2.12 | 0.75 | Mejora marginal |
| 2011 | 1.425 | 11.18 | 9.75 | Mejora fuerte del bienestar |
| 2010 | 1.45 | 17.17 | 15.72 | Mejora fuerte del bienestar |

---
