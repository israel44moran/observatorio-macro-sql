-- =============================================================
-- EJERCICIO 29 — PUNTOS DE INFLEXION EN EL CRECIMIENTO DEL PIB
-- =============================================================
-- HABILIDAD : LAG + LEAD + SIGN para detectar cambio de signo
-- DIFICULTAD: avanzado
--
-- PROBLEMA:
--   Un "punto de inflexion" es un anio en el que el signo del
--   crecimiento del PIB cambia respecto al anio anterior
--   (de positivo a negativo o viceversa). Identifica todos
--   estos anios desde 1970.
--
--   Tip: SIGN() devuelve -1, 0 o 1 segun el signo del numero.
--   Si SIGN(actual) != SIGN(anterior) hay cambio de signo.
--
-- TABLA: indicadores_wide
-- =============================================================

WITH con_lag AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        LAG(pib_crecimiento_pct) OVER (ORDER BY anio) AS pib_anterior
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
      AND anio >= 1970
)
SELECT
    anio,
    ROUND(pib_anterior, 2)        AS pib_anterior,
    ROUND(pib_crecimiento_pct, 2) AS pib_actual,
    CASE
        WHEN pib_anterior > 0 AND pib_crecimiento_pct < 0 THEN 'Entra en recesion'
        WHEN pib_anterior < 0 AND pib_crecimiento_pct > 0 THEN 'Sale de recesion'
    END AS tipo_inflexion
FROM con_lag
WHERE pib_anterior IS NOT NULL
  AND SIGN(pib_crecimiento_pct) != SIGN(pib_anterior)
  AND pib_crecimiento_pct != 0
  AND pib_anterior != 0
ORDER BY anio;
