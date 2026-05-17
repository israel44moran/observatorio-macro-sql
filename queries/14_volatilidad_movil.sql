-- =============================================================
-- 14. VOLATILIDAD MOVIL DEL PIB (DESVIACION ESTANDAR EN VENTANA)
-- =============================================================
-- DEMUESTRA: STDDEV() OVER (window), interpretacion: anios de
-- mayor turbulencia macro.
--
-- Mide la volatilidad del crecimiento del PIB en una ventana
-- movil de 5 anios. Anios con desv. estandar alta = epocas
-- inestables (crisis o transiciones de regimen).
-- =============================================================

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
