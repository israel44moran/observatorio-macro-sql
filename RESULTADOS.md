# Resultados de las 15 queries

Generado automaticamente por `correr_analisis.py` sobre `analisis.duckdb`.
Total de queries: **15**.

---

## 01_evolucion_pib_yoy — EVOLUCION DEL PIB CON VARIACION YEAR-OVER-YEAR

_DEMUESTRA: window functions LAG() y ROW_NUMBER() OVER (ORDER BY)._  
Para cada anio, recupera el PIB del anio anterior con LAG(),
calcula el delta y el porcentaje de variacion. Limita a los
ultimos 15 anios para hacer el resultado legible.

**SQL:**

```sql
WITH pib_con_lag AS (
    SELECT
        anio,
        pib_nominal_usd                                       AS pib_actual,
        LAG(pib_nominal_usd) OVER (ORDER BY anio)             AS pib_anterior,
        ROW_NUMBER()         OVER (ORDER BY anio DESC)        AS antiguedad
    FROM indicadores_wide
    WHERE pib_nominal_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(pib_actual / 1e9, 1)                                            AS pib_billones_usd,
    ROUND((pib_actual - pib_anterior) / 1e9, 1)                           AS delta_billones,
    ROUND(((pib_actual - pib_anterior) / pib_anterior) * 100, 2)          AS variacion_pct
FROM pib_con_lag
WHERE antiguedad <= 15
ORDER BY anio DESC;
```

**Resultado** — 15 filas:

| anio | pib_billones_usd | delta_billones | variacion_pct |
| --- | --- | --- | --- |
| 2024 | 1,856.4 | 58 | 3.23 |
| 2023 | 1,798.3 | 331.4 | 22.59 |
| 2022 | 1,466.9 | 150.4 | 11.42 |
| 2021 | 1,316.6 | 195.5 | 17.44 |
| 2020 | 1,121.1 | -183 | -14.04 |
| 2019 | 1,304.1 | 47.8 | 3.81 |
| 2018 | 1,256.3 | 65.6 | 5.51 |
| 2017 | 1,190.7 | 78.5 | 7.06 |
| 2016 | 1,112.2 | -101.1 | -8.33 |
| 2015 | 1,213.3 | -151.2 | -11.08 |
| 2014 | 1,364.5 | 37.1 | 2.79 |
| 2013 | 1,327.4 | 72.3 | 5.76 |
| 2012 | 1,255.1 | 26.1 | 2.12 |
| 2011 | 1,229 | 123.6 | 11.18 |
| 2010 | 1,105.4 | 162 | 17.17 |

---

## 02_top_anios_inflacion — TOP 10 ANIOS DE MAYOR INFLACION EN LA HISTORIA RECIENTE

_DEMUESTRA: subquery escalar, RANK() OVER, JOIN a vista_  
con eventos macro para contextualizar cada anio extremo.
Cruza el ranking con los eventos historicos para que el lector
vea inmediatamente por que ese anio fue tan inflacionario.

**SQL:**

```sql
SELECT
    RANK() OVER (ORDER BY w.inflacion_pct DESC) AS posicion,
    w.anio,
    ROUND(w.inflacion_pct, 2)                    AS inflacion_pct,
    ROUND(w.pib_crecimiento_pct, 2)              AS pib_crecimiento_pct,
    COALESCE(STRING_AGG(e.evento, ' / '), '')    AS contexto
FROM indicadores_wide w
LEFT JOIN eventos_macro e ON e.anio = w.anio
WHERE w.inflacion_pct IS NOT NULL
GROUP BY w.anio, w.inflacion_pct, w.pib_crecimiento_pct
ORDER BY w.inflacion_pct DESC
LIMIT 10;
```

**Resultado** — 10 filas:

