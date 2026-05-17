-- =============================================================
-- EJERCICIO 04 — REGISTROS DE GINI Y RANGO TEMPORAL
-- =============================================================
-- HABILIDAD : COUNT con filtro IS NOT NULL + MIN / MAX
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Cuantos anios tienen registro del Indice de Gini y cual es
--   el rango temporal cubierto (primer y ultimo anio con dato).
--   Devuelve una sola fila con 3 columnas: count, anio_min, anio_max.
--
-- TABLA: indicadores_wide
-- COLUMNAS: anio, gini
-- =============================================================

SELECT
    COUNT(gini)         AS anios_con_gini,
    MIN(anio) FILTER (WHERE gini IS NOT NULL) AS anio_min,
    MAX(anio) FILTER (WHERE gini IS NOT NULL) AS anio_max
FROM indicadores_wide;
