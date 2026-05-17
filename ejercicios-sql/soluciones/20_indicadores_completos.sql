-- =============================================================
-- EJERCICIO 20 — INDICADORES CON MAS DE 50 OBSERVACIONES
-- =============================================================
-- HABILIDAD : GROUP BY + HAVING + JOIN con catalogo
-- DIFICULTAD: intermedio
--
-- PROBLEMA:
--   Lista los indicadores que tienen mas de 50 observaciones
--   registradas en indicadores_long. Para cada uno, muestra
--   nombre legible, codigo del Banco Mundial, conteo y la
--   ventana temporal (anio min y max).
--
-- TABLAS: indicadores_long, catalogo_indicadores
-- =============================================================

SELECT
    c.nombre,
    c.codigo_wb,
    COUNT(*) AS n_observaciones,
    MIN(l.anio) AS anio_inicio,
    MAX(l.anio) AS anio_fin
FROM indicadores_long l
INNER JOIN catalogo_indicadores c ON c.columna = l.indicador
GROUP BY c.columna, c.nombre, c.codigo_wb
HAVING COUNT(*) > 50
ORDER BY n_observaciones DESC;
