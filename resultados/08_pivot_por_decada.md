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

**Resultado** — 8 filas:

| decada | pib_crecimiento_prom | inflacion_prom | desempleo_prom | ied_promedio_bn_usd | ratio_export_import | poblacion_fin_decada_mn | anios_con_datos |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1960.0s | 6.84 | 2.72 | — | — | 0.794 | 49.2 | 10 |
| 1970.0s | 6.43 | 14.68 | — | 0.53 | 0.871 | 65.6 | 10 |
| 1980.0s | 2.21 | 69.05 | — | 2.39 | 1.326 | 81.2 | 10 |
| 1990.0s | 3.65 | 20.41 | 4.15 | 8.54 | 0.918 | 97.1 | 10 |
| 2000.0s | 1.27 | 5.21 | 3.57 | 23.96 | 0.938 | 112 | 10 |
| 2010.0s | 2.33 | 3.96 | 4.34 | 32.81 | 0.959 | 125.8 | 10 |
| 2020.0s | 1.07 | 5.17 | 3.31 | 36.51 | 0.976 | 131.9 | 6 |
| — | 3.49 | 18.05 | 3.89 | 15.72 | 0.968 | 131.9 | 66 |

---
