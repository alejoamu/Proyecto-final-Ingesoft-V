# Documentación de Integración - Proyecto Final

## Resumen de Integración

Este documento describe la integración de los avances de ambos proyectos (Amu y compañero) para el proyecto final.

## Componentes Integrados

### 1. Pipelines de CI/CD

#### Pipeline Integrado Principal
- **Archivo**: `.github/workflows/integrated-pipeline.yml`
- **Características**:
  - ✅ Análisis de código con SonarQube
  - ✅ Escaneo de seguridad con Trivy
  - ✅ Versionamiento semántico automático
  - ✅ Pruebas unitarias e integración
  - ✅ Pruebas E2E con Kubernetes y Newman
  - ✅ Build y push de imágenes Docker
  - ✅ Notificaciones automáticas (Email/Slack/GitHub Issues)
  - ✅ Aprobaciones para despliegues en producción

#### Pipelines del Proyecto Amu
- **Ubicación**: `.github/workflows/` (múltiples pipelines por servicio)
- **Características**:
  - Pipelines específicos por servicio
  - Soporte para dev, stage y prod
  - Validación de Kubernetes

#### Pipelines del Proyecto Compañero
- **Archivos**:
  - `dev-ci.yml`: CI básico con Maven y Docker
  - `dev-e2e.yml`: Pruebas E2E con kind y Newman
- **Integrados en**: `integrated-pipeline.yml`

### 2. Infraestructura como Código

#### Terraform (Proyecto Compañero)
- **Ubicación**: `infra/`
- **Estado**: ✅ Corregido (credenciales movidas a variables de entorno)
- **Mejoras**:
  - `.gitignore` actualizado para no commitar `terraform.tfvars`
  - README con instrucciones de uso
  - Variables de entorno para passwords

#### Ansible (Proyecto Compañero)
- **Ubicación**: `Ansible/`
- **Estado**: ✅ Corregido (credenciales movidas a Ansible Vault)
- **Mejoras**:
  - Uso de Ansible Vault para credenciales
  - README con instrucciones
  - Ejemplo de vault file

### 3. Pruebas

#### Pruebas E2E (Proyecto Amu)
- **Ubicación**: `e2e-tests/`
- **Herramientas**: Postman + Newman
- **Integrado en**: Pipeline principal

#### Pruebas de Performance (Proyecto Amu)
- **Ubicación**: `performance-tests/`
- **Herramientas**: Locust
- **Nota**: Ya configurado en Ansible playbook

### 4. Patrones de Diseño

#### Documentación
- **Archivo**: `Docs/PATRONES_DISENO.md`
- **Contenido**:
  - 10 patrones identificados en la arquitectura actual
  - 3 patrones recomendados para implementar:
    1. **Saga Pattern** - Para transacciones distribuidas
    2. **CQRS Pattern** - Para optimización de lecturas/escrituras
    3. **Bulkhead Pattern** - Para aislamiento de recursos

## Configuración Requerida

### 1. Secrets de GitHub

Configurar los siguientes secrets en GitHub Settings → Secrets and variables → Actions:

```bash
# SonarQube
SONAR_TOKEN=your_sonar_token
SONAR_HOST_URL=https://sonarqube.example.com

# Email Notifications
EMAIL_USERNAME=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
NOTIFICATION_EMAIL=team@example.com

# Slack Notifications
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### 2. Environments en GitHub

Configurar environments con protección de ramas:

1. **Stage Environment**:
   - Settings → Environments → New environment → `stage`
   - Protection rules: Require reviewers (opcional para stage)

2. **Production Environment**:
   - Settings → Environments → New environment → `production`
   - Protection rules: 
     - ✅ Required reviewers (mínimo 1)
     - ✅ Wait timer (opcional, recomendado: 5 minutos)

### 3. SonarQube

1. Instalar SonarQube (ya configurado en Ansible)
2. Crear proyecto en SonarQube
3. Generar token de acceso
4. Configurar en GitHub Secrets

### 4. Versionamiento Semántico

El pipeline usa `semantic-release` que detecta automáticamente el tipo de commit:

- `feat:` → Minor version bump (1.0.0 → 1.1.0)
- `fix:` → Patch version bump (1.0.0 → 1.0.1)
- `BREAKING CHANGE:` → Major version bump (1.0.0 → 2.0.0)

**Ejemplo de commits:**
```bash
git commit -m "feat: add new payment method"
git commit -m "fix: resolve order service timeout"
git commit -m "feat: new API endpoint

