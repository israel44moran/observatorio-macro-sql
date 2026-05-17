-- =============================================================
-- EJERCICIO 22 — RANKING DE INFLACION DENTRO DE CADA DECADA
-- =============================================================
-- HABILIDAD : ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Para cada decada, asigna un ranking (1, 2, 3...) a los
--   anios segun su inflacion descendente. Devuelve solo el
--   peor anio (rank = 1) de cada decada. Tip: PARTITION BY
--   "particiona" la ventana en grupos antes de aplicar la
--   funcion.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH ranked AS (
    SELECT
        anio,
        inflacion_pct,
        FLOOR(anio / 10) * 10 AS decada,
        ROW_NUMBER() OVER (
            PARTITION BY FLOOR(anio / 10) * 10
            ORDER BY inflacion_pct DESC
        ) AS rk
    FROM indicadores_wide
    WHERE inflacion_pct IS NOT NULL
)
SELECT
    decada || 's' AS decada,
    anio          AS peor_anio,
    ROUND(inflacion_pct, 2) AS inflacion_pct
FROM ranked
WHERE rk = 1
ORDER BY decada;
