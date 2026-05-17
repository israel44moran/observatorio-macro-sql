## 01_evolucion_pib_yoy — EVOLUCION DEL PIB CON VARIACION YEAR-OVER-YEAR

_DEMUESTRA: window functions LAG() y ROW_NUMBER() OVER (ORDER BY)._  
Para cada anio, recupera el PIB del anio anterior con LAG(),
calcula el delta y el porcentaje de variacion. Limita a los
ultimos 15 anios para hacer el resultado legible.

**SQL:**

```sql
WITH pib_con_lag AS (
    SELECT
        anio,
        pib_nominal_usd                                       AS pib_actual,
        LAG(pib_nominal_usd) OVER (ORDER BY anio)             AS pib_anterior,
        ROW_NUMBER()         OVER (ORDER BY anio DESC)        AS antiguedad
    FROM indicadores_wide
    WHERE pib_nominal_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(pib_actual / 1e9, 1)                                            AS pib_billones_usd,
    ROUND((pib_actual - pib_anterior) / 1e9, 1)                           AS delta_billones,
    ROUND(((pib_actual - pib_anterior) / pib_anterior) * 100, 2)          AS variacion_pct
FROM pib_con_lag
WHERE antiguedad <= 15
ORDER BY anio DESC;
```

**Resultado** — 15 filas:

| anio | pib_billones_usd | delta_billones | variacion_pct |
| --- | --- | --- | --- |
| 2024 | 1,856.4 | 58 | 3.23 |
| 2023 | 1,798.3 | 331.4 | 22.59 |
| 2022 | 1,466.9 | 150.4 | 11.42 |
| 2021 | 1,316.6 | 195.5 | 17.44 |
| 2020 | 1,121.1 | -183 | -14.04 |
| 2019 | 1,304.1 | 47.8 | 3.81 |
| 2018 | 1,256.3 | 65.6 | 5.51 |
| 2017 | 1,190.7 | 78.5 | 7.06 |
| 2016 | 1,112.2 | -101.1 | -8.33 |
| 2015 | 1,213.3 | -151.2 | -11.08 |
| 2014 | 1,364.5 | 37.1 | 2.79 |
| 2013 | 1,327.4 | 72.3 | 5.76 |
| 2012 | 1,255.1 | 26.1 | 2.12 |
| 2011 | 1,229 | 123.6 | 11.18 |
| 2010 | 1,105.4 | 162 | 17.17 |

---
