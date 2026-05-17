-- =============================================================
-- EJERCICIO 14 — DECADAS CON INFLACION PROMEDIO MAYOR A 10 %
-- =============================================================
-- HABILIDAD : GROUP BY + HAVING (filtrar agregaciones)
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Lista las decadas en las que la inflacion promedio anual
--   supero el 10 %. La diferencia clave entre WHERE y HAVING
--   es que HAVING filtra DESPUES de agregar.
--   Devuelve: decada, inflacion promedio, peor anio de la
--   decada (con su inflacion).
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    (FLOOR(anio / 10) * 10) || 's'           AS decada,
    ROUND(AVG(inflacion_pct), 2)             AS inflacion_promedio,
    MAX(inflacion_pct)                       AS peor_inflacion
FROM indicadores_wide
WHERE inflacion_pct IS NOT NULL
GROUP BY FLOOR(anio / 10) * 10
HAVING AVG(inflacion_pct) > 10
ORDER BY inflacion_promedio DESC;
