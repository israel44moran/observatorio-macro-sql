-- =============================================================
-- EJERCICIO 26 — TRES CTEs ENCADENADAS PARA ANALISIS MULTI-PASO
-- =============================================================
-- HABILIDAD : multiples CTEs en secuencia donde cada una usa la previa
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Construye un analisis en 3 pasos usando CTEs encadenadas:
--     (1) base      : anio + crecimiento del PIB
--     (2) con_lag   : agregar el crecimiento del anio anterior
--     (3) cambios   : calcular el cambio (este_anio - anterior)
--                     y rankear por magnitud del cambio
--   Devuelve los 10 anios con mayor cambio brusco (positivo o
--   negativo) en el crecimiento del PIB respecto al anio
--   anterior.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH base AS (
    SELECT anio, pib_crecimiento_pct
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
),
con_lag AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        LAG(pib_crecimiento_pct) OVER (ORDER BY anio) AS pib_anterior
    FROM base
),
cambios AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        pib_anterior,
        pib_crecimiento_pct - pib_anterior            AS cambio,
        ABS(pib_crecimiento_pct - pib_anterior)       AS magnitud
    FROM con_lag
    WHERE pib_anterior IS NOT NULL
)
SELECT
    anio,
    ROUND(pib_anterior, 2)         AS pib_anterior,
    ROUND(pib_crecimiento_pct, 2)  AS pib_actual,
    ROUND(cambio, 2)               AS cambio
FROM cambios
ORDER BY magnitud DESC
LIMIT 10;
