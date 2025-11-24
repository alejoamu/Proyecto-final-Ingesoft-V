# Guía de Seguridad - Ecommerce Microservices

Esta guía documenta las implementaciones de seguridad del proyecto, incluyendo escaneo continuo de vulnerabilidades, gestión de secretos, RBAC y TLS.

## Tabla de Contenidos

1. [Escaneo Continuo de Vulnerabilidades](#escaneo-continuo-de-vulnerabilidades)
2. [Gestión Segura de Secretos](#gestión-segura-de-secretos)
3. [RBAC (Role-Based Access Control)](#rbac-role-based-access-control)
4. [TLS para Servicios Públicos](#tls-para-servicios-públicos)
5. [Mejores Prácticas](#mejores-prácticas)

## Escaneo Continuo de Vulnerabilidades

### Herramientas Implementadas

#### 1. OWASP Dependency-Check
- **Propósito**: Escanea dependencias Maven en busca de vulnerabilidades conocidas (CVE)
- **Integración**: Plugin Maven, workflows CI/CD, escaneo programado diario
- **Configuración**: `pom.xml` con umbral CVSS >= 7.0

**Ejecución local:**
```bash
# Windows
owasp-scan.cmd

# Linux/macOS
./owasp-scan.sh
```

**Reportes:**
- HTML: `{module}/target/dependency-check-report.html`
- JSON: `{module}/target/dependency-check-report.json`
- XML: `{module}/target/dependency-check-report.xml`

#### 2. Trivy
- **Propósito**: Escanea filesystem, imágenes Docker, Dockerfiles y dependencias
- **Integración**: Workflows CI/CD, escaneo programado diario, scripts locales

**Ejecución local:**
```bash
# Escaneo de filesystem
trivy fs --severity HIGH,CRITICAL --ignore-unfixed .

# Escaneo de imagen Docker
trivy image --severity HIGH,CRITICAL <image:tag>

# Escaneo de Dockerfile
trivy config Dockerfile
```

#### 3. Escaneo Programado
- **Workflow**: `.github/workflows/security-scan-scheduled.yml`
- **Frecuencia**: Diario a las 2 AM UTC
- **Alcance**: 
  - OWASP Dependency-Check para todos los servicios
  - Trivy filesystem scan
  - Trivy Dockerfile scan
  - Trivy container image scan
- **Reportes**: Se suben como SARIF a GitHub Security

### Integración en CI/CD

**En cada Pull Request:**
- OWASP Dependency-Check ejecuta automáticamente
- Trivy escanea filesystem y Dockerfiles
- El build falla si hay vulnerabilidades CRITICAL/HIGH no corregidas

**En cada push a main:**
- Escaneo completo de vulnerabilidades
- Escaneo de imágenes Docker después del build
- Reportes publicados en GitHub Security

**Escaneo diario:**
- Escaneo completo de todos los servicios
- Actualización de base de datos de vulnerabilidades
- Generación de reportes consolidados

## Gestión Segura de Secretos

### Kubernetes Secrets

**Creación de Secrets:**

```bash
# Crear secret desde archivos
kubectl create secret generic database-credentials \
  --from-literal=username=db_user \
  --from-literal=password=db_password \
  --namespace=ecommerce

# Crear secret desde archivo
kubectl create secret generic api-keys \
  --from-file=api-key=/path/to/api-key.txt \
  --namespace=ecommerce
```

**Uso en Deployments:**

Los secrets se referencian en los deployments usando `secretKeyRef`:

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: database-credentials
        key: password
```

**Ejemplo de Secret:**
Ver `k8s/security/secrets.example.yaml` para ejemplos de configuración.

### Sealed Secrets (Recomendado para Producción)

Sealed Secrets permite almacenar secrets cifrados en Git:

1. **Instalar Sealed Secrets:**
```bash
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml
```

2. **Crear Sealed Secret:**
```bash
# Crear secret normal
kubectl create secret generic database-credentials \
  --from-literal=username=db_user \
  --from-literal=password=db_password \
  --dry-run=client -o yaml > secret.yaml

# Sellarlo
kubectl seal -f secret.yaml -o sealed-secret.yaml

# Aplicar sealed secret
kubectl apply -f sealed-secret.yaml
```

### External Secrets Operator (Alternativa)

Para integración con proveedores externos (AWS Secrets Manager, HashiCorp Vault, etc.):

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets \
  external-secrets/external-secrets \
  -n external-secrets-system \
  --create-namespace
```

### Mejores Prácticas

1. **Nunca commits secrets en texto plano** en Git
2. **Usar Sealed Secrets o External Secrets** para producción
3. **Rotar secrets regularmente** (cada 90 días)
4. **Limit access** a secrets usando RBAC
5. **Auditar acceso** a secrets con auditoría de Kubernetes

## RBAC (Role-Based Access Control)

### Configuración Implementada

**Archivo**: `k8s/security/rbac.yaml`

### ServiceAccounts

Creados para diferentes namespaces:

- `microservice-sa` (namespace: ecommerce) - Para microservicios
- `monitoring-sa` (namespace: monitoring) - Para Prometheus y Grafana
- `logging-sa` (namespace: logging) - Para Filebeat y Elasticsearch

### Roles

**Role: microservice-role**
- Permisos: get, list en configmaps y secrets
- Permisos: get, list, watch en pods
- Scope: namespace ecommerce

**Role: monitoring-role**
- Permisos: get, list, watch en pods, services, endpoints
- Permisos: get, list en configmaps
- Scope: namespace monitoring

**Role: logging-role**
- Permisos: get, list, watch en pods, services
- Permisos: get, list en configmaps
- Scope: namespace logging

### ClusterRoles

**ClusterRole: prometheus-cluster-role**
- Permisos: Acceso a recursos de cluster para service discovery
- Incluye: nodes, services, endpoints, pods, ingresses
- Incluye: /metrics endpoint

### RoleBindings y ClusterRoleBindings

Cada ServiceAccount está vinculado a su Role/ClusterRole correspondiente, aplicando el principio de menor privilegio.

### Uso en Deployments

```yaml
spec:
  serviceAccountName: microservice-sa
  containers:
    - name: service-name
      # ...
```

### Verificar Permisos

```bash
# Ver permisos de un ServiceAccount
kubectl auth can-i get secrets --as=system:serviceaccount:ecommerce:microservice-sa -n ecommerce

# Listar todos los roles
kubectl get roles -n ecommerce

# Ver detalles de un role
kubectl describe role microservice-role -n ecommerce
```

## TLS para Servicios Públicos

### Cert-Manager con Let's Encrypt

**Instalación de Cert-Manager:**

```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.0/cert-manager.yaml

# Verificar instalación
kubectl get pods -n cert-manager
```

**Configuración de ClusterIssuer:**

Ver `k8s/security/cert-manager.yaml`:

- `letsencrypt-prod`: Para certificados de producción
- `letsencrypt-staging`: Para pruebas (límite de rate más alto)

**Aplicar ClusterIssuers:**
```bash
kubectl apply -f k8s/security/cert-manager.yaml
```

### Configuración de Ingress con TLS

**Archivo**: `k8s/security/ingress-tls.yaml`

**Ejemplo de Ingress con TLS:**

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway-ingress
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.ecommerce.com
    secretName: api-gateway-tls
  rules:
  - host: api.ecommerce.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 8080
```

**Aplicar Ingress con TLS:**
```bash
kubectl apply -f k8s/security/ingress-tls.yaml
```

### Verificación de Certificados

```bash
# Ver certificados emitidos
kubectl get certificates -A

# Ver detalles de un certificado
kubectl describe certificate api-gateway-tls -n ecommerce

# Ver certificado en formato legible
kubectl get secret api-gateway-tls -n ecommerce -o jsonpath='{.data.tls\.crt}' | base64 -d | openssl x509 -text -noout
```

### Renovación Automática

Cert-manager renueva automáticamente los certificados 30 días antes de su expiración.

Verificar renovación:
```bash
kubectl get certificaterequests -A
```

## Mejores Prácticas

### Seguridad General

1. **Principio de Menor Privilegio**: Asignar solo los permisos necesarios
2. **Defensa en Profundidad**: Múltiples capas de seguridad
3. **Auditoría Regular**: Revisar logs y acceso a recursos
4. **Actualización Continua**: Mantener dependencias y componentes actualizados

### Gestión de Secretos

1. **Nunca almacenar en texto plano** en Git o código
2. **Rotar regularmente** (recomendado cada 90 días)
3. **Usar herramientas especializadas** (Sealed Secrets, External Secrets)
4. **Limitar acceso** con RBAC
5. **Auditar acceso** a secrets

### RBAC

1. **Namespaces para aislamiento** de recursos
2. **ServiceAccounts dedicados** por aplicación
3. **Roles específicos** con permisos mínimos
4. **Revisar permisos regularmente**
5. **Usar ClusterRoles solo cuando sea necesario**

### TLS/HTTPS

1. **Siempre usar HTTPS** para servicios públicos
2. **Forzar redirección HTTP a HTTPS**
3. **Usar certificados válidos** (Let's Encrypt en producción)
4. **Monitorear expiración** de certificados
5. **Considerar mTLS** para comunicación entre servicios

### Escaneo de Vulnerabilidades

1. **Ejecutar escaneos regularmente** (diario automatizado)
2. **Revisar reportes** de seguridad semanalmente
3. **Priorizar vulnerabilidades CRITICAL/HIGH**
4. **Aplicar parches** lo antes posible
5. **Mantener base de datos** de vulnerabilidades actualizada

## Archivos de Configuración

- `k8s/security/rbac.yaml` - Configuración RBAC
- `k8s/security/secrets.example.yaml` - Ejemplos de Secrets
- `k8s/security/cert-manager.yaml` - ClusterIssuers para Let's Encrypt
- `k8s/security/ingress-tls.yaml` - Ingresses con TLS
- `.github/workflows/security-scan-scheduled.yml` - Escaneo programado

## Referencias

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [OWASP Dependency-Check](https://owasp.org/www-project-dependency-check/)
- [Trivy Documentation](https://aquasecurity.github.io/trivy/)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)