| posicion | anio | inflacion_pct | pib_crecimiento_pct | contexto |
| --- | --- | --- | --- | --- |
| 1 | 1987 | 131.83 | 2.06 |  |
| 2 | 1988 | 114.16 | 1.22 | Inicio del periodo de Salinas |
| 3 | 1983 | 101.87 | -4.62 |  |
| 4 | 1986 | 86.23 | -3.93 |  |
| 5 | 1984 | 65.45 | 3.51 |  |
| 6 | 1982 | 58.91 | -0.05 | Crisis de la deuda externa |
| 7 | 1985 | 57.75 | 1.92 |  |
| 8 | 1995 | 35 | -5.91 | Crisis del Tequila |
| 9 | 1996 | 34.38 | 6.22 |  |
| 10 | 1977 | 29.06 | 3.39 |  |

---

## 03_inflacion_acumulada_sexenal — INFLACION ACUMULADA COMPUESTA POR SEXENIO

_DEMUESTRA: CTE + CASE WHEN para segmentar por sexenio,_  
producto acumulado via EXP(SUM(LN(...))) -- truco clasico SQL
para multiplicar valores en una agregacion.
En Mexico el ejecutivo dura 6 anios. Calculamos cuanto subieron
los precios en TOTAL durante cada periodo presidencial.
inflacion_acumulada = (1 + i1) * (1 + i2) * ... * (1 + i6) - 1

**SQL:**

```sql
WITH inflacion_por_sexenio AS (
    SELECT
        CASE
            WHEN anio BETWEEN 1970 AND 1976 THEN '1970-1976  Echeverría'
            WHEN anio BETWEEN 1977 AND 1982 THEN '1977-1982  López Portillo'
            WHEN anio BETWEEN 1983 AND 1988 THEN '1983-1988  De la Madrid'
            WHEN anio BETWEEN 1989 AND 1994 THEN '1989-1994  Salinas'
            WHEN anio BETWEEN 1995 AND 2000 THEN '1995-2000  Zedillo'
            WHEN anio BETWEEN 2001 AND 2006 THEN '2001-2006  Fox'
            WHEN anio BETWEEN 2007 AND 2012 THEN '2007-2012  Calderón'
            WHEN anio BETWEEN 2013 AND 2018 THEN '2013-2018  Peña Nieto'
            WHEN anio BETWEEN 2019 AND 2024 THEN '2019-2024  López Obrador'
        END                              AS sexenio,
        anio,
        inflacion_pct
    FROM indicadores_wide
    WHERE inflacion_pct IS NOT NULL
      AND anio BETWEEN 1970 AND 2024
)
SELECT
    sexenio,
    COUNT(*)                                                                     AS anios_con_dato,
    ROUND(AVG(inflacion_pct), 2)                                                 AS inflacion_promedio_anual,
    ROUND((EXP(SUM(LN(1 + inflacion_pct / 100))) - 1) * 100, 1)                  AS inflacion_acumulada_pct,
    ROUND(MAX(inflacion_pct), 2)                                                 AS peor_anio_pct,
    ROUND(MIN(inflacion_pct), 2)                                                 AS mejor_anio_pct
FROM inflacion_por_sexenio
WHERE sexenio IS NOT NULL
GROUP BY sexenio
ORDER BY sexenio;
```

**Resultado** — 9 filas:

| sexenio | anios_con_dato | inflacion_promedio_anual | inflacion_acumulada_pct | peor_anio_pct | mejor_anio_pct |
| --- | --- | --- | --- | --- | --- |
| 1970-1976  Echeverría | 7 | 11.72 | 114.7 | 23.78 | 4.94 |
| 1977-1982  López Portillo | 6 | 29.65 | 360.3 | 58.91 | 17.46 |
| 1983-1988  De la Madrid | 6 | 92.88 | 4,771.7 | 131.83 | 57.75 |
| 1989-1994  Salinas | 6 | 16.92 | 152.8 | 26.65 | 6.97 |
| 1995-2000  Zedillo | 6 | 22 | 223.8 | 35 | 9.49 |
| 2001-2006  Fox | 6 | 4.71 | 31.8 | 6.37 | 3.63 |
| 2007-2012  Calderón | 6 | 4.34 | 29 | 5.3 | 3.41 |
| 2013-2018  Peña Nieto | 6 | 4.05 | 26.9 | 6.04 | 2.72 |
| 2019-2024  López Obrador | 6 | 5.14 | 35 | 7.9 | 3.4 |

