-- =============================================================
-- 02. TOP 10 ANIOS DE MAYOR INFLACION EN LA HISTORIA RECIENTE
-- =============================================================
-- DEMUESTRA: subquery escalar, RANK() OVER, JOIN a vista
-- con eventos macro para contextualizar cada anio extremo.
--
-- Cruza el ranking con los eventos historicos para que el lector
-- vea inmediatamente por que ese anio fue tan inflacionario.
-- =============================================================

SELECT
    RANK() OVER (ORDER BY w.inflacion_pct DESC) AS posicion,
    w.anio,
    ROUND(w.inflacion_pct, 2)                    AS inflacion_pct,
    ROUND(w.pib_crecimiento_pct, 2)              AS pib_crecimiento_pct,
    COALESCE(STRING_AGG(e.evento, ' / '), '')    AS contexto
FROM indicadores_wide w
LEFT JOIN eventos_macro e ON e.anio = w.anio
WHERE w.inflacion_pct IS NOT NULL
GROUP BY w.anio, w.inflacion_pct, w.pib_crecimiento_pct
ORDER BY w.inflacion_pct DESC
LIMIT 10;
