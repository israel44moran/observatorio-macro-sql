-- =============================================================
-- EJERCICIO 24 — IED ACUMULADA HISTORICA
-- =============================================================
-- HABILIDAD : SUM() OVER (ORDER BY ...) sin ROWS BETWEEN
--             (acumulado desde el inicio hasta cada fila)
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Muestra el monto de IED anual y el total acumulado
--   historico, ambos en miles de millones de USD. Sin
--   especificar ROWS BETWEEN, SUM() OVER (ORDER BY) hace un
--   "running total" hasta la fila actual.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    anio,
    ROUND(ied_usd / 1e9, 2)                                   AS ied_anual_bn,
    ROUND(SUM(ied_usd) OVER (ORDER BY anio) / 1e9, 2)         AS ied_acumulada_bn
FROM indicadores_wide
WHERE ied_usd IS NOT NULL
ORDER BY anio;
