-- =============================================================
-- EJERCICIO 19 — TOP 5 MEJORES Y TOP 5 PEORES ANIOS DE PIB
-- =============================================================
-- HABILIDAD : UNION ALL para combinar resultados de dos queries
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   En una sola tabla, devuelve los 5 mejores y los 5 peores
--   anios por crecimiento del PIB. Incluye una columna
--   "tipo" que diga "Mejor" o "Peor" para distinguirlos.
--
-- TABLA: indicadores_wide
-- =============================================================

(
    SELECT
        anio,
        ROUND(pib_crecimiento_pct, 2) AS pib_pct,
        'Mejor' AS tipo
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
    ORDER BY pib_crecimiento_pct DESC
    LIMIT 5
)
UNION ALL
(
    SELECT
        anio,
        ROUND(pib_crecimiento_pct, 2) AS pib_pct,
        'Peor' AS tipo
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
    ORDER BY pib_crecimiento_pct ASC
    LIMIT 5
)
ORDER BY tipo, pib_pct DESC;
