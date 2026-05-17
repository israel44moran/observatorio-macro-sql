-- =============================================================
-- 07. PROMEDIO MOVIL DEL CRECIMIENTO DEL PIB (3 / 5 / 10 ANIOS)
-- =============================================================
-- DEMUESTRA: tres window functions AVG() OVER con diferentes
-- ventanas ROWS BETWEEN ... PRECEDING para suavizar la serie y
-- separar el ruido coyuntural de la tendencia estructural.
--
-- El crecimiento anual del PIB es muy volatil. Los promedios
-- moviles revelan si Mexico esta en una era de alto o bajo
-- crecimiento estructural.
-- =============================================================

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
