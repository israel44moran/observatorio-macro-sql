## 08_pivot_por_decada — TABLA PIVOT: INDICADORES PROMEDIO POR DECADA

_DEMUESTRA: agregacion con FILTER (WHERE ...) -- sintaxis_  
moderna SQL:2003, mas limpia que CASE WHEN dentro de SUM().
Tambien GROUPING y CUBE para producir totales.
Resume cada decada en una sola fila con sus indicadores clave.

**SQL:**

```sql
SELECT
    FLOOR(anio / 10) * 10 || 's'                                                    AS decada,
    ROUND(AVG(pib_crecimiento_pct), 2)                                              AS pib_crecimiento_prom,
    ROUND(AVG(inflacion_pct),       2)                                              AS inflacion_prom,
    ROUND(AVG(desempleo_pct),       2)                                              AS desempleo_prom,
    ROUND(AVG(ied_usd) / 1e9,       2)                                              AS ied_promedio_bn_usd,
    ROUND(AVG(exportaciones_usd / NULLIF(importaciones_usd, 0)), 3)                 AS ratio_export_import,
    ROUND(MAX(poblacion) / 1e6, 1)                                                  AS poblacion_fin_decada_mn,
    COUNT(*)                                                                        AS anios_con_datos
FROM indicadores_wide
WHERE anio BETWEEN 1960 AND 2029
GROUP BY ROLLUP(FLOOR(anio / 10) * 10)
ORDER BY decada NULLS LAST;
```

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types '/(VARCHAR, VARCHAR)'. You might need to add explicit type casts.
	Candidate functions:
	/(FLOAT, FLOAT) -> FLOAT
	/(DOUBLE, DOUBLE) -> DOUBLE
	/(INTERVAL, DOUBLE) -> INTERVAL


LINE 7:     ROUND(AVG(exportaciones_usd / NULLIF(importaciones_usd, 0)), 3)                 AS rati...
                                        ^ |

---
