-- =============================================================
-- EJERCICIO 09 — ANIOS SIN REGISTRO DE DESEMPLEO
-- =============================================================
-- HABILIDAD : WHERE con IS NULL
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Lista los anios para los cuales NO existe registro de la
--   tasa de desempleo. Devuelve solo la columna anio, ordenada
--   ascendentemente.
--
-- TABLA: indicadores_wide
-- COLUMNAS: anio, desempleo_pct
-- =============================================================

SELECT anio
FROM indicadores_wide
WHERE desempleo_pct IS NULL
ORDER BY anio;