BREAKING CHANGE: API response format changed"
```

### 5. Ansible Vault

```bash
# Crear vault file
ansible-vault create Ansible/group_vars/all/vault.yml

# Editar vault file
ansible-vault edit Ansible/group_vars/all/vault.yml

# Ejecutar playbook con vault
ansible-playbook -i Ansible/inventory.ini Ansible/playbook.yml --ask-vault-pass
```

### 6. Terraform

```bash
# Configurar variables de entorno
export TF_VAR_region="Mexico Central"
export TF_VAR_user="adminuser"
export TF_VAR_password="your_password"
export TF_VAR_prefix_name="devops"

# O crear terraform.tfvars (NO COMMIT)
cp infra/terraform.tfvars.example infra/terraform.tfvars
# Editar terraform.tfvars con tus valores

# Inicializar y aplicar
cd infra
terraform init
terraform plan
terraform apply
```

## Flujo de Trabajo

### Desarrollo
1. Crear feature branch desde `develop`
2. Hacer cambios y commits (usar conventional commits)
3. Push → Trigger pipeline de CI
4. Crear Pull Request → Ejecuta validaciones
5. Merge a `develop` → Ejecuta pipeline completo

### Stage
1. Merge a `stage` branch
2. Pipeline ejecuta:
   - Code quality (SonarQube)
   - Security scan (Trivy)
   - Tests
   - Build Docker images
   - E2E tests
   - Deploy to stage (requiere aprobación si está configurado)

### Producción
1. Merge a `main`/`master`
2. Pipeline ejecuta todo lo anterior
3. Deploy to production (requiere aprobación obligatoria)
4. Notificaciones enviadas

## Notificaciones

### Email
- Se envía automáticamente cuando el pipeline falla
- Configurar `EMAIL_USERNAME`, `EMAIL_PASSWORD`, `NOTIFICATION_EMAIL`

### Slack
- Se envía siempre (éxito o fallo)
- Configurar `SLACK_WEBHOOK_URL`

### GitHub Issues
- Se crea automáticamente un issue cuando el pipeline falla
- Etiquetas: `bug`, `ci/cd`

## Troubleshooting

### Pipeline falla en SonarQube
- Verificar que `SONAR_TOKEN` y `SONAR_HOST_URL` estén configurados
- Verificar que SonarQube esté accesible desde GitHub Actions

### Pipeline falla en Trivy
- Verificar que las imágenes Docker se hayan construido correctamente
- Revisar logs de Trivy para vulnerabilidades críticas

### Deploy no se ejecuta
- Verificar que el branch sea correcto (`stage` o `main`/`master`)
- Verificar que los environments estén configurados en GitHub
- Verificar que las aprobaciones estén configuradas correctamente

### Notificaciones no se envían
- Verificar que los secrets estén configurados
- Para Slack: verificar formato del webhook URL
- Para Email: usar App Password de Gmail (no la contraseña normal)

## Próximos Pasos

1. ✅ Configurar secrets en GitHub
2. ✅ Configurar environments (stage, production)
3. ✅ Configurar SonarQube y obtener token
4. ✅ Configurar webhook de Slack (opcional)
5. ✅ Configurar email para notificaciones (opcional)
6. ✅ Probar pipeline en branch `develop`
7. ✅ Configurar aprobaciones para producción

## Referencias

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Semantic Release](https://semantic-release.gitbook.io/)
- [Ansible Vault](https://docs.ansible.com/ansible/latest/user_guide/vault.html)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)

