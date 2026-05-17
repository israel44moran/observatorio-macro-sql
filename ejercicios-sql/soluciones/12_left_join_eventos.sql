-- =============================================================
-- EJERCICIO 12 — TODOS LOS ANIOS CON SU EVENTO (SI EXISTE)
-- =============================================================
-- HABILIDAD : LEFT JOIN + COALESCE
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Devuelve todos los anios desde 1970 con el evento macro
--   asociado. Si un anio no tiene evento, mostrar "Sin evento"
--   en lugar de NULL. Limita a los ultimos 25 anios para que
--   el output sea manejable.
--
-- TABLAS: indicadores_wide (izquierda), eventos_macro (derecha)
-- =============================================================

SELECT
    w.anio,
    ROUND(w.pib_crecimiento_pct, 2) AS pib_pct,
    COALESCE(e.evento, 'Sin evento') AS evento
FROM indicadores_wide w
LEFT JOIN eventos_macro e ON e.anio = w.anio
WHERE w.anio >= 2000
ORDER BY w.anio;
