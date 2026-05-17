# Ejercicios SQL — del básico al avanzado

> **30 ejercicios graduados** sobre la base de datos del [Observatorio macroeconómico](../README.md). Material para entrenamiento previo a entrevistas técnicas de Data Analyst / Data Scientist.

## Estructura

```
ejercicios-sql/
├── EJERCICIOS.md       # Los 30 problemas planteados (SIN solución)
├── verificar.py        # Corre y valida todas las soluciones
├── soluciones/         # 30 archivos .sql con la solución comentada
│   ├── 01_top10_pib.sql
│   ├── 02_inflacion_alta.sql
│   └── ... 28 más
└── README.md           # Este archivo
```

## Niveles

| Nivel | Ejercicios | Habilidades cubiertas |
|---|---|---|
| **Fácil** | 01–10 | SELECT, WHERE, ORDER BY, LIMIT, agregaciones simples, GROUP BY, DISTINCT, NULL handling |
| **Intermedio** | 11–20 | JOINs (INNER, LEFT), subqueries, HAVING, CASE WHEN, CTEs simples, UNION ALL |
| **Avanzado** | 21–30 | Window functions (LAG, LEAD, ROW_NUMBER, NTILE, ventanas móviles), ROLLUP, pivots con FILTER, CTEs encadenadas, productos vía logaritmos |

## Cómo practicar (recomendado)

1. Lee el problema en [`EJERCICIOS.md`](EJERCICIOS.md).
2. Conéctate a la base con cualquier cliente SQL:
   ```bash
   duckdb ../analisis.duckdb           # CLI oficial
   ```
   O usa DBeaver / DataGrip / VS Code SQLTools.
3. Escribe tu solución sin mirar el archivo `soluciones/NN_*.sql`.
4. Cuando termines (o te atores), abre la solución para comparar.
5. Cada solución incluye un **comentario al inicio** que explica qué habilidad técnica demuestra.

## Validación automática

Ejecutar todas las soluciones de un golpe:

```bash
python verificar.py
```

Output esperado:
```
Validando 30 ejercicios contra analisis.duckdb...
  [OK  ] 01_top10_pib.sql
  [OK  ] 02_inflacion_alta.sql
  ...
============================================================
Resultado: 30/30 ejercicios OK
```

Ejecutar y **ver el resultado** de un ejercicio específico:

```bash
python verificar.py 21         # ejecuta el ejercicio 21 y muestra el output
```

## Requisitos previos

Antes de practicar, asegúrate de que `analisis.duckdb` existe en la carpeta padre:

```bash
cd ..
python descargar_datos.py
python cargar_db.py
```

Esto crea la base con 4 tablas + 2 vistas. Los ejercicios la consultan en modo solo lectura — no la modifican.

## Por qué este set y no LeetCode SQL

Tres diferencias clave:

1. **Datos reales con significado**: cada ejercicio responde una pregunta económica genuina sobre México (inflación por sexenio, recesiones, eventos macro), no una tabla `employees` ficticia.
2. **Escala de dificultad gradual**: del 01 al 30 sin saltos bruscos, cubriendo TODO el temario típico de entrevistas.
3. **Foco en patrones de entrevista**: especialmente del 21 al 30, los problemas son los que aparecen una y otra vez (`LAG`/`LEAD`, ventanas móviles, pivots, agregaciones jerárquicas). El ejercicio 30 (`EXP(SUM(LN(...)))` para producto compuesto) es una pregunta clásica de entrevistas en bancos y aseguradoras.

## Después de los 30

Si terminaste los 30 ejercicios sin ayuda, tienes el nivel SQL que el ~90 % de los puestos de Data Analyst exigen en su filtro técnico. Para profundizar:

- [HackerRank SQL](https://www.hackerrank.com/domains/sql) — buen volumen
- [LeetCode Database](https://leetcode.com/problemset/database/) — problemas de tipo entrevista FAANG
- [DataLemur](https://datalemur.com/) — preguntas reales de empresas tech
- [SQLZoo](https://sqlzoo.net/) — tutoriales interactivos clásicos
