-- =============================================================
-- EJERCICIO 21 — VARIACION YEAR-OVER-YEAR DEL PIB CON LAG
-- =============================================================
-- HABILIDAD : window function LAG() OVER (ORDER BY ...)
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Para cada anio, muestra el PIB nominal, el PIB del anio
--   anterior (usando LAG), la diferencia absoluta y el % de
--   variacion. Solo desde 2010.
--
--   LAG() es la funcion window mas pedida en entrevistas: te
--   permite acceder al valor de la fila previa sin self-join.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH pib_lag AS (
    SELECT
        anio,
        pib_nominal_usd                                       AS pib_actual,
        LAG(pib_nominal_usd) OVER (ORDER BY anio)             AS pib_anterior
    FROM indicadores_wide
    WHERE pib_nominal_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(pib_actual / 1e9, 1)                                AS pib_bn,
    ROUND(pib_anterior / 1e9, 1)                              AS pib_anterior_bn,
    ROUND((pib_actual - pib_anterior) / 1e9, 1)               AS delta_bn,
    ROUND(((pib_actual - pib_anterior) / pib_anterior) * 100, 2) AS variacion_pct
FROM pib_lag
WHERE anio >= 2010
ORDER BY anio;
