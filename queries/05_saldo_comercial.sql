-- =============================================================
-- 05. SALDO COMERCIAL Y SU EVOLUCION
-- =============================================================
-- DEMUESTRA: aritmetica entre columnas, CASE para clasificacion,
-- window function SUM() OVER (ORDER BY) para acumulado y
-- variacion vs el promedio movil con AVG OVER (ROWS BETWEEN).
--
-- Mexico paso de un modelo cerrado a una de las economias mas
-- abiertas tras el TLCAN. Aqui visualizamos el efecto.
-- =============================================================

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
