-- =============================================================
-- EJERCICIO 03 — INDICADORES DEL SEXENIO DE SALINAS
-- =============================================================
-- HABILIDAD : WHERE con BETWEEN
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Devuelve PIB nominal (en billones USD), crecimiento del PIB,
--   inflacion y desempleo para cada anio del sexenio de Carlos
--   Salinas (1989-1994). Ordena por anio ascendente.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    anio,
    ROUND(pib_nominal_usd / 1e9, 1) AS pib_bn,
    ROUND(pib_crecimiento_pct, 2)   AS pib_crecimiento_pct,
    ROUND(inflacion_pct, 2)         AS inflacion_pct,
    ROUND(desempleo_pct, 2)         AS desempleo_pct
FROM indicadores_wide
WHERE anio BETWEEN 1989 AND 1994
ORDER BY anio;
