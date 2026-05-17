-- =============================================================
-- EJERCICIO 17 — AUDITORIA DE VALORES FALTANTES POR INDICADOR
-- =============================================================
-- HABILIDAD : COUNT con FILTER, conteo de NULLs
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Para cada indicador del catalogo, calcula cuantos NULLs
--   tiene en la tabla indicadores_wide y que porcentaje de
--   completitud representa.
--   Pista: usa la tabla long para evitar tener que listar
--   las 15 columnas a mano.
--
-- TABLAS: catalogo_indicadores, indicadores_long, indicadores_wide
-- =============================================================

SELECT
    c.nombre                                                         AS indicador,
    c.unidad,
    COUNT(*) FILTER (WHERE l.valor IS NOT NULL)                      AS con_dato,
    (SELECT COUNT(*) FROM indicadores_wide) -
        COUNT(*) FILTER (WHERE l.valor IS NOT NULL)                  AS faltantes,
    ROUND(100.0 * COUNT(*) FILTER (WHERE l.valor IS NOT NULL) /
                  (SELECT COUNT(*) FROM indicadores_wide), 1)        AS completitud_pct
FROM catalogo_indicadores c
LEFT JOIN indicadores_long l ON l.indicador = c.columna
GROUP BY c.columna, c.nombre, c.unidad
ORDER BY completitud_pct DESC;