---

## 04_curva_phillips — CURVA DE PHILLIPS: CORRELACION DESEMPLEO vs INFLACION

_DEMUESTRA: funcion estadistica CORR() y agregacion en_  
ventanas de decadas usando CASE WHEN.
La curva de Phillips postula correlacion NEGATIVA entre
desempleo e inflacion (cuando uno sube el otro baja).
Aqui medimos el coeficiente para Mexico en distintas decadas.

**SQL:**

```sql
WITH datos_decada AS (
    SELECT
        FLOOR(anio / 10) * 10 AS decada,
        inflacion_pct,
        desempleo_pct
    FROM indicadores_wide
    WHERE inflacion_pct IS NOT NULL
      AND desempleo_pct IS NOT NULL
)
SELECT
    decada || 's'                                            AS periodo,
    COUNT(*)                                                 AS n_anios,
    ROUND(CORR(desempleo_pct, inflacion_pct), 3)             AS correlacion_phillips,
    ROUND(AVG(inflacion_pct), 2)                             AS inflacion_prom,
    ROUND(AVG(desempleo_pct), 2)                             AS desempleo_prom,
    CASE
        WHEN CORR(desempleo_pct, inflacion_pct) < -0.3 THEN 'Phillips clasica'
        WHEN CORR(desempleo_pct, inflacion_pct) >  0.3 THEN 'Phillips invertida'
        ELSE 'Sin relacion clara'
    END                                                      AS interpretacion
FROM datos_decada
GROUP BY decada
HAVING COUNT(*) >= 3
ORDER BY decada;
```

**Resultado** — 4 filas:

| periodo | n_anios | correlacion_phillips | inflacion_prom | desempleo_prom | interpretacion |
| --- | --- | --- | --- | --- | --- |
| 1990.0s | 9 | 0.697 | 19.71 | 4.15 | Phillips invertida |
| 2000.0s | 10 | -0.417 | 5.21 | 3.57 | Phillips clasica |
| 2010.0s | 10 | -0.336 | 3.96 | 4.34 | Phillips clasica |
| 2020.0s | 5 | -0.366 | 5.45 | 3.43 | Phillips clasica |

---

## 05_saldo_comercial — SALDO COMERCIAL Y SU EVOLUCION

_DEMUESTRA: aritmetica entre columnas, CASE para clasificacion,_  
window function SUM() OVER (ORDER BY) para acumulado y
variacion vs el promedio movil con AVG OVER (ROWS BETWEEN).
Mexico paso de un modelo cerrado a una de las economias mas
abiertas tras el TLCAN. Aqui visualizamos el efecto.

**SQL:**

```sql
WITH comercio AS (
    SELECT
        anio,
        exportaciones_usd,
        importaciones_usd,
        exportaciones_usd - importaciones_usd                                AS saldo,
        AVG(exportaciones_usd - importaciones_usd) OVER (
            ORDER BY anio
            ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
        )                                                                    AS saldo_promedio_5a
    FROM indicadores_wide
    WHERE exportaciones_usd IS NOT NULL
      AND importaciones_usd IS NOT NULL
)
SELECT
    anio,
    ROUND(exportaciones_usd / 1e9, 1)             AS exp_bn_usd,
    ROUND(importaciones_usd / 1e9, 1)             AS imp_bn_usd,
    ROUND(saldo / 1e9, 1)                         AS saldo_bn_usd,
    ROUND(saldo_promedio_5a / 1e9, 1)             AS saldo_prom_5a_bn,
    CASE
        WHEN saldo > 0 THEN 'Superavit'
        ELSE 'Deficit'
    END                                           AS clasificacion
FROM comercio
WHERE anio >= 1990
ORDER BY anio DESC;
```

