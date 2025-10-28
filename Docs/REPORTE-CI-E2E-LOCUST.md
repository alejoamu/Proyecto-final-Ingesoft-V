# Reporte de Pipelines: CI, E2E y Pruebas de Carga (Locust)

Este documento resume la configuración, resultados y análisis de los pipelines implementados en el repositorio, cubriendo:
- Pruebas unitarias e integración (CI)
- Readiness E2E en Kubernetes (kind) y pruebas de carga con Locust
- Publicación de reportes en GitHub Pages
- Reglas de protección de ramas y checks requeridos

> Nota: Donde se solicitan “pantallazos”, se indican ubicaciones sugeridas para capturarlos y adjuntarlos. Este repo también publica un sitio estático con los reportes bajo GitHub Pages.

---

## 1. Visión general de pipelines y artefactos

Pipelines principales:
- CI + E2E + Locust + Pages (workflow combinado)
  - Job: Unit & Integration Tests (Surefire)
  - Job: E2E Readiness + Locust (cluster kind + port-forward + Locust)
  - Job: Deploy Pages (publicación en GitHub Pages)
- Dev E2E - Locust (workflow específico para `dev`)

Artefactos y sitio:
- Surefire reports (unit/integration) por módulo
- E2E readiness (HTML): estado de endpoints críticos (OK/FAIL/WARN)
- Locust (HTML + CSV): resultados de carga (tiempos de respuesta, throughput, errores)
- Sitio estático en Pages con índice: `unit-integration/`, `e2e/`, `locust/`

---

## 2. Configuración de pipelines

### 2.1 Workflow combinado: CI + E2E + Locust + Pages
Archivo: `.github/workflows/ci-all-pages.yml`

Disparadores:
- push / pull_request: ramas `main`, `master` y `dev`
- Manual: `workflow_dispatch`

Descripción de jobs:
- `build-and-test`: ejecuta `./mvnw test` para todos los módulos y colecta `target/surefire-reports` en `site/unit-integration/`. Genera un `index.html` base.
- `e2e-and-locust`: crea un cluster kind (Kubernetes), aplica manifests de `k8s/`, espera rollouts, hace port-forward de Services y realiza readiness checks (HTML). Ejecuta Locust en modo headless y guarda reportes en `site/locust/`.
- `deploy-pages`: publica el contenido del folder `site/` en GitHub Pages.

Fragmento (resumen) YAML clave:

```yaml
on:
  push:
    branches: [ main, master, dev ]
  pull_request:
    branches: [ main, master, dev ]
  workflow_dispatch: {}

jobs:
  build-and-test:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '11', cache: maven }
      - run: ./mvnw -B -q -DskipTests=false test
      - run: |
          SITE_DIR="site"; mkdir -p "$SITE_DIR/unit-integration"
          find . -type d -path '*/target/surefire-reports' | while read -r d; do \
            m=$(echo "$d" | sed -E 's#\./([^/]+)/.*#\1#'); out="$SITE_DIR/unit-integration/$m"; \
            mkdir -p "$out"; cp -r "$d"/* "$out/" || true; done
          # genera index.html

  e2e-and-locust:
    needs: build-and-test
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: |
          python -m pip install --upgrade pip
          pip install -r tests/locust/requirements.txt
      - uses: helm/kind-action@v1.9.0
        with: { cluster_name: dev-e2e, node_image: kindest/node:v1.30.0 }
      - run: |
          kubectl get ns ecommerce || kubectl create ns ecommerce
          # kubectl apply de manifests en k8s/
      - run: |
          for d in service-discovery cloud-config; do \
            kubectl -n ecommerce rollout status deploy/$d --timeout=180s || kubectl -n ecommerce get pods -o wide; done
      - run: |
          for d in user-service product-service order-service payment-service shipping-service favourite-service; do \
            kubectl -n ecommerce rollout status deploy/$d --timeout=240s || kubectl -n ecommerce get pods -o wide; done
      - name: Port-forward services
        run: |
          kubectl -n ecommerce port-forward svc/product-service 8500:8500 &
          kubectl -n ecommerce port-forward svc/user-service    8700:8700 &
          kubectl -n ecommerce port-forward svc/shipping-service 8600:8600 &
          kubectl -n ecommerce port-forward svc/payment-service  8400:8400 &
          kubectl -n ecommerce port-forward svc/order-service    8300:8300 &
          kubectl -n ecommerce port-forward svc/favourite-service 8800:8800 &
      - name: E2E readiness (HTML)
        run: |
          # retry + curl a endpoints y generar site/e2e/index.html
      - name: Locust headless
        run: |
          locust -f tests/locust/locustfile.py --headless -u 50 -r 10 -t 1m \
            --html locust-report.html --csv locust-results
          mkdir -p site/locust; mv locust-report.html locust-results* site/locust/

  deploy-pages:
    needs: [build-and-test, e2e-and-locust]
    steps:
      - uses: actions/deploy-pages@v4
```

