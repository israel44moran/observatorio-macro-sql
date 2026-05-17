-- =============================================================
-- EJERCICIO 08 — PIB MINIMO Y MAXIMO DESDE 2000
-- =============================================================
-- HABILIDAD : MIN, MAX con filtro WHERE + escala numerica
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Desde el anio 2000 inclusive, encuentra el PIB nominal
--   minimo y maximo (en billones USD), junto con su anio
--   correspondiente. Devuelve una sola fila con 4 columnas.
--
--   Pista: el "anio del minimo/maximo" requiere una subquery o
--   un truco con first_value / argmin. Usa subqueries por
--   simplicidad.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    ROUND(MIN(pib_nominal_usd) / 1e9, 1) AS pib_min_bn,
    (SELECT anio FROM indicadores_wide
     WHERE anio >= 2000 AND pib_nominal_usd IS NOT NULL
     ORDER BY pib_nominal_usd ASC LIMIT 1)           AS anio_min,
    ROUND(MAX(pib_nominal_usd) / 1e9, 1) AS pib_max_bn,
    (SELECT anio FROM indicadores_wide
     WHERE anio >= 2000 AND pib_nominal_usd IS NOT NULL
     ORDER BY pib_nominal_usd DESC LIMIT 1)          AS anio_max
FROM indicadores_wide
WHERE anio >= 2000 AND pib_nominal_usd IS NOT NULL;