**Resultado** — 35 filas (mostrando primeras 15):

| anio | exp_bn_usd | imp_bn_usd | saldo_bn_usd | saldo_prom_5a_bn | clasificacion |
| --- | --- | --- | --- | --- | --- |
| 2024 | 681.3 | 703.3 | -21.9 | -19.6 | Deficit |
| 2023 | 648.6 | 674.5 | -25.9 | -16.3 | Deficit |
| 2022 | 629.8 | 672.8 | -43 | -16.5 | Deficit |
| 2021 | 534.1 | 559.5 | -25.4 | -12.4 | Deficit |
| 2020 | 439.9 | 421.7 | 18.1 | -11.9 | Superavit |
| 2019 | 502.5 | 507.7 | -5.3 | -20.6 | Deficit |
| 2018 | 490.5 | 517.2 | -26.7 | -22.8 | Deficit |
| 2017 | 446.7 | 469.6 | -22.9 | -20.6 | Deficit |
| 2016 | 409.5 | 432.4 | -22.9 | -18.9 | Deficit |
| 2015 | 414.5 | 439.8 | -25.3 | -17.5 | Deficit |
| 2014 | 429.3 | 445.3 | -16 | -15.2 | Deficit |
| 2013 | 408.3 | 423.9 | -15.7 | -14.9 | Deficit |
| 2012 | 395.9 | 410.7 | -14.8 | -17.2 | Deficit |
| 2011 | 374.1 | 389.8 | -15.7 | -18 | Deficit |
| 2010 | 320.8 | 334.5 | -13.7 | -17.6 | Deficit |

---

## 06_recesiones_detectadas — DETECCION AUTOMATICA DE RECESIONES (PIB DECRECIENTE)

_DEMUESTRA: LAG() para comparar con anio anterior, CASE con_  
multiples condiciones, JOIN con eventos para contexto.
Definicion practica: anio con crecimiento del PIB negativo.
Tambien marcamos si el anio siguiente tambien fue negativo
(recesion "doble") o si vino seguido de recuperacion fuerte.

**SQL:**

```sql
WITH crecimiento AS (
    SELECT
        anio,
        pib_crecimiento_pct,
        LAG(pib_crecimiento_pct)  OVER (ORDER BY anio) AS pib_anterior,
        LEAD(pib_crecimiento_pct) OVER (ORDER BY anio) AS pib_siguiente
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
)
SELECT
    c.anio,
    ROUND(c.pib_crecimiento_pct, 2)                     AS crecimiento,
    ROUND(c.pib_anterior,         2)                    AS anio_previo,
    ROUND(c.pib_siguiente,        2)                    AS anio_siguiente,
    CASE
        WHEN c.pib_anterior  < 0 THEN 'Recesion encadenada'
        WHEN c.pib_siguiente < 0 THEN 'Continuara cayendo'
        WHEN c.pib_siguiente > 3 THEN 'Recuperacion fuerte (rebote)'
        ELSE 'Recesion aislada'
    END                                                 AS patron,
    COALESCE(e.evento, '-')                             AS evento_contexto
FROM crecimiento c
LEFT JOIN eventos_macro e ON e.anio = c.anio
WHERE c.pib_crecimiento_pct < 0
ORDER BY c.anio;
```

**Resultado** — 9 filas:

| anio | crecimiento | anio_previo | anio_siguiente | patron | evento_contexto |
| --- | --- | --- | --- | --- | --- |
| 1982 | -0.05 | 9.59 | -4.62 | Continuara cayendo | Crisis de la deuda externa |
| 1983 | -4.62 | -0.05 | 3.51 | Recesion encadenada | - |
| 1986 | -3.93 | 1.92 | 2.06 | Recesion aislada | - |
| 1995 | -5.91 | 4.39 | 6.22 | Recuperacion fuerte (rebote) | Crisis del Tequila |
| 2001 | -0.45 | 5.03 | -0.24 | Continuara cayendo | Recesión EUA post-9/11 |
| 2002 | -0.24 | -0.45 | 1.19 | Recesion encadenada | - |
| 2009 | -6.3 | 0.94 | 4.97 | Recuperacion fuerte (rebote) | Crisis financiera global |
| 2019 | -0.39 | 1.97 | -8.35 | Continuara cayendo | - |
| 2020 | -8.35 | -0.39 | 6.05 | Recesion encadenada | Pandemia COVID-19 |

