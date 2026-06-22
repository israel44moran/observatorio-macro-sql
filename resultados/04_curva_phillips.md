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

**Resultado** — 1 filas:

| ERROR |
| --- |
| Binder Error: No function matches the given name and argument types 'corr(VARCHAR, DOUBLE)'. You might need to add explicit type casts.
	Candidate functions:
	corr(DOUBLE, DOUBLE) -> DOUBLE


LINE 13:     ROUND(CORR(desempleo_pct, inflacion_pct), 3)             AS corre...
                   ^ |

---
