# Pipelines nuevas: Versionado Semántico, Notificaciones y Aprobaciones

Este documento explica las nuevas pipelines creadas, cómo funcionan y qué ajustes debes realizar. Para propósito académico se incluyen opciones de variables "quemadas" (no recomendado en producción).

## 1) Versionado Semántico Automático
- Archivo: `.github/workflows/semantic-release.yml`
- Configuración: `.releaserc.json` (ramas main/master/develop/stage, plugins changelog, git, github).
- Dispara en push a main/master/develop/stage.
- Reglas: usa Conventional Commits (feat, fix, chore, refactor, BREAKING CHANGE).
- Resultado: crea tag, release y actualiza `CHANGELOG.md`.

Cómo probar
```bash
# Comitea con convención
git commit -m "feat: agregar validación X"
# Haz push a main/develop/stage según corresponda
```

## 2) Notificaciones de fallos
- Archivo: `.github/workflows/notifications.yml`
- Evento: `workflow_run` para pipelines existentes (Integrated CI/CD Pipeline) y Code Quality & Security.
- Slack: usa `BURNED_SLACK_WEBHOOK_URL` en el mismo workflow (ajústalo con tu URL de Incoming Webhook de Slack). Para Teams, `BURNED_TEAMS_WEBHOOK_URL`.
- Producción: sustituye por `secrets` (SLACK_WEBHOOK_URL / TEAMS_WEBHOOK_URL) si lo migras.

Cómo configurar (académico)
- Edita `notifications.yml` y reemplaza `https://hooks.slack.com/services/XXX/YYY/ZZZ` por tu webhook de Slack.

## 3) Aprobaciones para despliegue a Producción (Gated)
- Archivo: `.github/workflows/deploy-gated.yml`
- Disparo manual: `workflow_dispatch` con inputs `environment` (stage/production) y `version`.
- Environments: GitHub pausa el job hasta que aprueben (configura en Settings > Environments > stage / production > Required reviewers).

Cómo usar
1. Crea environments en GitHub: `stage` y `production`.
2. En cada environment define Required reviewers (usuarios o equipos) y opcionalmente un Secret Scope.
3. Ejecuta el workflow manualmente desde la pestaña Actions, elige `stage` o `production` y la `version` a desplegar.

## Variables/Secretos
- Para este proyecto académico se permiten variables "quemadas" en `notifications.yml` para Slack/Teams.
- Si quieres mover a secretos:
  - `SLACK_WEBHOOK_URL`, `TEAMS_WEBHOOK_URL` para notificaciones.
  - `SONAR_HOST_URL`, `SONAR_TOKEN` ya usados por Code Quality.

## Ejemplos rápidos
- Lanzar semantic release: push con Conventional Commits a `main`.
- Notificación: al finalizar cualquier run de "Integrated CI/CD Pipeline".
- Despliegue con aprobación: Actions > "Deploy (Gated)" > Run workflow > environment: `production`, version: `1.2.3`.

## Notas
- No se modificaron pipelines existentes; se añadieron workflows nuevos.
- Para producción real, NO "quemes" webhooks ni tokens en YAML.
- Puedes centralizar mensajes de Slack en un solo workflow o mantenerlos por job.

## Próximos pasos sugeridos
- Añadir `commitlint` para validar Conventional Commits.
- Migrar variables quemadas a `secrets`.
- Añadir recordatorios de aprobación (reacción automática / issue) si no se aprueba en X tiempo.
- Conectar `deploy-gated.yml` a manifiestos `k8s` reales.

