-- =============================================================
-- 10. EVENTOS MACRO: PROMEDIOS ANTES vs DESPUES
-- =============================================================
-- DEMUESTRA: self-join entre la tabla eventos_macro y la tabla
-- de indicadores, agregacion bilateral (5 anos antes vs 5
-- despues) en una sola query con subqueries correlacionadas.
--
-- Para cada evento importante de la historia mexicana, calcula
-- como se vio afectado el PIB y la inflacion 5 anios antes
-- versus 5 anios despues del evento.
-- =============================================================

SELECT
    e.anio                                        AS anio_evento,
    e.evento,
    e.categoria,
    (
        SELECT ROUND(AVG(pib_crecimiento_pct), 2)
        FROM indicadores_wide
        WHERE anio BETWEEN e.anio - 5 AND e.anio - 1
          AND pib_crecimiento_pct IS NOT NULL
    )                                             AS pib_prom_5a_antes,
    (
        SELECT ROUND(AVG(pib_crecimiento_pct), 2)
        FROM indicadores_wide
        WHERE anio BETWEEN e.anio + 1 AND e.anio + 5
          AND pib_crecimiento_pct IS NOT NULL
    )                                             AS pib_prom_5a_despues,
    (
        SELECT ROUND(AVG(inflacion_pct), 2)
        FROM indicadores_wide
        WHERE anio BETWEEN e.anio - 5 AND e.anio - 1
          AND inflacion_pct IS NOT NULL
    )                                             AS inflacion_prom_5a_antes,
    (
        SELECT ROUND(AVG(inflacion_pct), 2)
        FROM indicadores_wide
        WHERE anio BETWEEN e.anio + 1 AND e.anio + 5
          AND inflacion_pct IS NOT NULL
    )                                             AS inflacion_prom_5a_despues
FROM eventos_macro e
ORDER BY e.anio;