---

## 07_promedio_movil_pib — PROMEDIO MOVIL DEL CRECIMIENTO DEL PIB (3 / 5 / 10 ANIOS)

_DEMUESTRA: tres window functions AVG() OVER con diferentes_  
ventanas ROWS BETWEEN ... PRECEDING para suavizar la serie y
separar el ruido coyuntural de la tendencia estructural.
El crecimiento anual del PIB es muy volatil. Los promedios
moviles revelan si Mexico esta en una era de alto o bajo
crecimiento estructural.

**SQL:**

```sql
SELECT
    anio,
    ROUND(pib_crecimiento_pct, 2)                                                                  AS pib_anual,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS prom_movil_3a,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 4 PRECEDING AND CURRENT ROW), 2) AS prom_movil_5a,
    ROUND(AVG(pib_crecimiento_pct) OVER (ORDER BY anio ROWS BETWEEN 9 PRECEDING AND CURRENT ROW), 2) AS prom_movil_10a
FROM indicadores_wide
WHERE pib_crecimiento_pct IS NOT NULL
  AND anio >= 1990
ORDER BY anio DESC;
```

**Resultado** — 35 filas (mostrando primeras 15):

| anio | pib_anual | prom_movil_3a | prom_movil_5a | prom_movil_10a |
| --- | --- | --- | --- | --- |
| 2024 | 1.43 | 2.83 | 1.24 | 1.41 |
| 2023 | 3.35 | 4.37 | 0.87 | 1.52 |
| 2022 | 3.71 | 0.47 | 0.6 | 1.27 |
| 2021 | 6.05 | -0.9 | 0.23 | 1.25 |
| 2020 | -8.35 | -2.26 | -0.63 | 0.99 |
| 2019 | -0.39 | 1.15 | 1.59 | 2.33 |
| 2018 | 1.97 | 1.87 | 2.16 | 1.73 |
| 2017 | 1.87 | 2.12 | 1.94 | 1.63 |
| 2016 | 1.77 | 2.33 | 2.28 | 1.65 |
| 2015 | 2.7 | 2.02 | 2.61 | 1.96 |
| 2014 | 2.5 | 2.3 | 3.06 | 1.9 |
| 2013 | 0.85 | 2.62 | 1.31 | 2 |
| 2012 | 3.55 | 3.99 | 1.32 | 2.04 |
| 2011 | 3.44 | 0.71 | 1.03 | 1.66 |
| 2010 | 4.97 | -0.13 | 1.3 | 1.27 |

---

## 08_pivot_por_decada — TABLA PIVOT: INDICADORES PROMEDIO POR DECADA

_DEMUESTRA: agregacion con FILTER (WHERE ...) -- sintaxis_  
moderna SQL:2003, mas limpia que CASE WHEN dentro de SUM().
Tambien GROUPING y CUBE para producir totales.
Resume cada decada en una sola fila con sus indicadores clave.

**SQL:**

```sql
SELECT
    FLOOR(anio / 10) * 10 || 's'                                                    AS decada,
    ROUND(AVG(pib_crecimiento_pct), 2)                                              AS pib_crecimiento_prom,
    ROUND(AVG(inflacion_pct),       2)                                              AS inflacion_prom,
    ROUND(AVG(desempleo_pct),       2)                                              AS desempleo_prom,
    ROUND(AVG(ied_usd) / 1e9,       2)                                              AS ied_promedio_bn_usd,
    ROUND(AVG(exportaciones_usd / NULLIF(importaciones_usd, 0)), 3)                 AS ratio_export_import,
    ROUND(MAX(poblacion) / 1e6, 1)                                                  AS poblacion_fin_decada_mn,
    COUNT(*)                                                                        AS anios_con_datos
FROM indicadores_wide
WHERE anio BETWEEN 1960 AND 2029
GROUP BY ROLLUP(FLOOR(anio / 10) * 10)
ORDER BY decada NULLS LAST;
```

