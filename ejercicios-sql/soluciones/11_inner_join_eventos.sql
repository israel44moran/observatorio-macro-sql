-- =============================================================
-- EJERCICIO 11 — EVENTOS CON SU CONTEXTO ECONOMICO
-- =============================================================
-- HABILIDAD : INNER JOIN entre dos tablas
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Para cada evento de la tabla eventos_macro, muestra el
--   evento, su anio, el crecimiento del PIB y la inflacion de
--   ese mismo anio. Solo eventos con datos economicos
--   disponibles. Ordena por anio.
--
-- TABLAS: eventos_macro, indicadores_wide
-- =============================================================

SELECT
    e.anio,
    e.evento,
    e.categoria,
    ROUND(w.pib_crecimiento_pct, 2) AS pib_crecimiento_pct,
    ROUND(w.inflacion_pct, 2)       AS inflacion_pct
FROM eventos_macro e
INNER JOIN indicadores_wide w ON w.anio = e.anio
WHERE w.pib_crecimiento_pct IS NOT NULL
  AND w.inflacion_pct IS NOT NULL
ORDER BY e.anio;
