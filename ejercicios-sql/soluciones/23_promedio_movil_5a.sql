-- =============================================================
-- EJERCICIO 23 — PROMEDIO MOVIL DE 5 ANIOS DEL CRECIMIENTO
-- =============================================================
-- HABILIDAD : AVG() OVER (ORDER BY ... ROWS BETWEEN N PRECEDING)
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Calcula el promedio movil de 5 anios del crecimiento del
--   PIB usando una ventana ROWS BETWEEN 4 PRECEDING AND
--   CURRENT ROW (incluye el anio actual + los 4 previos).
--   Devuelve solo desde 2000 para que el output sea legible.
--
--   Las ventanas moviles son LA herramienta para suavizar
--   series de tiempo en SQL.
--
-- TABLA: indicadores_wide
-- =============================================================

SELECT
    anio,
    ROUND(pib_crecimiento_pct, 2) AS pib_anual,
    ROUND(
        AVG(pib_crecimiento_pct) OVER (
            ORDER BY anio
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        ), 2
    ) AS promedio_movil_5a
FROM indicadores_wide
WHERE pib_crecimiento_pct IS NOT NULL
  AND anio >= 2000
ORDER BY anio;