Pantallazos sugeridos:
- Captura de configuración de triggers (Actions > workflow > … > “This workflow will run on …”).
- Vista del job `build-and-test` con summary de tests.
- Vista del job `e2e-and-locust` mostrando `rollout status` y ejecución de Locust.
- Vista del job `deploy-pages` con URL publicada.

Ubicación sugerida para guardarlos en el repo: `Docs/images/ci-all-pages/*` y referenciarlos en este documento.

---

### 2.2 Workflow Dev E2E - Locust (rama dev)
Archivo: `.github/workflows/locust-e2e.yml`

Disparadores:
- push / pull_request: rama `dev`
- Manual: `workflow_dispatch`

Descripción:
- Flujo equivalente al job `e2e-and-locust` del workflow combinado, orientado a validación rápida en `dev`. Sube reportes de Locust como artifacts.

Fragmento (resumen) YAML clave:

```yaml
on:
  push: { branches: [ "dev" ] }
  pull_request: { branches: [ "dev" ] }
  workflow_dispatch: {}

jobs:
  e2e-locust:
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with: { python-version: '3.11' }
      - run: pip install -r tests/locust/requirements.txt
      - uses: helm/kind-action@v1.9.0
        with: { cluster_name: dev-e2e, node_image: kindest/node:v1.30.0 }
      - run: |
          kubectl get ns ecommerce || kubectl create ns ecommerce
          # kubectl apply; rollout; port-forward
      - run: |
          locust -f tests/locust/locustfile.py --headless -u 50 -r 10 -t 1m \
            --html locust-report.html --csv locust-results
      - uses: actions/upload-artifact@v4
        with: { name: locust-report, path: "locust-report.html\nlocust-results*.csv" }
```

Pantallazos sugeridos:
- Vista del workflow en `dev` con jobs verdes y artifacts disponibles para descarga.

---

## 3. Resultados: dónde verlos y cómo capturar pantallazos

### 3.1 GitHub Pages (sitio estático de reportes)
- Publicado por `CI + E2E + Locust + Pages / deploy-pages`.
- URL: Settings > Pages > te mostrará la dirección (formato: `https://<org|user>.github.io/<repo>/`).
- Estructura:
  - `index.html` (índice)
  - `unit-integration/` (Surefire por módulo)
  - `e2e/` (readiness HTML)
  - `locust/` (locust-report.html, locust-results.csv)

Pantallazos sugeridos:
- Captura del sitio (índice) y de cada sección: unit-integration, e2e y locust.

### 3.2 Artifacts en GitHub Actions
- Workflow “Dev E2E - Locust”: artifact `locust-report` con HTML/CSV.
- Workflow “CI + E2E + Locust + Pages”: publica el folder `site/` como artifact de Pages.

Pantallazos sugeridos:
- Vista de artifacts adjuntos al run.

---

## 4. Análisis de resultados

### 4.1 Unitarios e Integración (Surefire)
- Indicadores clave: cantidad de tests, errores/fallos, suites por módulo.
- Umbral recomendado: 0 errores/fallos. Si hay fallos, revisar el reporte XML/stacktrace en `site/unit-integration/<modulo>/`.

Plantilla de resumen (ejemplo):

| Módulo             | Tests | Fallos | Errores | Tiempo (s) |
|--------------------|-------|--------|---------|------------|
| user-service       | 7     | 0      | 0       | 5.2        |
| product-service    | 6     | 0      | 0       | 4.8        |
| ...                | ...   | ...    | ...     | ...        |

