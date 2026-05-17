-- =============================================================
-- EJERCICIO 25 — CUARTILES DE CRECIMIENTO DEL PIB CON NTILE
-- =============================================================
-- HABILIDAD : NTILE(n) para dividir el resultado en n grupos iguales
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Divide todos los anios en 4 cuartiles segun su crecimiento
--   del PIB (1 = peor cuartil, 4 = mejor). Muestra los limites
--   de cada cuartil: anio min, anio max, crecimiento min y
--   max dentro del cuartil.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH cuartiles AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        NTILE(4) OVER (ORDER BY pib_crecimiento_pct) AS cuartil
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
)
SELECT
    cuartil,
    COUNT(*)                              AS n_anios,
    MIN(anio)                             AS anio_min,
    MAX(anio)                             AS anio_max,
    ROUND(MIN(pib_crecimiento_pct), 2)    AS crecimiento_min,
    ROUND(MAX(pib_crecimiento_pct), 2)    AS crecimiento_max,
    ROUND(AVG(pib_crecimiento_pct), 2)    AS crecimiento_prom
FROM cuartiles
GROUP BY cuartil
ORDER BY cuartil;
