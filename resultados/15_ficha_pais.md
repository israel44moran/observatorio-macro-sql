## 15_ficha_pais — FICHA RESUMEN DEL PAIS: ULTIMO DATO DISPONIBLE x INDICADOR

_DEMUESTRA: subquery escalar dentro de subquery, DISTINCT ON_  
(DuckDB), JOIN con catalogo para etiquetar y formato.
Es la "ficha de Mexico" que un analista usaria para abrir un
informe: cada indicador mostrado con su ultimo valor publicado
y el anio al que corresponde.

**SQL:**

```sql
WITH ultimo_valor AS (
    SELECT DISTINCT ON (indicador)
        indicador,
        anio,
        valor
    FROM indicadores_long
    ORDER BY indicador, anio DESC
),
hace_10 AS (
    SELECT DISTINCT ON (indicador)
        indicador,
        valor                                AS valor_hace_10a
    FROM indicadores_long
    WHERE anio <= (SELECT MAX(anio) FROM indicadores_long) - 10
    ORDER BY indicador, anio DESC
)
SELECT
    c.nombre                                                                   AS indicador,
    c.unidad,
    u.anio                                                                     AS anio_ultimo,
    CASE
        WHEN ABS(u.valor) >= 1e9  THEN ROUND(u.valor / 1e9,  2)  || ' bn'
        WHEN ABS(u.valor) >= 1e6  THEN ROUND(u.valor / 1e6,  2)  || ' mn'
        WHEN ABS(u.valor) >= 1000 THEN ROUND(u.valor, 0)         || ''
        ELSE                           ROUND(u.valor, 2)         || ''
    END                                                                        AS ultimo_valor,
    ROUND(((u.valor - h.valor_hace_10a) / NULLIF(h.valor_hace_10a, 0)) * 100, 1)
        || ' %'                                                                AS cambio_10a
FROM catalogo_indicadores c
LEFT JOIN ultimo_valor u ON u.indicador = c.columna
LEFT JOIN hace_10      h ON h.indicador = c.columna
ORDER BY c.columna;
```

**Resultado** — 15 filas:

| indicador | unidad | anio_ultimo | ultimo_valor | cambio_10a |
| --- | --- | --- | --- | --- |
| Emisiones CO₂ per cápita | toneladas | 2024 | 3.64 | -10.2 % |
| Tasa de desempleo | % de la PEA | 2025 | 2.67 | -38.0 % |
| Deuda externa | USD corrientes | 2024 | 591.26 bn | 9.9 % |
| Exportaciones | USD corrientes | 2025 | 726.56 bn | 75.3 % |
| Gasto público en educación | % del PIB | 2022 | 4.06 | -19.6 % |
| Gasto en salud | % del PIB | 2023 | 5.5 | -0.4 % |
| Índice de Gini | 0-100 | 2024 | 42.6 | -12.9 % |
| Inversión extranjera directa | USD corrientes | 2025 | 43.09 bn | 18.9 % |
| Importaciones | USD corrientes | 2025 | 738.16 bn | 67.8 % |
| Inflación | % anual | 2025 | 3.81 | 39.9 % |
| Crecimiento del PIB | % anual | 2025 | 0.56 | -79.2 % |
| PIB nominal | USD corrientes | 2025 | 1832.64 bn | 51.0 % |
| PIB per cápita | USD corrientes | 2025 | 13889.0 | 38.6 % |
| Población | habitantes | 2025 | 131.95 mn | 9.0 % |
| Tasa de interés real | % anual | 2025 | 3.97 | 1817.8 % |

---