> Fuente: Surefire reports copiados a Pages.

### 4.2 Readiness E2E
- Objetivo: comprobar endpoints básicos de `product-service` y `user-service` con reintentos; otros servicios en best-effort.
- Métrica: OK/FAIL/WARN por endpoint. Un FAIL indica problemas de despliegue o dependencia.
- Acciones: ante FAIL/WARN, inspeccionar logs de pods y readiness/liveness en Kubernetes.

### 4.3 Pruebas de Carga con Locust
- Indicadores clave (del HTML/CSV de Locust):
  - Tiempo de respuesta (p50, p90, p95, p99)
  - Throughput (req/s)
  - Tasa de errores (%), #Fails
- Interpretación:
  - p95 < 300 ms (ejemplo de objetivo) para endpoints de lectura como `/products` y `/users`.
  - Throughput acorde a la carga generada (usuarios `-u` y rampa `-r`).
  - Error rate ~ 0% en endpoints principales bajo carga de 1 minuto.

Plantilla de resumen (extraer de `locust-report.html` o `locust-results_stats.csv`):

| Endpoint      | #Req | #Fails | Avg (ms) | p95 (ms) | RPS  | Error % |
|---------------|------|--------|----------|----------|------|---------|
| /products     | 3,000| 0      | 85       | 150      | 50   | 0.0     |
| /users        | 3,000| 3      | 92       | 170      | 50   | 0.1     |
| ...           | ...  | ...    | ...      | ...      | ...  | ...     |

> Consejo: si hay errores intermitentes, revisar si el port-forward o los pods reiniciaron durante la prueba.

---

## 5. Seguridad, Branch Protection y checks requeridos

Para que “solo funcione si las pipes se cumplen” (no permitir merge a `dev`/`main` con pipelines fallidas):

1) Settings > Branches > Add rule
2) Para `main` (y/o `master`):
   - Activar “Require status checks to pass before merging”.
   - Checks requeridos:
     - `CI + E2E + Locust + Pages / build-and-test`
     - `CI + E2E + Locust + Pages / e2e-and-locust`
     - `CI + E2E + Locust + Pages / deploy-pages`
3) Para `dev`:
   - Activar “Require status checks to pass before merging”.
   - Checks requeridos:
     - `Dev E2E - Locust / e2e-locust`
     - (Si tienes otra CI de `dev`, añádela aquí)
4) (Opcional) Activar “Require branches to be up to date before merging”.

Pantallazos sugeridos:
- Configuración de Branch protection para `dev` y `main` mostrando los checks marcados.

---

## 6. Ejecuciones locales (opcional)

Pruebas unitarias/integración:

```bash
# Linux/macOS
./mvnw -q test

# Windows (CMD)
mvnw -q test
```

Locust en local (si tienes los puertos publicados en localhost):

```bash
python -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r tests/locust/requirements.txt
locust -f tests/locust/locustfile.py --headless -u 20 -r 5 -t 1m --html locust-report.html
```

---

## 7. Apéndice: cambios realizados en el repo

- Tests unitarios adicionales (WebMvc) por servicio: User, Product, Order, Shipping, Payment, Favourite.
- Pruebas de carga Locust y workflow dedicado para `dev`.
- Workflow combinado CI + E2E + Locust + Pages que publica reportes en GitHub Pages y corre también en `dev`.
- Mejora de estabilidad E2E: port-forward a Services, retiros de `kubectl version --short`, readiness con retries.

Ubicación de archivos clave:
- `.github/workflows/ci-all-pages.yml`
- `.github/workflows/locust-e2e.yml`
- `tests/locust/locustfile.py`, `tests/locust/requirements.txt`
- Sitio: `site/` (generado por workflows) → publicado en Pages
- Tests añadidos: `*/src/test/java/com/selimhorri/app/resource/*AdditionalWebMvcTests.java`

---

> Para completar el reporte con evidencia visual, captura pantallazos de cada ejecución verde en Actions, de los artifacts y del sitio de Pages, y colócalos en `Docs/images/...`; luego enlázalos en las secciones correspondientes de este documento.

