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

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types '/(VARCHAR, DOUBLE)'. You might need to add explicit type casts.
	Candidate functions:
	/(FLOAT, FLOAT) -> FLOAT
	/(DOUBLE, DOUBLE) -> DOUBLE
	/(INTERVAL, DOUBLE) -> INTERVAL


LINE 12:     ROUND(pib_actual / 1e9, 1)                                            AS...
                              ^ |

---
