# 30 ejercicios de SQL — del básico al avanzado

> **Cómo usar este documento**
>
> 1. Asegúrate de tener `analisis.duckdb` generado (corre `python cargar_db.py` desde la raíz del proyecto si aún no lo has hecho).
> 2. Conéctate a la DB con DuckDB CLI (`duckdb analisis.duckdb`), DBeaver, DataGrip o cualquier cliente.
> 3. Lee el problema, **intenta resolverlo sin mirar la solución**.
> 4. Cuando termines (o te atores), abre `soluciones/NN_*.sql` para comparar.
> 5. Si quieres validar todo de un golpe: `python verificar.py`.
>
> Los ejercicios usan los datos del [Observatorio macroeconómico de México](../README.md): 15 indicadores oficiales del Banco Mundial entre 1960 y 2024, más un catálogo de eventos macroeconómicos.

---

## Tablas y vistas disponibles

| Objeto | Filas | Descripción |
|---|---|---|
| `indicadores_wide` | 66 | Una fila por año, 15 columnas de indicadores (formato pivot) |
| `indicadores_long` | 760 | Una fila por par (año, indicador) en formato tall |
| `catalogo_indicadores` | 15 | Código del Banco Mundial, nombre legible, unidad |
| `eventos_macro` | 13 | Año, evento histórico, categoría |
| `v_anio_con_eventos` | vista | Wide con eventos del año concatenados |
| `v_indicadores_etiquetados` | vista | Long enriquecido con catálogo |

---

# Nivel 1 — Fácil (01–10)

