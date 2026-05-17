-- =============================================================
-- EJERCICIO 07 — CATEGORIAS DISTINTAS DE EVENTOS
-- =============================================================
-- HABILIDAD : DISTINCT + listado de valores unicos
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Devuelve la lista de categorias distintas que existen en
--   eventos_macro, ordenadas alfabeticamente.
--
-- TABLA: eventos_macro
-- =============================================================

SELECT DISTINCT categoria
FROM eventos_macro
ORDER BY categoria;
