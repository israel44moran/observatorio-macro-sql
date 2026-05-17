-- =============================================================
-- EJERCICIO 05 — INFLACION PROMEDIO HISTORICA Y POR DECADA
-- =============================================================
-- HABILIDAD : AVG simple + AVG con GROUP BY por decada
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Calcula la inflacion promedio simple de toda la historia y
--   tambien la inflacion promedio por decada. Devuelve dos
--   queries separadas:
--     a) una sola fila con el promedio global
--     b) una fila por decada
--
-- TABLA: indicadores_wide
-- =============================================================

-- (a) Promedio global
SELECT
    ROUND(AVG(inflacion_pct), 2) AS inflacion_promedio_global
FROM indicadores_wide
WHERE inflacion_pct IS NOT NULL;

-- (b) Promedio por decada
SELECT
    (FLOOR(anio / 10) * 10) || 's' AS decada,
    ROUND(AVG(inflacion_pct), 2)   AS inflacion_promedio
FROM indicadores_wide
WHERE inflacion_pct IS NOT NULL
GROUP BY FLOOR(anio / 10) * 10
ORDER BY decada;
