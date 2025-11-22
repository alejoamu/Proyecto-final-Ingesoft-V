# Guía Completa: SonarQube y Trivy (Calidad de Código y Seguridad)

Esta guía detalla, paso a paso, cómo levantar SonarQube, generar el token de acceso, ejecutar análisis de calidad y cobertura con Maven/Jacoco, así como realizar escaneos de vulnerabilidades con Trivy sobre el filesystem y las imágenes Docker de los microservicios. Incluye además consejos de integración continua (CI), optimización y resolución de problemas.

---
## Índice
1. Prerrequisitos
2. Arquitectura y archivos relevantes
3. SonarQube: levantamiento local
4. Generación del token en SonarQube
5. Análisis de código y cobertura (Maven / quality-scan.cmd)
6. Alternativas de análisis (sonar-scanner contenedor)
7. Quality Gate: creación y criterios sugeridos
8. Integración SonarQube en GitHub Actions (CI)
9. Instalación y uso de Trivy (filesystem)
10. Escaneo de imágenes Docker con Trivy
11. Ignorar vulnerabilidades y configuración avanzada (.trivyignore)
12. Optimización de rendimiento (caché, DB, severidades)
13. Mejores prácticas de actualización de dependencias
14. Solución de problemas frecuentes
15. Comandos rápidos (cheat sheet)
16. Próximos pasos recomendados

---
## 1. Prerrequisitos
Asegúrate de contar con:
- Docker Desktop 4.x
- Java 11 (o superior si migras a Spring Boot 3.x)
- Maven (o el wrapper `mvnw` incluido)
- PowerShell (Windows) o Bash (Linux/macOS)
- Acceso local al puerto 9000 para SonarQube y puertos de servicios según `compose.yml`

Opcionales:
- Chocolatey / Scoop (para instalar Trivy CLI en Windows)
- GitHub repo con secretos configurados (SONAR_HOST_URL, SONAR_TOKEN)

---
## 2. Arquitectura y archivos relevantes
En la raíz del proyecto:
- `pom.xml`: contiene plugins de Jacoco y Sonar (`jacoco-maven-plugin`, `sonar-maven-plugin`).
- `sonar-project.properties`: módulos y exclusiones para Sonar.
- `quality-scan.cmd`: script Windows para build + tests + análisis Sonar.
- `trivy-scan.cmd`: script Windows para escaneo filesystem + imágenes con Trivy.
- `compose.yml`: incluye ahora el servicio `sonarqube`.
- `.github/workflows/code-quality.yml`: workflow de CI para calidad y seguridad.

---
## 3. SonarQube: levantamiento local
Primero levanta servicios core si aún no existe la red `microservices_network`:
```powershell
docker compose -f core.yml up -d
```
Luego levanta SonarQube (solo SonarQube) o todo el landscape:
```powershell
# Solo SonarQube
docker compose -f compose.yml up -d sonarqube
# Todo el landscape (incluye sonarqube si lo agregas)
docker compose -f compose.yml up -d
```
Verifica estado (tarda ~40–60 s):
```powershell
curl http://localhost:9000/api/system/status
# Esperado: {"status":"UP"}
```
Logs (opcional):
```powershell
docker logs -f sonarqube
```

---
## 4. Generación del token en SonarQube
1. Abre http://localhost:9000
2. Login inicial: `admin` / `admin` (forzará cambio de contraseña).
3. Haz clic en tu avatar → "My Account" → pestaña "Security".
4. Campo "Generate Tokens": asigna un nombre (ej.: `ecommerce-local`) y pulsa "Generate".
5. Copia el token y guárdalo (no se vuelve a mostrar).

---
## 5. Análisis de código y cobertura (Maven / quality-scan.cmd)
Exporta variables de entorno en PowerShell:
```powershell
$Env:SONAR_HOST_URL="http://localhost:9000"
$Env:SONAR_TOKEN="<TU_TOKEN>"
```
Ejecuta script automatizado:
```powershell
quality-scan.cmd
```
Internamente realiza:
1. `mvnw clean verify` (tests + Jacoco XML).
2. `mvnw sonar:sonar` (sube resultados a SonarQube).