**Resultado** — 8 filas:

| decada | pib_crecimiento_prom | inflacion_prom | desempleo_prom | ied_promedio_bn_usd | ratio_export_import | poblacion_fin_decada_mn | anios_con_datos |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1960.0s | 6.84 | 2.72 | — | — | 0.794 | 49.2 | 10 |
| 1970.0s | 6.43 | 14.68 | — | 0.53 | 0.871 | 65.6 | 10 |
| 1980.0s | 2.21 | 69.05 | — | 2.39 | 1.326 | 81.2 | 10 |
| 1990.0s | 3.65 | 20.41 | 4.15 | 8.54 | 0.918 | 97.1 | 10 |
| 2000.0s | 1.27 | 5.21 | 3.57 | 23.96 | 0.938 | 112 | 10 |
| 2010.0s | 2.33 | 3.96 | 4.34 | 32.81 | 0.959 | 125.8 | 10 |
| 2020.0s | 1.24 | 5.45 | 3.31 | 36.51 | 0.973 | 130.9 | 6 |
| — | 3.54 | 18.27 | 3.89 | 15.72 | 0.968 | 130.9 | 66 |

---

## 09_brecha_demografica_economica — BRECHA: CRECIMIENTO POBLACIONAL vs CRECIMIENTO ECONOMICO

_DEMUESTRA: dos CTEs encadenadas, calculo de tasas YoY con LAG,_  
diferencia entre dos tasas de crecimiento.
Si el PIB crece 2% pero la poblacion crece 1.5%, el PIB per
capita real solo crece 0.5%. Esta query muestra esa brecha.

**SQL:**

```sql
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
```

**Resultado** — 25 filas (mostrando primeras 15):

| anio | crec_pob_pct | crec_pib_pct | brecha | interpretacion |
| --- | --- | --- | --- | --- |
| 2024 | 0.864 | 3.23 | 2.37 | Mejora marginal |
| 2023 | 0.876 | 22.59 | 21.71 | Mejora fuerte del bienestar |
| 2022 | 0.756 | 11.42 | 10.66 | Mejora fuerte del bienestar |
| 2021 | 0.67 | 17.44 | 16.77 | Mejora fuerte del bienestar |
| 2020 | 0.824 | -14.04 | -14.86 | Retroceso real |
| 2019 | 0.955 | 3.81 | 2.86 | Mejora marginal |
| 2018 | 0.951 | 5.51 | 4.56 | Mejora fuerte del bienestar |
| 2017 | 0.94 | 7.06 | 6.12 | Mejora fuerte del bienestar |
| 2016 | 0.974 | -8.33 | -9.3 | Retroceso real |
| 2015 | 1.075 | -11.08 | -12.16 | Retroceso real |
| 2014 | 1.217 | 2.79 | 1.57 | Mejora marginal |
| 2013 | 1.306 | 5.76 | 4.45 | Mejora fuerte del bienestar |
| 2012 | 1.366 | 2.12 | 0.75 | Mejora marginal |
| 2011 | 1.425 | 11.18 | 9.75 | Mejora fuerte del bienestar |
| 2010 | 1.45 | 17.17 | 15.72 | Mejora fuerte del bienestar |

---

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
| 2018 | Inicio periodo de López Obrador (AMLO) | regimen | 1.94 | 0.87 | 3.88 | 5.23 |
| 2020 | Pandemia COVID-19 | crisis | 1.59 | 3.63 | 4.02 | 5.96 |
| 2024 | Inicio periodo de Sheinbaum | regimen | 0.87 | — | 5.23 | — |

---

## 11_ranking_multidimensional — RANKING MULTIDIMENSIONAL DE ANIOS

