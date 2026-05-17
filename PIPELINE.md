# Pipeline orquestado con GitHub Actions

> Proyecto 10 del portafolio — orquestación del [Observatorio macroeconómico](README.md) (Proyecto 9).

Este documento describe el **pipeline de CI/CD** que mantiene el observatorio actualizado de forma automática. La intención es demostrar la transición de **"script que corro a mano en mi laptop"** a **"sistema que trabaja solo y deja auditoría completa"**.

## Qué hace

Cada **lunes a las 12:00 UTC** (6:00 am tiempo del centro de México), un workflow de GitHub Actions ejecuta los cuatro scripts del Proyecto 9 en cadena:

```
descargar_datos.py  →  cargar_db.py  →  correr_analisis.py  →  generar_graficas.py
```

Si detecta que el Banco Mundial publicó datos nuevos (o revisiones a series existentes), **commitea automáticamente** los archivos actualizados — `wb_mexico_indicadores.csv`, `RESULTADOS.md`, los 15 markdowns de `resultados/` y las 4 PNG de `graficas/` — con un mensaje fechado:

```
chore: actualizacion automatica del observatorio (2026-05-25)

Workflow: Actualizar Observatorio
Run:      14829365022
Trigger:  schedule
```

Si el pipeline **falla** (cambio de URL en la API, indicador retirado, error de red), abre automáticamente un **issue** en el repositorio con el link al run que falló para diagnosticar.

## Por qué GitHub Actions y no Airflow o Prefect

| Criterio | GitHub Actions | Airflow | Prefect Cloud |
|---|---|---|---|
| Costo para uso público | **Gratis** (2,000 min/mes en cuentas free) | Requiere servidor o EC2 | Free tier limitado |
| Setup inicial | **1 archivo YAML en el repo** | Servidor + DB + scheduler + UI | Cuenta + agente local |
| Visibilidad para reclutadores | **Alta** — pestaña "Actions" del repo se ve sin login | Necesita demo | Necesita demo |
| Integración con git | **Nativa** — checkout, commit, push automáticos | Requiere operadores extra | Requiere conexión |
| Curva de aprendizaje | Baja | Alta (DAGs, operadores, conexiones) | Media |

Para un pipeline relativamente simple (cinco scripts en cadena, una vez por semana, sin estado compartido entre ejecuciones), **GitHub Actions tiene mejor relación esfuerzo/valor** que las herramientas de data engineering dedicadas. Para casos complejos (centenares de DAGs, dependencias entre tareas que tardan horas, gestión de pools) sí justificaría Airflow.

## Anatomía del workflow

El archivo está en [`.github/workflows/actualizar_observatorio.yml`](.github/workflows/actualizar_observatorio.yml). Sus partes:

### Trigger

```yaml
on:
  schedule:
    - cron: '0 12 * * 1'   # cada lunes 12:00 UTC
  workflow_dispatch:        # ejecucion manual desde la UI
```

Dos formas de disparar: el cron semanal y la opción "Run workflow" en la pestaña Actions, útil para correr el pipeline a demanda durante el desarrollo o demos.

### Permisos

```yaml
permissions:
  contents: write   # para commitear resultados
  issues:   write   # para abrir tickets si algo falla
```

Por defecto un workflow tiene permisos de solo lectura. Aquí se otorga lo mínimo necesario.

### Concurrencia

```yaml
concurrency:
  group: actualizar-observatorio
  cancel-in-progress: false
```

Si el cron y un dispatch manual se cruzan, el segundo espera al primero — no se cancelan entre sí, no compiten por escribir al repo.

### Detección de cambios

```bash
if [[ -z "$(git status --porcelain)" ]]; then
  echo "hay_cambios=false" >> "$GITHUB_OUTPUT"
else
  echo "hay_cambios=true" >> "$GITHUB_OUTPUT"
fi
```

Solo si los datos realmente cambiaron se hace commit. Si el Banco Mundial no publicó nada nuevo, el workflow termina limpio sin generar ruido en el historial.

### Notificación de falla

```yaml
- name: Abrir issue si fallo
  if: failure()
  uses: actions/github-script@v7
```

Cuando algo falla, el bot abre un issue con label `pipeline` y el link directo al run. Esto cierra el ciclo: el sistema no solo se mantiene solo, **avisa cuando no puede**.

## Auditoría

Toda actualización deja **tres rastros**:

1. **Pestaña Actions** del repo — log completo de cada run con duración, status y output paso a paso.
2. **Historial de commits** — cada actualización es un commit del bot, con fecha en el mensaje.
3. **Issues automáticos** — si algo falla, queda registrado con su run asociado.

Esto significa que cualquiera (un reclutador, un colega, yo mismo en seis meses) puede reconstruir exactamente qué pasó en cualquier momento del último año.

## Cómo verificarlo

1. **Workflow file**: <https://github.com/israel44moran/observatorio-macro-sql/blob/main/.github/workflows/actualizar_observatorio.yml>
2. **Runs históricos**: <https://github.com/israel44moran/observatorio-macro-sql/actions>
3. **Commits del bot**: los reconoces porque el autor es `github-actions[bot]` y el mensaje empieza con `chore: actualizacion automatica`.

## Habilidades técnicas demostradas

- **YAML de CI/CD** con triggers múltiples, permisos granulares, control de concurrencia
- **GitHub Actions API**: caching de pip, group/endgroup en logs, step outputs, GITHUB_STEP_SUMMARY
- **Bash en CI**: parsing de `git status`, escritura a `$GITHUB_OUTPUT`, conditionals con `if:`
- **Auto-commit desde un bot** con identidad correcta (`github-actions[bot]`)
- **Failure handling**: abrir issues programáticamente con `actions/github-script` y la REST API de GitHub
- **Diseño idempotente**: el pipeline solo commitea cuando hay cambios reales

## Próximos pasos posibles

- **Notificación a Slack o Discord** cuando hay cambios significativos (PIB con variación > 1%, inflación con cambio > 0.5%)
- **Gráficas comparativas** entre la versión nueva y la anterior, publicadas como comentario en el commit
- **Despliegue en GitHub Pages** del `RESULTADOS.md` para que sea navegable como sitio web — preparativo para el Proyecto 11
