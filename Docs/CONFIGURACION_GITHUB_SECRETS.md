# Configuración de Secrets en GitHub

## 📋 Secrets Requeridos

Para que todos los pipelines funcionen correctamente, necesitas configurar los siguientes secrets en GitHub.

### Cómo Configurar Secrets en GitHub

1. Ve a tu repositorio en GitHub
2. Click en **Settings** (Configuración)
3. En el menú lateral, click en **Secrets and variables** > **Actions**
4. Click en **New repository secret**
5. Ingresa el nombre y valor del secret
6. Click en **Add secret**

---

## 🔐 Secrets OBLIGATORIOS

### 1. DOCKER_USERNAME
- **Descripción**: Usuario de Docker Hub o GitHub Container Registry
- **Ejemplo**: `tu-usuario-docker` o `ghcr.io/tu-usuario`
- **Usado en**: Todos los pipelines que construyen y publican imágenes Docker

### 2. DOCKER_PASSWORD
- **Descripción**: Contraseña o token de acceso a Docker Hub o GitHub Container Registry
- **Para Docker Hub**: Tu contraseña o un Personal Access Token
- **Para GitHub Container Registry**: Un Personal Access Token con permisos `write:packages`
- **Usado en**: Todos los pipelines que construyen y publican imágenes Docker

### 3. PROJECT_VERSION
- **Descripción**: Versión del proyecto para etiquetar las imágenes Docker
- **Ejemplo**: `1.0.0`, `0.1.0`, `v1.0.0`
- **Usado en**: Todos los pipelines que construyen y publican imágenes Docker

---

## 🔐 Secrets OPCIONALES (para funcionalidades avanzadas)

### 4. SONAR_TOKEN
- **Descripción**: Token de autenticación de SonarQube/SonarCloud
- **Cómo obtenerlo**:
  - SonarCloud: https://sonarcloud.io → My Account → Security → Generate Token
  - SonarQube: User > My Account > Security > Generate Token
- **Usado en**: `integrated-pipeline.yml` (análisis de calidad de código)

### 5. SONAR_HOST_URL
- **Descripción**: URL del servidor SonarQube
- **Ejemplo**: `https://sonarcloud.io` (para SonarCloud)
- **Ejemplo**: `https://sonarqube.tu-dominio.com` (para SonarQube self-hosted)
- **Usado en**: `integrated-pipeline.yml` (análisis de calidad de código)

### 6. EMAIL_USERNAME
- **Descripción**: Usuario SMTP para enviar notificaciones por email
- **Ejemplo**: `notificaciones@tu-dominio.com`
- **Usado en**: `integrated-pipeline.yml` (notificaciones de fallos)

### 7. EMAIL_PASSWORD
- **Descripción**: Contraseña del usuario SMTP
- **Usado en**: `integrated-pipeline.yml` (notificaciones de fallos)

### 8. NOTIFICATION_EMAIL
- **Descripción**: Email destino para recibir notificaciones de fallos
- **Ejemplo**: `devops@tu-dominio.com`
- **Usado en**: `integrated-pipeline.yml` (notificaciones de fallos)

### 9. SLACK_WEBHOOK_URL
- **Descripción**: URL del webhook de Slack para notificaciones
- **Cómo obtenerlo**: Slack → Apps → Incoming Webhooks → Add to Slack
- **Formato**: `https://hooks.slack.com/services/TEAM_ID/CHANNEL_ID/WEBHOOK_TOKEN`
- **Ejemplo de formato** (NO usar este valor real): `https://hooks.slack.com/services/T1234567890/B1234567890/abc123def456ghi789`
- **Usado en**: `integrated-pipeline.yml` (notificaciones de fallos)

---

## ✅ Secrets Automáticos (No Requieren Configuración)

### GITHUB_TOKEN
- **Descripción**: Token automático proporcionado por GitHub Actions
- **No requiere configuración**: Se genera automáticamente
- **Usado en**: Varios pipelines para autenticación con GitHub API

---

## 🎯 Configuración Mínima Recomendada

Para que los pipelines básicos funcionen, configura al menos:

1. ✅ `DOCKER_USERNAME`
2. ✅ `DOCKER_PASSWORD`
3. ✅ `PROJECT_VERSION`

Con estos 3 secrets, los siguientes pipelines funcionarán:
- ✅ Todos los `*-pipeline-*-push.yml` (construcción y publicación de imágenes)
- ✅ `master-environment.yml` (despliegue a producción)
- ✅ `stage-environment.yml` (despliegue a staging)

---

## 📝 Ejemplo de Configuración

### Para Docker Hub:
```
DOCKER_USERNAME = tu-usuario-dockerhub
DOCKER_PASSWORD = tu-token-o-contraseña
PROJECT_VERSION = 1.0.0
```

### Para GitHub Container Registry:
```
DOCKER_USERNAME = ghcr.io/tu-usuario-github
DOCKER_PASSWORD = ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (Personal Access Token)
PROJECT_VERSION = 1.0.0
```

---

## ⚠️ Notas Importantes

1. **Nunca compartas tus secrets**: Los secrets son privados y solo visibles para los workflows
2. **Usa tokens en lugar de contraseñas**: Para Docker Hub y GitHub, es más seguro usar Personal Access Tokens
3. **Rotación de secrets**: Cambia tus secrets periódicamente por seguridad
4. **Permisos mínimos**: Cuando crees tokens, otorga solo los permisos necesarios

---

## 🔍 Verificar Configuración

Después de configurar los secrets, puedes verificar que están configurados correctamente:

1. Ve a **Settings** > **Secrets and variables** > **Actions**
2. Deberías ver todos los secrets listados (sin mostrar sus valores)
3. Los secrets estarán disponibles automáticamente en todos los workflows

---

## 🚨 Troubleshooting

### Error: "Secret not found"
- Verifica que el secret esté configurado en el repositorio correcto
- Verifica que el nombre del secret sea exactamente el mismo (case-sensitive)

### Error: "Docker login failed"
- Verifica que `DOCKER_USERNAME` y `DOCKER_PASSWORD` sean correctos
- Para GitHub Container Registry, asegúrate de usar un Personal Access Token con permisos `write:packages`

### Error: "SonarQube authentication failed"
- Verifica que `SONAR_TOKEN` sea válido y no haya expirado
- Verifica que `SONAR_HOST_URL` sea correcto

