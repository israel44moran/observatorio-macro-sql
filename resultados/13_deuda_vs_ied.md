## 13_deuda_vs_ied — DEUDA EXTERNA vs INVERSION EXTRANJERA DIRECTA

_DEMUESTRA: ratio entre dos series, agregacion acumulada con_  
SUM() OVER, calculo de "anios para repagar" usando IED.
Dos formas de capital del exterior: deuda (que se paga con
intereses) e IED (que invierte y compra activos). Esta query
mide su balance historico.

**SQL:**

```sql
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
```

**Resultado** — 35 filas (mostrando primeras 15):

| anio | deuda_bn | ied_anual_bn | ied_acumulada_bn | ratio_deuda_ied_anual | ratio_deuda_ied_acumulada |
| --- | --- | --- | --- | --- | --- |
| 2024 | 591.3 | 45.5 | 864.8 | 13 | 0.68 |
| 2023 | 596 | 30.7 | 819.4 | 19.4 | 0.73 |
| 2022 | 585.9 | 39.2 | 788.7 | 14.9 | 0.74 |
| 2021 | 601.5 | 35.6 | 749.5 | 16.9 | 0.8 |
| 2020 | 616.7 | 31.5 | 713.9 | 19.5 | 0.86 |
| 2019 | 617.4 | 29.9 | 682.3 | 20.6 | 0.9 |
| 2018 | 602 | 37.9 | 652.4 | 15.9 | 0.92 |
| 2017 | 578.6 | 33.1 | 614.5 | 17.5 | 0.94 |
| 2016 | 544.8 | 38.9 | 581.4 | 14 | 0.94 |
| 2015 | 538 | 36.3 | 542.5 | 14.8 | 0.99 |
| 2014 | 544.2 | 28.4 | 506.2 | 19.1 | 1.08 |
| 2013 | 504.1 | 50.9 | 477.8 | 9.9 | 1.06 |
| 2012 | 433 | 18.2 | 426.8 | 23.7 | 1.01 |
| 2011 | 351.7 | 23.9 | 408.6 | 14.7 | 0.86 |
| 2010 | 312.3 | 30.5 | 384.7 | 10.2 | 0.81 |

---
