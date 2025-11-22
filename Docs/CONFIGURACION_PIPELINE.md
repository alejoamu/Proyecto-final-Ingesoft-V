# Guía de Configuración del Pipeline Integrado

## Requisitos Previos

1. Repositorio en GitHub
2. Acceso a GitHub Actions
3. SonarQube instalado y accesible (o usar SonarCloud)
4. (Opcional) Slack workspace para notificaciones
5. (Opcional) Email para notificaciones

## Paso 1: Configurar Secrets de GitHub

1. Ve a tu repositorio en GitHub
2. Settings → Secrets and variables → Actions
3. Agrega los siguientes secrets:

### SonarQube
```
SONAR_TOKEN: Token generado en SonarQube
SONAR_HOST_URL: https://sonarqube.example.com o https://sonarcloud.io
```

**Cómo obtener SONAR_TOKEN:**
- Si usas SonarCloud: Settings → Security → Generate Token
- Si usas SonarQube local: User → My Account → Security → Generate Token

### Email (Opcional)
```
EMAIL_USERNAME: tu_email@gmail.com
EMAIL_PASSWORD: App Password de Gmail (no la contraseña normal)
NOTIFICATION_EMAIL: email@example.com (destinatario de notificaciones)
```

**Cómo obtener App Password de Gmail:**
1. Google Account → Security
2. 2-Step Verification → ON
3. App passwords → Generate
4. Usar el password generado (16 caracteres)

### Slack (Opcional)
```
SLACK_WEBHOOK_URL: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

**Cómo obtener Slack Webhook:**
1. Slack App → Incoming Webhooks
2. Add to Slack
3. Seleccionar canal
4. Copiar Webhook URL

## Paso 2: Configurar Environments

### Stage Environment

1. Settings → Environments → New environment
2. Nombre: `stage`
3. Protection rules (opcional):
   - Required reviewers: 0 (o 1 si quieres aprobación)
   - Wait timer: 0 minutos

### Production Environment

1. Settings → Environments → New environment
2. Nombre: `production`
3. Protection rules (recomendado):
   - ✅ Required reviewers: 1 (mínimo)
   - ✅ Wait timer: 5 minutos (opcional, para dar tiempo de revisión)

## Paso 3: Configurar SonarQube

### Opción A: SonarCloud (Recomendado para proyectos open source)

1. Ir a https://sonarcloud.io
2. Login con GitHub
3. Importar repositorio
4. Copiar `SONAR_TOKEN` y `SONAR_PROJECT_KEY`
5. Agregar a GitHub Secrets:
   ```
   SONAR_TOKEN: [token de SonarCloud]
   SONAR_HOST_URL: https://sonarcloud.io
   ```

### Opción B: SonarQube Local (Ya configurado en Ansible)

1. El playbook de Ansible ya instala SonarQube
2. Acceder a http://tu-servidor-ci:9000/sonar
3. Login: admin/admin (cambiar en primer login)
4. Crear proyecto
5. Generar token
6. Agregar a GitHub Secrets

## Paso 4: Configurar Versionamiento Semántico

El pipeline usa `semantic-release` que detecta automáticamente el tipo de commit.

### Formato de Commits

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```bash
# Feature (minor version: 1.0.0 → 1.1.0)
git commit -m "feat: add new payment gateway"

# Fix (patch version: 1.0.0 → 1.0.1)
git commit -m "fix: resolve timeout in order service"

# Breaking change (major version: 1.0.0 → 2.0.0)
git commit -m "feat: redesign API

BREAKING CHANGE: API response format changed completely"

# Chore (no version bump)
git commit -m "chore: update dependencies"
```

### Tags Automáticos

El pipeline crea automáticamente:
- Git tags: `v1.0.0`, `v1.1.0`, etc.
- GitHub releases con changelog
- Docker image tags con versiones

## Paso 5: Probar el Pipeline

### Test en Branch Develop

1. Crear branch `develop` si no existe:
   ```bash
   git checkout -b develop
   git push origin develop
   ```

2. Hacer un commit de prueba:
   ```bash
   git commit -m "feat: test pipeline integration"
   git push origin develop
   ```

3. Verificar en GitHub Actions que el pipeline se ejecute

### Test de Notificaciones

1. Hacer un commit que falle intencionalmente (ej: agregar un error de sintaxis)
2. Verificar que se envíen notificaciones:
   - Email (si está configurado)
   - Slack (si está configurado)
   - GitHub Issue creado automáticamente

## Paso 6: Configurar Aprobaciones para Producción

1. Settings → Environments → `production`
2. En "Required reviewers", agregar al menos 1 reviewer
3. Guardar

**Comportamiento:**
- Cuando el pipeline llegue al job `deploy-prod`, se pausará
- Se enviará notificación a los reviewers
- Los reviewers deben aprobar en GitHub Actions
- Después de aprobación, continúa el despliegue

## Estructura del Pipeline

```
┌─────────────────┐
│  Code Quality   │ (SonarQube)
│  Security Scan  │ (Trivy)
└────────┬────────┘
         │
┌────────▼────────┐
│ Semantic Version│ (Auto versioning)
└────────┬────────┘
         │
┌────────▼────────┐
│ Unit/Integration│ (Maven tests)
│      Tests      │
└────────┬────────┘
         │
┌────────▼────────┐
│ Build Docker    │ (Multi-service)
│     Images      │
└────────┬────────┘
         │
┌────────▼────────┐
│   E2E Tests     │ (K8s + Newman)
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼────┐
│ Stage │ │  Prod │ (Requiere aprobación)
│ Deploy│ │ Deploy│
└───────┘ └───────┘
```

## Troubleshooting

### Error: "SONAR_TOKEN not found"
- Verificar que el secret esté configurado en GitHub
- Verificar que el nombre sea exactamente `SONAR_TOKEN`

### Error: "Quality Gate failed"
- Revisar reporte en SonarQube
- Corregir code smells y bugs
- Ajustar umbrales de calidad si es necesario

### Error: "Trivy found critical vulnerabilities"
- Revisar reporte de Trivy
- Actualizar dependencias vulnerables
- O ajustar severidad en el pipeline (no recomendado)

### Deploy no se ejecuta
- Verificar que el branch sea `stage` o `main`/`master`
- Verificar que el environment esté configurado
- Verificar que los jobs anteriores hayan pasado

### Notificaciones no se envían
- Verificar secrets configurados
- Para Slack: verificar formato del webhook
- Para Email: usar App Password, no contraseña normal
- Revisar logs del job `notify`

## Mejores Prácticas

1. **Commits**: Siempre usar conventional commits para versionamiento automático
2. **Branches**: 
   - `develop` → CI completo
   - `stage` → CI + Deploy a stage
   - `main`/`master` → CI + Deploy a prod (requiere aprobación)
3. **Reviews**: Siempre revisar PRs antes de merge
4. **Secrets**: Rotar secrets periódicamente
5. **Monitoring**: Revisar logs de pipeline regularmente

## Siguiente: Implementar Patrones de Diseño

Ver `Docs/PATRONES_DISENO.md` para:
- Patrones identificados
- Patrones recomendados (Saga, CQRS, Bulkhead)
- Guía de implementación

