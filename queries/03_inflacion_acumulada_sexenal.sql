-- =============================================================
-- 03. INFLACION ACUMULADA COMPUESTA POR SEXENIO
-- =============================================================
-- DEMUESTRA: CTE + CASE WHEN para segmentar por sexenio,
-- producto acumulado via EXP(SUM(LN(...))) -- truco clasico SQL
-- para multiplicar valores en una agregacion.
--
-- En Mexico el ejecutivo dura 6 anios. Calculamos cuanto subieron
-- los precios en TOTAL durante cada periodo presidencial.
--   inflacion_acumulada = (1 + i1) * (1 + i2) * ... * (1 + i6) - 1
-- =============================================================

WITH inflacion_por_sexenio AS (
    SELECT
        CASE
            WHEN anio BETWEEN 1970 AND 1976 THEN '1970-1976  Echeverría'
            WHEN anio BETWEEN 1977 AND 1982 THEN '1977-1982  López Portillo'
            WHEN anio BETWEEN 1983 AND 1988 THEN '1983-1988  De la Madrid'
            WHEN anio BETWEEN 1989 AND 1994 THEN '1989-1994  Salinas'
            WHEN anio BETWEEN 1995 AND 2000 THEN '1995-2000  Zedillo'
            WHEN anio BETWEEN 2001 AND 2006 THEN '2001-2006  Fox'
            WHEN anio BETWEEN 2007 AND 2012 THEN '2007-2012  Calderón'
            WHEN anio BETWEEN 2013 AND 2018 THEN '2013-2018  Peña Nieto'
            WHEN anio BETWEEN 2019 AND 2024 THEN '2019-2024  López Obrador'
        END                              AS sexenio,
        anio,
        inflacion_pct
    FROM indicadores_wide
    WHERE inflacion_pct IS NOT NULL
      AND anio BETWEEN 1970 AND 2024
)
SELECT
    sexenio,
    COUNT(*)                                                                     AS anios_con_dato,
    ROUND(AVG(inflacion_pct), 2)                                                 AS inflacion_promedio_anual,
    ROUND((EXP(SUM(LN(1 + inflacion_pct / 100))) - 1) * 100, 1)                  AS inflacion_acumulada_pct,
    ROUND(MAX(inflacion_pct), 2)                                                 AS peor_anio_pct,
    ROUND(MIN(inflacion_pct), 2)                                                 AS mejor_anio_pct
FROM inflacion_por_sexenio
WHERE sexenio IS NOT NULL
GROUP BY sexenio
ORDER BY sexenio;
