# Guía de CI y Pruebas (Dev) — Maven, Docker, Kubernetes y Newman

Este documento resume los cambios y el flujo de CI/Testing para la rama `dev`, cómo ejecutarlo en GitHub Actions y cómo correrlo en local (unitarias, integración y E2E con Newman sobre Kubernetes).

## Resumen de cambios

- Kubernetes (k8s):
  - Forzado `eureka.client.serviceUrl.defaultZone` a `http://service-discovery:8761/eureka/` en todos los microservicios (SPRING_APPLICATION_JSON) y registro por IP del Pod.
  - Servicios expuestos como NodePort para mantener puertos “originales” a través del contenedor `k3s`:
    - api-gateway: 30080 → host 8080
    - order-service: 30300 → 8300
    - payment-service: 30400 → 8400
    - product-service: 30500 → 8500
    - shipping-service: 30600 → 8600
    - user-service: 30700 → 8700
    - favourite-service: 30800 → 8800
  - API Gateway con rutas estáticas y preservando endpoints originales (incluye `Path=/app/** → PRODUCT-SERVICE` reescritura a `/product-service/**`).

- Pruebas añadidas por servicio:
  - Unitarias (@WebMvcTest + servicios mock):
    - product-service: `ProductResourceWebMvcTest`
    - user-service: `UserResourceWebMvcTest`
    - shipping-service: `OrderItemResourceWebMvcTest`
    - payment-service: `PaymentResourceWebMvcTest`
    - order-service: `OrderResourceWebMvcTest`
    - favourite-service: `FavouriteResourceWebMvcTest`
  - Integración (@SpringBootTest + @AutoConfigureMockMvc, eureka/config deshabilitados):
    - product-service: `ProductResourceIntegrationTests`
    - user-service: `UserResourceIntegrationTests`
    - shipping-service: `OrderItemResourceIntegrationTests`
    - payment-service: `PaymentResourceIntegrationTests`
    - order-service: `OrderResourceIntegrationTests`
    - favourite-service: `FavouriteResourceIntegrationTests`

- E2E con Newman:
  - Colección Postman: `tests/postman/ecommerce-e2e.postman_collection.json` (6 endpoints directos en puertos 8300/8400/8500/8600/8700/8800)

- Workflows de GitHub Actions:
  - `.github/workflows/dev-ci.yml` (CI dev)
    - Build y tests Maven
    - Docker build local (sin push)
    - Lint de k8s (kustomize + kubeconform)
  - `.github/workflows/dev-e2e.yml` (E2E + unit/integration)
    - Job 1: Unit & Integration (Maven)
    - Job 2: E2E con kind + kubectl + port-forward + Newman

## Cómo se ejecuta en GitHub Actions (rama dev)

- Se ejecuta automáticamente en `push` o `pull_request` a la rama `dev`, o manualmente (workflow_dispatch) desde la pestaña Actions.
- `dev-ci.yml` realiza:
  1) `mvn package` con tests.
  2) Construcción de imágenes Docker localmente (no publica).
  3) Renderiza y valida los manifiestos k8s.
- `dev-e2e.yml` realiza:
  1) Unitarias e Integración (Maven): publica artefacto `surefire-reports`.
  2) E2E: crea un cluster kind efímero, aplica `k8s/`, espera `Ready`, hace port-forward de servicios a localhost y ejecuta Newman (artefacto `newman-results`).

Secretos requeridos: ninguno (los workflows dev no publican imágenes ni usan clusters externos).

## Ejecutar localmente (unit + integración + E2E)

- Requisitos: Java 11, Maven, Node.js (para Newman), Docker (si quieres usar k3s o kind).

### 1) Unitarias e Integración

```bat
cd /d "C:\Users\aguir\Downloads\ti2 para calificar\ecommerce-microservice-backend-app"
mvn -B -DskipTests=false -Deureka.client.enabled=false -Dspring.cloud.config.enabled=false test
```

- Los reportes JUnit se generan en `**/target/surefire-reports/*.xml`.

### 2) E2E con tu k3s local

Sigue la guía `Ansible/k3s/README.md` para levantar el clúster k3s y aplicar `k8s/`. Con los NodePorts publicados por `Ansible/docker-compose.yml`, ejecuta:

```bat
npm i -g newman
newman run tests\postman\ecommerce-e2e.postman_collection.json
```

Endpoints usados por la colección:
- http://localhost:8500/product-service/api/products
- http://localhost:8700/user-service/api/users
- http://localhost:8600/shipping-service/api/shippings
- http://localhost:8400/payment-service/api/payments
- http://localhost:8300/order-service/api/orders
- http://localhost:8800/favourite-service/api/favourites

### 3) E2E con kind efímero (opcional, como hace el workflow)

```bash
# Linux/macOS (o Git Bash)
kind create cluster --name dev-e2e --wait 120s
kubectl apply -k k8s
kubectl -n ecommerce wait --for=condition=available --timeout=240s deployment --all
# Port-forward a localhost en segundo plano
kubectl -n ecommerce port-forward svc/product-service 8500:8500 &
kubectl -n ecommerce port-forward svc/user-service 8700:8700 &
# ...repite para 8600, 8400, 8300, 8800

npm i -g newman
newman run tests/postman/ecommerce-e2e.postman_collection.json

kind delete cluster --name dev-e2e
```

## Arquitectura de los workflows

### dev-ci.yml
- Job `build-java`:
  - Java 11 Temurin
  - Cache Maven
  - `mvn package` (con tests) y publica surefire-reports
- Job `docker-build`:
  - Buildx
  - Construye imágenes con `context: .` y `file: <servicio>/Dockerfile` (sin push)
- Job `k8s-lint`:
  - kustomize build → `k8s-rendered.yaml`
  - kubeconform strict (ignore-missing-schemas)

### dev-e2e.yml
- Job `unit-integration` (previo al E2E):
  - `mvn test` con eureka/config deshabilitados
  - Publica surefire-reports
- Job `e2e`:
  - kind + kubectl
  - `kubectl apply -k k8s` + `wait` de deployments
  - port-forward de 6 servicios
  - warm-up (intento con retry) y ejecución de Newman
  - Publica `newman-results.xml`

## Troubleshooting

- 404/503 justo al despliegue (E2E):
  - Espera a que todos los deployments estén `Available` y Eureka registre las apps (el workflow ya hace `wait` y warm-up). Reintenta Newman local si es necesario.
- Tests de integración fallan por Eureka o Config:
  - Verifica que en los tests se estés pasando `-Deureka.client.enabled=false -Dspring.cloud.config.enabled=false` o revisa las anotaciones `@SpringBootTest(properties=...)` en las clases de test.
- NodePorts ocupados en el host:
  - Asegúrate de tener libres 8080, 8300, 8400, 8500, 8600, 8700, 8800.
- ¿Dónde están los artefactos?
  - En cada corrida, ve a Actions → la ejecución → Artifacts: `surefire-reports`, `k8s-rendered`, `newman-results`.

## Referencias útiles
- Guía de k3s local y NodePorts: `Ansible/k3s/README.md`
- Manifiestos k8s: carpeta `k8s/`
- Workflows: `.github/workflows/dev-ci.yml` y `.github/workflows/dev-e2e.yml`
- Colección Postman: `tests/postman/ecommerce-e2e.postman_collection.json`

## Siguientes pasos (opcional)
- Añadir Jacoco para cobertura y publicarla en artefactos.
- Extender Newman para probar el API Gateway (8080) además de NodePorts.
- Agregar despliegue CD a un registro (GHCR/Docker Hub) y a un clúster remoto cuando se requiera.

