-- =============================================================
-- 01. EVOLUCION DEL PIB CON VARIACION YEAR-OVER-YEAR
-- =============================================================
-- DEMUESTRA: window functions LAG() y ROW_NUMBER() OVER (ORDER BY).
--
-- Para cada anio, recupera el PIB del anio anterior con LAG(),
-- calcula el delta y el porcentaje de variacion. Limita a los
-- ultimos 15 anios para hacer el resultado legible.
-- =============================================================

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
