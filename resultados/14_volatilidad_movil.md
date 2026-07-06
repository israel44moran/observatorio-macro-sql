## 14_volatilidad_movil — VOLATILIDAD MOVIL DEL PIB (DESVIACION ESTANDAR EN VENTANA)

_DEMUESTRA: STDDEV() OVER (window), interpretacion: anios de_  
mayor turbulencia macro.
Mide la volatilidad del crecimiento del PIB en una ventana
movil de 5 anios. Anios con desv. estandar alta = epocas
inestables (crisis o transiciones de regimen).

**SQL:**

```sql
SELECT
    anio,
    ROUND(pib_crecimiento_pct, 2)                                                       AS pib_anual,
    ROUND(STDDEV(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2)                                                                               AS volatilidad_5a,
    ROUND(MAX(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) - MIN(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2)                                                                               AS rango_5a
FROM indicadores_wide
WHERE pib_crecimiento_pct IS NOT NULL
  AND anio >= 1970
ORDER BY volatilidad_5a DESC
LIMIT 15;
```

**Resultado** — 15 filas:

| anio | pib_anual | volatilidad_5a | rango_5a |
| --- | --- | --- | --- |
| 1983 | -4.62 | 6.61 | 14.32 |
| 1984 | 3.51 | 5.98 | 14.21 |
| 2023 | 3.11 | 5.62 | 14.4 |
| 2024 | 1.35 | 5.58 | 14.4 |
| 2022 | 3.71 | 5.53 | 14.4 |
| 1998 | 6.19 | 5.42 | 13.11 |
| 1999 | 2.76 | 5.41 | 13.11 |
| 2021 | 6.05 | 5.33 | 14.4 |
| 1997 | 7.2 | 5.23 | 13.11 |
| 1985 | 1.92 | 5.19 | 14.21 |
| 1996 | 6.22 | 4.72 | 12.13 |
| 2010 | 4.97 | 4.59 | 11.27 |
| 2013 | 0.85 | 4.5 | 11.27 |
| 2012 | 3.55 | 4.5 | 11.27 |
| 2020 | -8.35 | 4.43 | 10.33 |

---
