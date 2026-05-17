-- =============================================================
-- EJERCICIO 15 — CLASIFICAR CADA ANIO POR DESEMPENO ECONOMICO
-- =============================================================
-- HABILIDAD : CASE WHEN para crear categorias derivadas
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Clasifica cada anio segun el crecimiento del PIB:
--     - "Crisis"   si crecimiento < 0
--     - "Estancamiento" si crecimiento entre 0 y 2 %
--     - "Normal"   si crecimiento entre 2 % y 5 %
--     - "Bonanza"  si crecimiento >= 5 %
--   Devuelve un conteo de cuantos anios cayeron en cada
--   categoria, ordenado de mayor frecuencia a menor.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH clasificacion AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        CASE
            WHEN pib_crecimiento_pct <  0  THEN 'Crisis'
            WHEN pib_crecimiento_pct <  2  THEN 'Estancamiento'
            WHEN pib_crecimiento_pct <  5  THEN 'Normal'
            ELSE                                 'Bonanza'
        END AS categoria
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
)
SELECT
    categoria,
    COUNT(*)                       AS n_anios,
    ROUND(AVG(pib_crecimiento_pct), 2) AS crecimiento_promedio
FROM clasificacion
GROUP BY categoria
ORDER BY n_anios DESC;