Alternativa manual:
```powershell
./mvnw clean verify -DskipTests=false -DfailIfNoTests=false
./mvnw sonar:sonar -Dsonar.host.url=$Env:SONAR_HOST_URL -Dsonar.login=$Env:SONAR_TOKEN
```

---
## 6. Alternativas de análisis (sonar-scanner contenedor)
Si prefieres no usar el plugin Maven:
```powershell
docker run --rm -v "$PWD":/usr/src -w /usr/src \  
  -e SONAR_HOST_URL=$Env:SONAR_HOST_URL -e SONAR_LOGIN=$Env:SONAR_TOKEN \  
  sonarsource/sonar-scanner-cli:latest
```
Asegúrate de que `sonar-project.properties` esté en la raíz.

---
## 7. Quality Gate: creación y criterios sugeridos
En SonarQube:
1. Administration → Quality Gates → Create.
2. Añade condiciones sugeridas:
   - Coverage ≥ 60%
   - Security Rating = A
   - Reliability Rating = A
   - 0 Vulnerabilities
3. Marca como Default o asigna al proyecto.

Recomendación: empieza con cobertura mínima más baja (ej. 40–50%) si el proyecto recién agrega tests y súbela gradualmente.

---
## 8. Integración SonarQube en GitHub Actions (CI)
Configura secretos en GitHub: Settings → Secrets and variables → Actions → New repository secret:
- `SONAR_HOST_URL`: URL del servidor (ej. https://sonar.miempresa.com)
- `SONAR_TOKEN`: token de usuario con permisos de análisis.

Workflow `code-quality.yml` ya:
- Compila y ejecuta tests.
- Lanza `sonar:sonar`.
- Escanea con Trivy filesystem e imágenes.

---
## 9. Instalación y uso de Trivy (filesystem)
Opciones Windows:
- Chocolatey:
  ```powershell
  choco install trivy -y
  ```
- Scoop:
  ```powershell
  scoop install trivy
  ```
- Contenedor (sin instalación):
  ```powershell
  docker run --rm -v "$PWD":/workspace aquasec/trivy:latest fs /workspace
  ```

Actualizar base de datos (primera ejecución):
```powershell
trivy --download-db-only
```
Escaneo con severidades altas y salida de error si se encuentran:
```powershell
trivy fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 .
```
Formato JSON (para procesar resultados):
```powershell
trivy fs --severity HIGH,CRITICAL --ignore-unfixed --format json -o trivy-fs.json .
```

---
## 10. Escaneo de imágenes Docker con Trivy
Construir imagen de un microservicio (ej. `product-service`):
```powershell
docker build -t product-service:scan product-service
```
Escanear imagen:
```powershell
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 product-service:scan
```
Loop rápido (PowerShell):
```powershell
foreach ($svc in "api-gateway","proxy-client","user-service","product-service","favourite-service","order-service","shipping-service","payment-service","cloud-config","service-discovery") {
  if (Test-Path "$svc/Dockerfile") {
    docker build -t "$svc:scan" $svc
    trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 "$svc:scan"
  }
}
```

---
## 11. Ignorar vulnerabilidades (.trivyignore)
Crea `.trivyignore` en la raíz para suprimir CVEs temporalmente:
```
CVE-2024-12345
CVE-2023-98765
```
Úsalo solo como medida transitoria mientras actualizas dependencias.

---
## 12. Optimización de rendimiento
- Cache local de Trivy: `~/.cache/trivy` (usa `actions/cache` en CI).
- Evita actualización de DB en cada ejecución: `--skip-db-update` si escaneas varias veces en poco tiempo.
- Limita severidades: durante desarrollo puedes usar `--severity HIGH,CRITICAL` y ampliar después.
- SonarQube: ejecutar análisis sólo en PR y en push a ramas principales; evitar ramas experimentales.

---
## 13. Mejores prácticas de actualización de dependencias
Muchas vulnerabilidades provienen de versiones antiguas:
- Spring Boot 2.5.7 → migrar a 2.7.18 (lts 2.x) o 3.2.x (Java 17).
- Jackson 2.12.x → 2.17.x.
- Logback 1.2.x → 1.5.x.
- BouncyCastle, SnakeYAML, commons-compress: actualizar BOM o versiones explícitas.

Usa el BOM de Spring para centralizar versiones y reduce CVEs transitorios.

---
## 14. Solución de problemas frecuentes
| Problema | Causa común | Solución |
|----------|-------------|----------|
| `sonar:sonar` falla autenticación | Token no exportado o expirado | Reexportar `$Env:SONAR_TOKEN` o crear nuevo token |
| Cobertura 0% | Tests no ejecutados o falta XML Jacoco | Verificar fase `verify` y existencia de `target/site/jacoco/jacoco.xml` |
| Trivy muy lento inicial | Descarga de base de datos | Reusar cache y evitar borrado |
| Muchos falsos positivos | Versiones antiguas en dependencias | Actualizar librerías / framework |
| Docker image scan falla por tamaño | Imagen muy grande | Multi-stage build, reducir capa base |
| Quality Gate rojo por duplicaciones | Código duplicado en módulos | Refactor común, extraer librerías compartidas |

---
## 15. Comandos rápidos (Cheat Sheet)
```powershell
# SonarQube local
docker compose -f core.yml up -d
docker compose -f compose.yml up -d sonarqube
$Env:SONAR_HOST_URL="http://localhost:9000"
$Env:SONAR_TOKEN="<token>"
quality-scan.cmd

# Análisis manual
./mvnw clean verify
./mvnw sonar:sonar -Dsonar.host.url=$Env:SONAR_HOST_URL -Dsonar.login=$Env:SONAR_TOKEN

# Trivy filesystem
trivy fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 .
trivy fs --format json -o trivy-fs.json .

# Construir y escanear imagen
docker build -t product-service:scan product-service
trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 product-service:scan

# Descargar base de datos Trivy
trivy --download-db-only
```

---
## 16. Próximos pasos recomendados
1. Crear perfil Maven `quality` que encapsule `verify` + `sonar:sonar`.
2. Agregar SpotBugs y OWASP Dependency-Check al workflow de calidad.
3. Publicar reportes de Trivy (JSON/SARIF) como artefactos y subir SARIF a GitHub Security.
4. Implementar script para crear Quality Gate custom vía API Sonar (automatización onboarding).
5. Migrar a Spring Boot 3.x + Java 17 para reducir CVEs y mejorar soporte.
6. Integrar análisis periódico (cron) de seguridad para monitoreo continuo.

---
## Anexos
### A. Archivo `sonar-project.properties` (resumen)
Declara módulos y exclusiones:
```
sonar.modules=service-discovery,cloud-config,api-gateway,proxy-client,user-service,product-service,favourite-service,order-service,shipping-service,payment-service
sonar.exclusions=**/target/**,**/k8s/**,**/infra/**,**/Ansible/**,**/performance-tests/**,**/e2e-tests/**,**/*.cmd,**/*.sh,**/*.drawio,**/*.png
```

### B. Política inicial sugerida
- Cobertura ≥ 60% (incremental)
- 0 vulnerabilidades HIGH/CRITICAL
- Security Rating y Reliability Rating = A
- Revisar duplicaciones y mantener deuda técnica controlada

---
¿Dudas o ampliaciones? Puedes extender esta guía agregando una sección de Integración con otros escáneres (Dependency-Check, Snyk) o métricas agregadas de cobertura (report-aggregate Jacoco).

---
**Fin de la guía.**

