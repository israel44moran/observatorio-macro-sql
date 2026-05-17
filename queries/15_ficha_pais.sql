-- =============================================================
-- 15. FICHA RESUMEN DEL PAIS: ULTIMO DATO DISPONIBLE x INDICADOR
-- =============================================================
-- DEMUESTRA: subquery escalar dentro de subquery, DISTINCT ON
-- (DuckDB), JOIN con catalogo para etiquetar y formato.
--
-- Es la "ficha de Mexico" que un analista usaria para abrir un
-- informe: cada indicador mostrado con su ultimo valor publicado
-- y el anio al que corresponde.
-- =============================================================

WITH ultimo_valor AS (
    SELECT DISTINCT ON (indicador)
        indicador,
        anio,
        valor
    FROM indicadores_long
    ORDER BY indicador, anio DESC
),
hace_10 AS (
    SELECT DISTINCT ON (indicador)
        indicador,
        valor                                AS valor_hace_10a
    FROM indicadores_long
    WHERE anio <= (SELECT MAX(anio) FROM indicadores_long) - 10
    ORDER BY indicador, anio DESC
)
SELECT
    c.nombre                                                                   AS indicador,
    c.unidad,
    u.anio                                                                     AS anio_ultimo,
    CASE
        WHEN ABS(u.valor) >= 1e9  THEN ROUND(u.valor / 1e9,  2)  || ' bn'
        WHEN ABS(u.valor) >= 1e6  THEN ROUND(u.valor / 1e6,  2)  || ' mn'
        WHEN ABS(u.valor) >= 1000 THEN ROUND(u.valor, 0)         || ''
        ELSE                           ROUND(u.valor, 2)         || ''
    END                                                                        AS ultimo_valor,
    ROUND(((u.valor - h.valor_hace_10a) / NULLIF(h.valor_hace_10a, 0)) * 100, 1)
        || ' %'                                                                AS cambio_10a
FROM catalogo_indicadores c
LEFT JOIN ultimo_valor u ON u.indicador = c.columna
LEFT JOIN hace_10      h ON h.indicador = c.columna
ORDER BY c.columna;
