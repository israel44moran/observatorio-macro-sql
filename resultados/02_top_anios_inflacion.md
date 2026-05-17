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