Cubre `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, agregaciones simples, `GROUP BY`, `DISTINCT` y `NULL handling`.

### Ejercicio 01 — Top 10 años de mayor PIB nominal
Lista los 10 años con el PIB nominal más alto, mostrando el año y el PIB convertido a miles de millones de USD, redondeado a 1 decimal. Ordena de mayor a menor.

### Ejercicio 02 — Años con inflación alta
Devuelve todos los años en los que la inflación anual fue **mayor a 50 %**. Muestra año y valor de inflación redondeado a 2 decimales, ordenado del peor al mejor.

### Ejercicio 03 — Indicadores del sexenio de Salinas
Devuelve PIB nominal (billones USD), crecimiento del PIB, inflación y desempleo para cada año del sexenio de Carlos Salinas (1989-1994), ordenado por año.

### Ejercicio 04 — Registros de Gini y rango temporal
¿Cuántos años tienen registro del Índice de Gini y cuál es el primer y último año con dato? Devuelve una sola fila con 3 columnas.

### Ejercicio 05 — Inflación promedio histórica y por década
Dos queries: (a) inflación promedio simple de toda la historia; (b) inflación promedio por década.

### Ejercicio 06 — Conteo de eventos por categoría
Cuenta cuántos eventos hay en cada `categoria` de `eventos_macro`. Ordena de mayor a menor.

### Ejercicio 07 — Categorías distintas de eventos
Devuelve la lista de categorías únicas en `eventos_macro`, en orden alfabético.

### Ejercicio 08 — PIB mínimo y máximo desde 2000
Desde el año 2000, encuentra el PIB nominal mínimo y máximo (billones USD) junto con su año. Devuelve una sola fila con 4 columnas.

### Ejercicio 09 — Años sin registro de desempleo
Lista los años para los cuales **no existe registro** de la tasa de desempleo.

### Ejercicio 10 — Validar el PIB per cápita reportado
Calcula manualmente `pib_nominal_usd / poblacion` y compara con el `pib_per_capita_usd` reportado. Muestra los últimos 10 años con ambos valores y la diferencia absoluta.

---

# Nivel 2 — Intermedio (11–20)

Cubre `JOINs` (INNER, LEFT), subqueries (escalares y correlacionadas), `HAVING`, `CASE WHEN`, CTEs simples, `UNION ALL`.

### Ejercicio 11 — Eventos con su contexto económico
Para cada evento de `eventos_macro`, muestra el evento, su año, el crecimiento del PIB y la inflación del mismo año. Solo eventos con datos económicos.

### Ejercicio 12 — Todos los años con su evento (si existe)
Devuelve todos los años desde 2000 con el evento macro asociado. Si un año no tiene evento, muestra `"Sin evento"` en lugar de NULL.

### Ejercicio 13 — Años con PIB superior al promedio histórico
Usa una subquery escalar en el `WHERE` para encontrar los años cuyo PIB nominal estuvo por encima del promedio histórico. Muestra año, PIB en billones y diferencia vs el promedio.

### Ejercicio 14 — Décadas con inflación promedio > 10 %
Lista las décadas donde la inflación promedio anual superó el 10 %. Usa `HAVING`. Incluye también el peor año de la década.

### Ejercicio 15 — Clasificar cada año por desempeño económico
Usa `CASE WHEN` para clasificar cada año según el crecimiento del PIB: "Crisis" (< 0), "Estancamiento" (0–2 %), "Normal" (2–5 %), "Bonanza" (≥ 5 %). Cuenta cuántos años cayeron en cada categoría.

### Ejercicio 16 — CTE para reusar un cálculo
Para cada año, indica si el desempleo estuvo por encima o por debajo del promedio histórico, y por cuántos puntos porcentuales. Usa una CTE para calcular el promedio una sola vez.

### Ejercicio 17 — Auditoría de valores faltantes
Para cada indicador del catálogo, calcula cuántos NULLs tiene en `indicadores_wide` y qué porcentaje de completitud representa. Pista: usa `indicadores_long` para evitar listar las 15 columnas a mano.

### Ejercicio 18 — Subquery correlacionada
Para cada evento, recupera la inflación del año del evento (subquery correlacionada en el SELECT) y compárala con el promedio de los 3 años previos al evento (otra subquery correlacionada).

### Ejercicio 19 — Top 5 mejores y top 5 peores años (UNION ALL)
En una sola tabla, los 5 mejores y los 5 peores años por crecimiento del PIB. Incluye una columna `tipo` con "Mejor" o "Peor".

### Ejercicio 20 — Indicadores con más de 50 observaciones
Lista los indicadores que tienen más de 50 observaciones registradas. Para cada uno: nombre, código WB, conteo y ventana temporal (año min y max).

---

# Nivel 3 — Avanzado (21–30)

Cubre **window functions** (`LAG`, `LEAD`, `ROW_NUMBER`, `NTILE`, ventanas móviles con `ROWS BETWEEN`), `ROLLUP`, pivots con `FILTER`, CTEs encadenadas, y trucos avanzados como producto acumulado vía logaritmos.

### Ejercicio 21 — Variación YoY del PIB con LAG
Para cada año, muestra el PIB nominal, el PIB del año anterior (usando `LAG`), la diferencia absoluta y el % de variación. Solo desde 2010.

### Ejercicio 22 — Ranking de inflación dentro de cada década
Usa `ROW_NUMBER() OVER (PARTITION BY decada ORDER BY inflacion_pct DESC)` para asignar ranking dentro de cada década. Devuelve solo el peor año (rank = 1) de cada década.

### Ejercicio 23 — Promedio móvil de 5 años del crecimiento
Calcula el promedio móvil de 5 años del crecimiento del PIB usando `AVG() OVER (ORDER BY anio ROWS BETWEEN 4 PRECEDING AND CURRENT ROW)`. Devuelve desde 2000.

### Ejercicio 24 — IED acumulada histórica
Muestra el monto de IED anual y el total acumulado histórico, ambos en billones USD. Usa `SUM() OVER (ORDER BY anio)` sin `ROWS BETWEEN` (acumulado).

### Ejercicio 25 — Cuartiles de crecimiento con NTILE
Divide todos los años en 4 cuartiles según su crecimiento del PIB usando `NTILE(4) OVER (ORDER BY pib_crecimiento_pct)`. Muestra los límites de cada cuartil (n, min, max, promedio).

### Ejercicio 26 — Tres CTEs encadenadas
Construye un análisis en 3 pasos con CTEs encadenadas: (1) base con año + crecimiento, (2) agregar el crecimiento del año anterior con `LAG`, (3) calcular el cambio y rankear por magnitud. Devuelve los 10 años con el cambio más brusco.

### Ejercicio 27 — Pivot: década × categoría de evento
Construye una tabla pivot manual: filas = década, columnas = categorías (`crisis`, `regimen`, `tratado`, `externo`), valor = cuántos eventos de esa categoría ocurrieron en esa década. Tip: usa `COUNT(*) FILTER (WHERE ...)`.

### Ejercicio 28 — Inflación por sexenio + subtotal con ROLLUP
Inflación promedio por sexenio entre 1970 y 2024. Al final agrega una fila "TOTAL" con el promedio global usando `GROUP BY ROLLUP`.

### Ejercicio 29 — Puntos de inflexión del PIB
Detecta años donde el crecimiento del PIB cambió de signo respecto al anterior (entra/sale de recesión). Usa `LAG` y `SIGN`.

### Ejercicio 30 — Inflación compuesta por sexenio (¡joya de entrevista!)
La inflación no se promedia, se multiplica:
```
acumulada = (1 + i1)(1 + i2)...(1 + iN) - 1
```
SQL no tiene `PROD()`, pero existe el truco: `EXP(SUM(LN(x)))` reproduce el producto vía logaritmos. Calcula la inflación acumulada real por sexenio y la "tasa geométrica anual" equivalente.

---

## Después de terminar

Si resolviste los 30 sin ayuda, tienes el nivel SQL que el 90 % de los puestos de Data Analyst piden en su filtro técnico. Los retos típicos en entrevistas son combinaciones de estos patrones.

Para llevarlo más lejos:
- Resuélvelos en **PostgreSQL** (DuckDB usa SQL casi idéntico — solo `DISTINCT ON` y algún detalle cambia)
- Repite los avanzados pero **escribe tu propia versión** sin mirar la solución
- Practica el mismo tipo de problemas en [HackerRank SQL](https://www.hackerrank.com/domains/sql) y [LeetCode Database](https://leetcode.com/problemset/database/)