_DEMUESTRA: multiples RANK() OVER, NTILE para quartiles,_  
agregacion ponderada con CASE WHEN.
Cada anio se evalua en 4 dimensiones (crecimiento, inflacion,
desempleo, IED). Se le asigna un "rank" en cada una y se
calcula un score compuesto para identificar los anios
"mas buenos" o "mas malos" macroeconomicamente.

**SQL:**

```sql
WITH ranked AS (
    SELECT
        anio,
        ROUND(pib_crecimiento_pct, 2) AS pib_pct,
        ROUND(inflacion_pct, 2)       AS inflacion,
        ROUND(desempleo_pct, 2)       AS desempleo,
        ROUND(ied_usd / 1e9, 1)       AS ied_bn,
        -- Mejor = mayor crecimiento => DESC
        RANK() OVER (ORDER BY pib_crecimiento_pct DESC NULLS LAST) AS rank_crecimiento,
        -- Mejor = menor inflacion => ASC
        RANK() OVER (ORDER BY inflacion_pct ASC NULLS LAST)        AS rank_inflacion,
        -- Mejor = menor desempleo => ASC
        RANK() OVER (ORDER BY desempleo_pct ASC NULLS LAST)        AS rank_desempleo,
        -- Mejor = mayor IED => DESC
        RANK() OVER (ORDER BY ied_usd DESC NULLS LAST)             AS rank_ied
    FROM indicadores_wide
    WHERE pib_crecimiento_pct IS NOT NULL
      AND inflacion_pct IS NOT NULL
      AND desempleo_pct IS NOT NULL
      AND ied_usd IS NOT NULL
),
con_score AS (
    SELECT *,
        rank_crecimiento + rank_inflacion + rank_desempleo + rank_ied AS score
    FROM ranked
)
SELECT
    anio, pib_pct, inflacion, desempleo, ied_bn,
    score,
    NTILE(4) OVER (ORDER BY score)                                  AS cuartil_global,
    CASE NTILE(4) OVER (ORDER BY score)
        WHEN 1 THEN 'Excelente'
        WHEN 2 THEN 'Bueno'
        WHEN 3 THEN 'Regular'
        WHEN 4 THEN 'Dificil'
    END                                                             AS clasificacion
FROM con_score
ORDER BY score
LIMIT 12;
```

**Resultado** — 12 filas:

| anio | pib_pct | inflacion | desempleo | ied_bn | score | cuartil_global | clasificacion |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2024 | 1.43 | 4.72 | 2.68 | 45.5 | 46 | 1 | Excelente |
| 2022 | 3.71 | 7.9 | 3.26 | 39.2 | 47 | 1 | Excelente |
| 2006 | 4.81 | 3.63 | 3.57 | 22.1 | 48 | 1 | Excelente |
| 2016 | 1.77 | 2.82 | 3.85 | 38.9 | 49 | 1 | Excelente |
| 2015 | 2.7 | 2.72 | 4.31 | 36.3 | 49 | 1 | Excelente |
| 2023 | 3.35 | 5.53 | 2.77 | 30.7 | 51 | 1 | Excelente |
| 2018 | 1.97 | 4.9 | 3.28 | 37.9 | 53 | 1 | Excelente |
| 2021 | 6.05 | 5.69 | 4.02 | 35.6 | 54 | 1 | Excelente |
| 2007 | 2.08 | 3.97 | 3.63 | 31 | 56 | 1 | Excelente |
| 2000 | 5.03 | 9.49 | 2.65 | 18.4 | 57 | 2 | Bueno |
| 2010 | 4.97 | 4.16 | 5.3 | 30.5 | 61 | 2 | Bueno |
| 2005 | 2.11 | 3.99 | 3.56 | 25.2 | 61 | 2 | Bueno |

