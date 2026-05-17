-- =============================================================
-- EJERCICIO 06 — CONTEO DE EVENTOS POR CATEGORIA
-- =============================================================
-- HABILIDAD : GROUP BY + COUNT(*)
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Cuenta cuantos eventos hay en cada categoria de la tabla
--   eventos_macro. Ordena de mayor a menor cantidad.
--
-- TABLA: eventos_macro
-- COLUMNAS: categoria
-- =============================================================

SELECT
    categoria,
    COUNT(*) AS n_eventos
FROM eventos_macro
GROUP BY categoria
ORDER BY n_eventos DESC;
