## 05_saldo_comercial — SALDO COMERCIAL Y SU EVOLUCION

_DEMUESTRA: aritmetica entre columnas, CASE para clasificacion,_  
window function SUM() OVER (ORDER BY) para acumulado y
variacion vs el promedio movil con AVG OVER (ROWS BETWEEN).
Mexico paso de un modelo cerrado a una de las economias mas
abiertas tras el TLCAN. Aqui visualizamos el efecto.

**SQL:**

```sql
WITH comercio AS (
    SELECT
        anio,
        exportaciones_usd,
        importaciones_usd,
        exportaciones_usd - importaciones_usd                                AS saldo,
        AVG(exportaciones_usd - importaciones_usd) OVER (
            ORDER BY anio
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        )                                                                    AS saldo_promedio_5a
    FROM indicadores_wide
    WHERE exportaciones_usd IS NOT NULL
      AND importaciones_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(exportaciones_usd / 1e9, 1)             AS exp_bn_usd,
    ROUND(importaciones_usd / 1e9, 1)             AS imp_bn_usd,
    ROUND(saldo / 1e9, 1)                         AS saldo_bn_usd,
    ROUND(saldo_promedio_5a / 1e9, 1)             AS saldo_prom_5a_bn,
    CASE
        WHEN saldo > 0 THEN 'Superavit'
        ELSE 'Deficit'
    END                                           AS clasificacion
FROM comercio
WHERE anio >= 1990
ORDER BY anio DESC;
```

**Resultado** — 35 filas (mostrando primeras 15):

| anio | exp_bn_usd | imp_bn_usd | saldo_bn_usd | saldo_prom_5a_bn | clasificacion |
| --- | --- | --- | --- | --- | --- |
| 2024 | 681.3 | 703.3 | -21.9 | -19.6 | Deficit |
| 2023 | 648.6 | 674.5 | -25.9 | -16.3 | Deficit |
| 2022 | 629.8 | 672.8 | -43 | -16.5 | Deficit |
| 2021 | 534.1 | 559.5 | -25.4 | -12.4 | Deficit |
| 2020 | 439.9 | 421.7 | 18.1 | -11.9 | Superavit |
| 2019 | 502.5 | 507.7 | -5.3 | -20.6 | Deficit |
| 2018 | 490.5 | 517.2 | -26.7 | -22.8 | Deficit |
| 2017 | 446.7 | 469.6 | -22.9 | -20.6 | Deficit |
| 2016 | 409.5 | 432.4 | -22.9 | -18.9 | Deficit |
| 2015 | 414.5 | 439.8 | -25.3 | -17.5 | Deficit |
| 2014 | 429.3 | 445.3 | -16 | -15.2 | Deficit |
| 2013 | 408.3 | 423.9 | -15.7 | -14.9 | Deficit |
| 2012 | 395.9 | 410.7 | -14.8 | -17.2 | Deficit |
| 2011 | 374.1 | 389.8 | -15.7 | -18 | Deficit |
| 2010 | 320.8 | 334.5 | -13.7 | -17.6 | Deficit |

---
