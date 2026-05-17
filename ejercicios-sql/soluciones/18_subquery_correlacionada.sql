-- =============================================================
-- EJERCICIO 18 — INFLACION EN EL ANIO DE CADA EVENTO
-- =============================================================
-- HABILIDAD : subquery correlacionada (se ejecuta por cada fila externa)
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Para cada evento de eventos_macro, recupera la inflacion
--   del anio del evento usando una subquery correlacionada
--   en el SELECT. Compara con el promedio de los 3 anios
--   previos al evento (otra subquery correlacionada).
--
-- TABLAS: eventos_macro, indicadores_wide
-- =============================================================

SELECT
    e.anio,
    e.evento,
    (
        SELECT ROUND(inflacion_pct, 2)
        FROM indicadores_wide
        WHERE anio = e.anio
    ) AS inflacion_en_evento,
    (
        SELECT ROUND(AVG(inflacion_pct), 2)
        FROM indicadores_wide
        WHERE anio BETWEEN e.anio - 3 AND e.anio - 1
          AND inflacion_pct IS NOT NULL
    ) AS inflacion_promedio_3a_previa
FROM eventos_macro e
ORDER BY e.anio;
