-- =============================================================
-- 06. DETECCION AUTOMATICA DE RECESIONES (PIB DECRECIENTE)
-- =============================================================
-- DEMUESTRA: LAG() para comparar con anio anterior, CASE con
-- multiples condiciones, JOIN con eventos para contexto.
--
-- Definicion practica: anio con crecimiento del PIB negativo.
-- Tambien marcamos si el anio siguiente tambien fue negativo
-- (recesion "doble") o si vino seguido de recuperacion fuerte.
-- =============================================================

WITH crecimiento AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        LAG(pib_crecimiento_pct)  OVER (ORDER BY anio) AS pib_anterior,
        LEAD(pib_crecimiento_pct) OVER (ORDER BY anio) AS pib_siguiente
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
)
SELECT
    c.anio,
    ROUND(c.pib_crecimiento_pct, 2)                     AS crecimiento,
    ROUND(c.pib_anterior,         2)                    AS anio_previo,
    ROUND(c.pib_siguiente,        2)                    AS anio_siguiente,
    CASE
        WHEN c.pib_anterior  < 0 THEN 'Recesion encadenada'
        WHEN c.pib_siguiente < 0 THEN 'Continuara cayendo'
        WHEN c.pib_siguiente > 3 THEN 'Recuperacion fuerte (rebote)'
        ELSE 'Recesion aislada'
    END                                                 AS patron,
    COALESCE(e.evento, '-')                             AS evento_contexto
FROM crecimiento c
LEFT JOIN eventos_macro e ON e.anio = c.anio
WHERE c.pib_crecimiento_pct < 0
ORDER BY c.anio;
