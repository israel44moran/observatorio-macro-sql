-- =============================================================
-- EJERCICIO 02 — ANIOS CON INFLACION ALTA
-- =============================================================
-- HABILIDAD : WHERE con comparacion numerica + ORDER BY
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Lista todos los anios en los que la inflacion anual fue
--   mayor a 50 %. Muestra el anio y el valor de inflacion
--   redondeado a 2 decimales. Ordena del peor al mejor.
--
-- TABLA: indicadores_wide
-- COLUMNAS: anio, inflacion_pct
-- =============================================================

SELECT
    anio,
    ROUND(inflacion_pct, 2) AS inflacion_pct
FROM indicadores_wide
WHERE inflacion_pct > 50
ORDER BY inflacion_pct DESC;
