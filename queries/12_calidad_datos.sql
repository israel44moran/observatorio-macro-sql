-- =============================================================
-- 12. AUDITORIA DE CALIDAD DE DATOS
-- =============================================================
-- DEMUESTRA: agregacion sobre la tabla long, JOIN con catalogo,
-- calculo de completitud y deteccion de gaps en la serie.
--
-- Para cada indicador reporta cobertura temporal, % de
-- completitud y si hay anios "huecos" dentro del rango cubierto.
-- =============================================================

WITH stats AS (
    SELECT
        c.columna,
        c.nombre,
        c.unidad,
        MIN(l.anio)                                      AS anio_inicio,
        MAX(l.anio)                                      AS anio_fin,
        COUNT(*)                                         AS n_observaciones,
        MAX(l.anio) - MIN(l.anio) + 1                    AS rango_esperado,
        ROUND(COUNT(*) * 100.0 / (MAX(l.anio) - MIN(l.anio) + 1), 1) AS completitud_pct
    FROM catalogo_indicadores c
    LEFT JOIN indicadores_long l ON l.indicador = c.columna
    GROUP BY c.columna, c.nombre, c.unidad
)
SELECT
    nombre,
    unidad,
    anio_inicio,
    anio_fin,
    rango_esperado || ' anios'             AS rango,
    n_observaciones                        AS observaciones,
    completitud_pct || ' %'                AS completitud,
    CASE
        WHEN completitud_pct = 100 THEN 'OK'
        WHEN completitud_pct >  90 THEN 'Pocos huecos'
        WHEN completitud_pct >  50 THEN 'Cobertura parcial'
        ELSE                            'Serie corta o muy fragmentada'
    END                                    AS diagnostico
FROM stats
ORDER BY completitud_pct DESC, anio_inicio;
