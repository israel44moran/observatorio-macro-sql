-- =============================================================
-- 13. DEUDA EXTERNA vs INVERSION EXTRANJERA DIRECTA
-- =============================================================
-- DEMUESTRA: ratio entre dos series, agregacion acumulada con
-- SUM() OVER, calculo de "anios para repagar" usando IED.
--
-- Dos formas de capital del exterior: deuda (que se paga con
-- intereses) e IED (que invierte y compra activos). Esta query
-- mide su balance historico.
-- =============================================================

WITH base AS (
    SELECT
        anio,
        deuda_externa_usd,
        ied_usd,
        SUM(ied_usd) OVER (ORDER BY anio)              AS ied_acumulada
    FROM indicadores_wide
    WHERE deuda_externa_usd IS NOT NULL
      AND ied_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(deuda_externa_usd / 1e9, 1)                  AS deuda_bn,
    ROUND(ied_usd / 1e9, 1)                            AS ied_anual_bn,
    ROUND(ied_acumulada / 1e9, 1)                      AS ied_acumulada_bn,
    ROUND(deuda_externa_usd / NULLIF(ied_usd, 0), 1)   AS ratio_deuda_ied_anual,
    ROUND(deuda_externa_usd / NULLIF(ied_acumulada, 0), 2) AS ratio_deuda_ied_acumulada
FROM base
WHERE anio >= 1990
ORDER BY anio DESC;