---

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
| PIB nominal | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| PIB per cápita | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Exportaciones | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Importaciones | USD corrientes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Población | habitantes | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Inflación | % anual | 1960 | 2024 | 65 anios | 65 | 100.0 % | OK |
| Crecimiento del PIB | % anual | 1961 | 2024 | 64 anios | 64 | 100.0 % | OK |
| Deuda externa | USD corrientes | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Emisiones CO₂ per cápita | toneladas | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Inversión extranjera directa | USD corrientes | 1970 | 2024 | 55 anios | 55 | 100.0 % | OK |
| Tasa de desempleo | % de la PEA | 1991 | 2025 | 35 anios | 35 | 100.0 % | OK |
| Tasa de interés real | % anual | 1993 | 2024 | 32 anios | 32 | 100.0 % | OK |
| Gasto en salud | % del PIB | 2000 | 2023 | 24 anios | 24 | 100.0 % | OK |
| Índice de Gini | 0-100 | 1984 | 2024 | 41 anios | 20 | 48.8 % | Serie corta o muy fragmentada |
| Gasto público en educación | % del PIB | — | — | — | 1 | — | Serie corta o muy fragmentada |

---

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

## 14_volatilidad_movil — VOLATILIDAD MOVIL DEL PIB (DESVIACION ESTANDAR EN VENTANA)

_DEMUESTRA: STDDEV() OVER (window), interpretacion: anios de_  
mayor turbulencia macro.
Mide la volatilidad del crecimiento del PIB en una ventana
movil de 5 anios. Anios con desv. estandar alta = epocas
inestables (crisis o transiciones de regimen).

**SQL:**

```sql
SELECT
    anio,
    ROUND(pib_crecimiento_pct, 2)                                                       AS pib_anual,
    ROUND(STDDEV(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2)                                                                               AS volatilidad_5a,
    ROUND(MAX(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) - MIN(pib_crecimiento_pct) OVER (
        ORDER BY anio
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ), 2)                                                                               AS rango_5a
FROM indicadores_wide
WHERE pib_crecimiento_pct IS NOT NULL
  AND anio >= 1970
ORDER BY volatilidad_5a DESC
LIMIT 15;
```

**Resultado** — 15 filas:

| anio | pib_anual | volatilidad_5a | rango_5a |
| --- | --- | --- | --- |
| 1983 | -4.62 | 6.61 | 14.32 |
| 1984 | 3.51 | 5.98 | 14.21 |
| 2023 | 3.35 | 5.65 | 14.4 |
| 2024 | 1.43 | 5.61 | 14.4 |
| 2022 | 3.71 | 5.53 | 14.4 |
| 1998 | 6.19 | 5.42 | 13.11 |
| 1999 | 2.76 | 5.41 | 13.11 |
| 2021 | 6.05 | 5.33 | 14.4 |
| 1997 | 7.2 | 5.23 | 13.11 |
| 1985 | 1.92 | 5.19 | 14.21 |
| 1996 | 6.22 | 4.72 | 12.13 |
| 2010 | 4.97 | 4.59 | 11.27 |
| 2013 | 0.85 | 4.5 | 11.27 |
| 2012 | 3.55 | 4.5 | 11.27 |
| 2020 | -8.35 | 4.43 | 10.33 |

---

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

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types 'abs(VARCHAR)'. You might need to add explicit type casts.
	Candidate functions:
	abs(TINYINT) -> TINYINT
	abs(SMALLINT) -> SMALLINT
	abs(INTEGER) -> INTEGER
	abs(BIGINT) -> BIGINT
	abs(HUGEINT) -> HUGEINT
	abs(FLOAT) -> FLOAT
	abs(DOUBLE) -> DOUBLE
	abs(DECIMAL) -> DECIMAL
	abs(UTINYINT) -> UTINYINT
	abs(USMALLINT) -> USMALLINT
	abs(UINTEGER) -> UINTEGER
	abs(UBIGINT) -> UBIGINT
	abs(UHUGEINT) -> UHUGEINT


LINE 22:         WHEN ABS(u.valor) >= 1e9  THEN ROUND(u.valor / 1e9,  2)  || ...
                      ^ |

---
