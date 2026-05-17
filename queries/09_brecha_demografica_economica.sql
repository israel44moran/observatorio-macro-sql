-- =============================================================
-- 09. BRECHA: CRECIMIENTO POBLACIONAL vs CRECIMIENTO ECONOMICO
-- =============================================================
-- DEMUESTRA: dos CTEs encadenadas, calculo de tasas YoY con LAG,
-- diferencia entre dos tasas de crecimiento.
--
-- Si el PIB crece 2% pero la poblacion crece 1.5%, el PIB per
-- capita real solo crece 0.5%. Esta query muestra esa brecha.
-- =============================================================

WITH crecimientos AS (
    SELECT
        anio,
        poblacion,
        pib_nominal_usd,
        LAG(poblacion)        OVER (ORDER BY anio) AS pob_prev,
        LAG(pib_nominal_usd)  OVER (ORDER BY anio) AS pib_prev
    FROM indicadores_wide
    WHERE poblacion IS NOT NULL
      AND pib_nominal_usd IS NOT NULL
),
tasas AS (
    SELECT
        anio,
        ROUND(((poblacion - pob_prev) / pob_prev) * 100, 3)        AS crec_pob_pct,
        ROUND(((pib_nominal_usd - pib_prev) / pib_prev) * 100, 2)  AS crec_pib_pct
    FROM crecimientos
    WHERE pob_prev IS NOT NULL
)
SELECT
    anio,
    crec_pob_pct,
    crec_pib_pct,
    ROUND(crec_pib_pct - crec_pob_pct, 2) AS brecha,
    CASE
        WHEN crec_pib_pct - crec_pob_pct > 3  THEN 'Mejora fuerte del bienestar'
        WHEN crec_pib_pct - crec_pob_pct > 0  THEN 'Mejora marginal'
        WHEN crec_pib_pct - crec_pob_pct > -3 THEN 'Estancamiento'
        ELSE 'Retroceso real'
    END                                   AS interpretacion
FROM tasas
WHERE anio >= 2000
ORDER BY anio DESC;
