## 10_eventos_antes_despues — EVENTOS MACRO: PROMEDIOS ANTES vs DESPUES

_DEMUESTRA: self-join entre la tabla eventos_macro y la tabla_  
de indicadores, agregacion bilateral (5 anos antes vs 5
despues) en una sola query con subqueries correlacionadas.
Para cada evento importante de la historia mexicana, calcula
como se vio afectado el PIB y la inflacion 5 anios antes
versus 5 anios despues del evento.

**SQL:**

```sql
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
```

**Resultado** — 13 filas:

| anio_evento | evento | categoria | pib_prom_5a_antes | pib_prom_5a_despues | inflacion_prom_5a_antes | inflacion_prom_5a_despues |
| --- | --- | --- | --- | --- | --- | --- |
| 1976 | Devaluación del peso | crisis | 6.27 | 8.08 | 12.24 | 23.8 |
| 1982 | Crisis de la deuda externa | crisis | 8.08 | -0.21 | 23.8 | 88.63 |
| 1988 | Inicio del periodo de Salinas | regimen | -0.21 | 3.86 | 88.63 | 18.92 |
| 1994 | Entrada en vigor del TLCAN | tratado | 3.86 | 3.29 | 18.92 | 24.5 |
| 1995 | Crisis del Tequila | crisis | 4.01 | 5.48 | 16.31 | 19.4 |
| 2000 | Alternancia política: Fox / PAN | regimen | 3.29 | 1.24 | 24.5 | 4.92 |
| 2001 | Recesión EUA post-9/11 | externo | 5.48 | 2.29 | 19.4 | 4.38 |
| 2006 | Inicio periodo de Calderón | regimen | 1.24 | 1.03 | 4.92 | 4.39 |
| 2009 | Crisis financiera global | crisis | 2.7 | 3.06 | 4.28 | 3.9 |
| 2012 | Inicio periodo de Peña Nieto | regimen | 1.03 | 1.94 | 4.39 | 3.88 |
| 2018 | Inicio periodo de López Obrador (AMLO) | regimen | 1.94 | 0.82 | 3.88 | 5.23 |
| 2020 | Pandemia COVID-19 | crisis | 1.59 | 2.96 | 4.02 | 5.53 |
| 2024 | Inicio periodo de Sheinbaum | regimen | 0.82 | 0.56 | 5.23 | 3.81 |

---
