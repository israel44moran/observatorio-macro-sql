-- =============================================================
-- EJERCICIO 10 — VALIDAR EL PIB PER CAPITA REPORTADO
-- =============================================================
-- HABILIDAD : aritmetica entre columnas + ROUND + WHERE
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Calcula manualmente el PIB per capita (pib_nominal_usd /
--   poblacion) y comparalo con el valor pib_per_capita_usd
--   reportado por el Banco Mundial. Muestra anio, los dos
--   valores y la diferencia absoluta. Limita a los ultimos
--   10 anios.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    anio,
    ROUND(pib_per_capita_usd, 2)                    AS pib_pc_reportado,
    ROUND(pib_nominal_usd / poblacion, 2)           AS pib_pc_calculado,
    ROUND(ABS(pib_per_capita_usd - pib_nominal_usd / poblacion), 2) AS diferencia
FROM indicadores_wide
WHERE pib_per_capita_usd IS NOT NULL
  AND pib_nominal_usd IS NOT NULL
  AND poblacion IS NOT NULL
ORDER BY anio DESC
LIMIT 10;
