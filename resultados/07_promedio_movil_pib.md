## 07_promedio_movil_pib — PROMEDIO MOVIL DEL CRECIMIENTO DEL PIB (3 / 5 / 10 ANIOS)

_DEMUESTRA: tres window functions AVG() OVER con diferentes_  
ventanas ROWS BETWEEN ... PRECEDING para suavizar la serie y
separar el ruido coyuntural de la tendencia estructural.
El crecimiento anual del PIB es muy volatil. Los promedios
moviles revelan si Mexico esta en una era de alto o bajo
crecimiento estructural.

**SQL:**

```sql
SELECT
    anio,
    ROUND(pib_crecimiento_pct, 2)                                                                  AS pib_anual,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS prom_movil_3a,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 4 PRECEDING AND CURRENT ROW), 2) AS prom_movil_5a,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 9 PRECEDING AND CURRENT ROW), 2) AS prom_movil_10a
FROM indicadores_wide
WHERE pib_crecimiento_pct IS NOT NULL
  AND anio >= 1990
ORDER BY anio DESC;
```

**Resultado** — 35 filas (mostrando primeras 15):

| anio | pib_anual | prom_movil_3a | prom_movil_5a | prom_movil_10a |
| --- | --- | --- | --- | --- |
| 2024 | 1.43 | 2.83 | 1.24 | 1.41 |
| 2023 | 3.35 | 4.37 | 0.87 | 1.52 |
| 2022 | 3.71 | 0.47 | 0.6 | 1.27 |
| 2021 | 6.05 | -0.9 | 0.23 | 1.25 |
| 2020 | -8.35 | -2.26 | -0.63 | 0.99 |
| 2019 | -0.39 | 1.15 | 1.59 | 2.33 |
| 2018 | 1.97 | 1.87 | 2.16 | 1.73 |
| 2017 | 1.87 | 2.12 | 1.94 | 1.63 |
| 2016 | 1.77 | 2.33 | 2.28 | 1.65 |
| 2015 | 2.7 | 2.02 | 2.61 | 1.96 |
| 2014 | 2.5 | 2.3 | 3.06 | 1.9 |
| 2013 | 0.85 | 2.62 | 1.31 | 2 |
| 2012 | 3.55 | 3.99 | 1.32 | 2.04 |
| 2011 | 3.44 | 0.71 | 1.03 | 1.66 |
| 2010 | 4.97 | -0.13 | 1.3 | 1.27 |

---
