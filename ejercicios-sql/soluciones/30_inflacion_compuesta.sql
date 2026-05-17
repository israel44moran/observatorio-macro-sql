-- =============================================================
-- EJERCICIO 30 — INFLACION COMPUESTA POR SEXENIO (PRODUCTO ACUMULADO)
-- =============================================================
-- HABILIDAD : producto acumulado via EXP(SUM(LN(...))) — truco
--             clasico SQL para multiplicar valores agregados
-- DIFICULTAD: avanzado (joya de entrevista)
--
-- PROBLEMA:
--   Calcula la inflacion ACUMULADA REAL de cada sexenio.
--   La inflacion no se promedia, se multiplica:
--     acumulada = (1 + i1)(1 + i2)...(1 + iN) - 1
--   SQL no tiene PROD() pero usando logaritmos:
--     producto = EXP(SUM(LN(x))) si todos los x > 0
--
--   Esto es lo que diferencia un analista que conoce SQL de
--   uno que SOLO conoce SQL. Pregunta clasica en bancos.
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
    sexenio,
    COUNT(*)                                                      AS anios,
    ROUND(AVG(inflacion_pct), 2)                                  AS inf_promedio_anual,
    ROUND((EXP(SUM(LN(1 + inflacion_pct / 100))) - 1) * 100, 1)   AS inf_acumulada,
    -- Equivalente: la "tasa promedio geometrica" que reproduce la acumulada
    ROUND((POWER(1 + (EXP(SUM(LN(1 + inflacion_pct / 100))) - 1),
                  1.0 / COUNT(*)) - 1) * 100, 2)                  AS tasa_geometrica_anual
FROM por_sexenio
WHERE sexenio IS NOT NULL
GROUP BY sexenio
ORDER BY sexenio;
