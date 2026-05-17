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
| 2001 | -0.45 | 5.03 | -0.24 | Continuara cayendo | Recesion EUA post-9/11 |
| 2002 | -0.24 | -0.45 | 1.19 | Recesion encadenada | - |
| 2009 | -6.3 | 0.94 | 4.97 | Recuperacion fuerte (rebote) | Crisis financiera global |
| 2019 | -0.39 | 1.97 | -8.35 | Continuara cayendo | - |
| 2020 | -8.35 | -0.39 | 6.05 | Recesion encadenada | Pandemia COVID-19 |

---
