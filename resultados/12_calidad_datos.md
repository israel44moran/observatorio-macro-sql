## 12_calidad_datos — AUDITORIA DE CALIDAD DE DATOS

_DEMUESTRA: agregacion sobre la tabla long, JOIN con catalogo,_  
calculo de completitud y deteccion de gaps en la serie.
Para cada indicador reporta cobertura temporal, % de
completitud y si hay anios "huecos" dentro del rango cubierto.

**SQL:**

```sql
WITH stats AS (
    SELECT
        c.columna,
        c.nombre,
        c.unidad,
        MIN(l.anio)                                      AS anio_inicio,
        MAX(l.anio)                                      AS anio_fin,
        COUNT(*)                                         AS n_observaciones,
        MAX(l.anio) - MIN(l.anio) + 1                    AS rango_esperado,
        ROUND(COUNT(*) * 100.0 / (MAX(l.anio) - MIN(l.anio) + 1), 1) AS completitud_pct
    FROM catalogo_indicadores c
    LEFT JOIN indicadores_long l ON l.indicador = c.columna
    GROUP BY c.columna, c.nombre, c.unidad
)
SELECT
    nombre,
    unidad,
    anio_inicio,
    anio_fin,
    rango_esperado || ' anios'             AS rango,
    n_observaciones                        AS observaciones,
    completitud_pct || ' %'                AS completitud,
    CASE
        WHEN completitud_pct = 100 THEN 'OK'
        WHEN completitud_pct >  90 THEN 'Pocos huecos'
        WHEN completitud_pct >  50 THEN 'Cobertura parcial'
        ELSE                            'Serie corta o muy fragmentada'
    END                                    AS diagnostico
FROM stats
ORDER BY completitud_pct DESC, anio_inicio;
```

**Resultado** — 15 filas:

| nombre | unidad | anio_inicio | anio_fin | rango | observaciones | completitud | diagnostico |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PIB per capita | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Inflacion | % anual | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| PIB nominal | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Importaciones | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Poblacion | habitantes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Exportaciones | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Crecimiento del PIB | % anual | 1961 | 2024 | 64 anios | 64 | 100.0 % | OK |
| Deuda externa | USD corrientes | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Emisiones CO2 per capita | toneladas | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Inversion extranjera directa | USD corrientes | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Tasa de desempleo | % de la PEA | 1991 | 2025 | 35 anios | 35 | 100.0 % | OK |
| Tasa de interes real | % anual | 1993 | 2024 | 32 anios | 32 | 100.0 % | OK |
| Gasto en salud | % del PIB | 2000 | 2023 | 24 anios | 24 | 100.0 % | OK |
| Gasto publico en educacion | % del PIB | 1989 | 2022 | 34 anios | 30 | 88.2 % | Cobertura parcial |
| Indice de Gini | 0-100 | 1984 | 2024 | 41 anios | 20 | 48.8 % | Serie corta o muy fragmentada |

---
