-- =============================================================
-- EJERCICIO 13 — ANIOS CON PIB SUPERIOR AL PROMEDIO HISTORICO
-- =============================================================
-- HABILIDAD : subquery escalar en WHERE
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Encuentra los anios cuyo PIB nominal estuvo por encima del
--   promedio historico de toda la serie. Devuelve anio, PIB en
--   billones USD y diferencia vs el promedio (tambien en bn).
--   Ordena por la diferencia, mayor primero.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    anio,
    ROUND(pib_nominal_usd / 1e9, 1) AS pib_bn,
    ROUND((pib_nominal_usd - (SELECT AVG(pib_nominal_usd) FROM indicadores_wide)) / 1e9, 1)
        AS diferencia_vs_promedio_bn
FROM indicadores_wide
WHERE pib_nominal_usd > (SELECT AVG(pib_nominal_usd) FROM indicadores_wide)
ORDER BY diferencia_vs_promedio_bn DESC
LIMIT 15;
