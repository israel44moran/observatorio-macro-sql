-- =============================================================
-- EJERCICIO 28 — INFLACION PROMEDIO POR SEXENIO + SUBTOTAL CON ROLLUP
-- =============================================================
-- HABILIDAD : GROUP BY ROLLUP() para agregar subtotales jerarquicos
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Inflacion promedio por sexenio entre 1970 y 2024. Al final
--   agregar una fila "TOTAL" con el promedio global usando
--   GROUP BY ROLLUP, que es la forma SQL estandar de producir
--   subtotales sin escribir una segunda query.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH por_sexenio AS (
    SELECT
        CASE
            WHEN anio BETWEEN 1970 AND 1976 THEN '1970-1976 Echeverria'
            WHEN anio BETWEEN 1977 AND 1982 THEN '1977-1982 Lopez Portillo'
            WHEN anio BETWEEN 1983 AND 1988 THEN '1983-1988 De la Madrid'
            WHEN anio BETWEEN 1989 AND 1994 THEN '1989-1994 Salinas'
            WHEN anio BETWEEN 1995 AND 2000 THEN '1995-2000 Zedillo'
            WHEN anio BETWEEN 2001 AND 2006 THEN '2001-2006 Fox'
            WHEN anio BETWEEN 2007 AND 2012 THEN '2007-2012 Calderon'
            WHEN anio BETWEEN 2013 AND 2018 THEN '2013-2018 Pena Nieto'
            WHEN anio BETWEEN 2019 AND 2024 THEN '2019-2024 Lopez Obrador'
        END AS sexenio,
        inflacion_pct
    FROM indicadores_wide
    WHERE inflacion_pct IS NOT NULL
      AND anio BETWEEN 1970 AND 2024
)
SELECT
    COALESCE(sexenio, '— TOTAL —')      AS periodo,
    COUNT(*)                            AS anios,
    ROUND(AVG(inflacion_pct), 2)        AS inflacion_promedio
FROM por_sexenio
WHERE sexenio IS NOT NULL
GROUP BY ROLLUP(sexenio)
ORDER BY periodo NULLS FIRST;
