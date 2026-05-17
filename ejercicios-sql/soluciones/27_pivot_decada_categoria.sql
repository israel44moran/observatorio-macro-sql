-- =============================================================
-- EJERCICIO 27 — PIVOT: ANIOS POR DECADA × CATEGORIA DE EVENTO
-- =============================================================
-- HABILIDAD : PIVOT manual con COUNT(*) FILTER por categoria
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Construye una tabla pivot: filas = decada, columnas =
--   categoria de evento (crisis, regimen, tratado, externo),
--   valor = cuantos eventos de esa categoria ocurrieron en
--   esa decada. Tip: FILTER es la sintaxis moderna (SQL:2003);
--   alternativa: CASE WHEN ... END dentro de COUNT().
--
-- TABLA: eventos_macro
-- =============================================================

SELECT
    (FLOOR(anio / 10) * 10) || 's'                   AS decada,
    COUNT(*) FILTER (WHERE categoria = 'crisis')     AS crisis,
    COUNT(*) FILTER (WHERE categoria = 'regimen')    AS regimen,
    COUNT(*) FILTER (WHERE categoria = 'tratado')    AS tratado,
    COUNT(*) FILTER (WHERE categoria = 'externo')    AS externo,
    COUNT(*)                                         AS total
FROM eventos_macro
GROUP BY FLOOR(anio / 10) * 10
ORDER BY decada;
