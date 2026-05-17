-- =============================================================
-- EJERCICIO 01 — TOP 10 ANIOS DE MAYOR PIB NOMINAL
-- =============================================================
-- HABILIDAD : SELECT + ORDER BY DESC + LIMIT
-- DIFICULTAD: facil
--
-- PROBLEMA:
--   Lista los 10 anios con el PIB nominal mas alto, mostrando
--   el anio y el PIB convertido a miles de millones (billones) de USD,
--   redondeado a 1 decimal. Ordenar de mayor a menor PIB.
--
-- TABLA: indicadores_wide
-- COLUMNAS: anio, pib_nominal_usd
-- =============================================================

SELECT
    anio,
    ROUND(pib_nominal_usd / 1e9, 1) AS pib_billones_usd
FROM indicadores_wide
WHERE pib_nominal_usd IS NOT NULL
ORDER BY pib_nominal_usd DESC
LIMIT 10;
