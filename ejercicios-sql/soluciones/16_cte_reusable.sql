-- =============================================================
-- EJERCICIO 16 — CTE PARA REUSAR UN CALCULO
-- =============================================================
-- HABILIDAD : CTE (WITH) para evitar repetir una agregacion
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Para cada anio, indica si el desempleo estuvo por encima
--   o por debajo del promedio historico, y por cuantos puntos
--   porcentuales. Usa una CTE para calcular el promedio una
--   sola vez y reutilizarlo en el SELECT.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH stats AS (
    SELECT AVG(desempleo_pct) AS prom
    FROM indicadores_wide
    WHERE desempleo_pct IS NOT NULL
)
SELECT
    w.anio,
    ROUND(w.desempleo_pct, 2)                  AS desempleo,
    ROUND(stats.prom, 2)                       AS promedio_historico,
    ROUND(w.desempleo_pct - stats.prom, 2)     AS diferencia,
    CASE WHEN w.desempleo_pct > stats.prom
         THEN 'Encima' ELSE 'Debajo' END       AS posicion
FROM indicadores_wide w
CROSS JOIN stats
WHERE w.desempleo_pct IS NOT NULL
ORDER BY w.anio;
