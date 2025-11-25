a@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

REM Verifica si existe trivy en PATH
where trivy >nul 2>&1
if errorlevel 1 (
  echo Trivy CLI no encontrado, se usara contenedor Docker.
  set USE_DOCKER=1
) else (
  set USE_DOCKER=0
)

set REPORT_DIR=security-reports
if not exist %REPORT_DIR% mkdir %REPORT_DIR%

echo --- Actualizando base de datos de vulnerabilidades ---
if "%USE_DOCKER%"=="1" (
  docker run --rm -v %REPORT_DIR%:/root/.cache/ aquasec/trivy:latest --download-db-only
) else (
  trivy --download-db-only
)

echo --- Escaneo filesystem por modulo ---
for %%M in (service-discovery cloud-config api-gateway proxy-client user-service product-service favourite-service order-service shipping-service payment-service) do (
  echo Escaneando %%M ...
  if "%USE_DOCKER%"=="1" (
    docker run --rm -v "%cd%":/workspace -v %REPORT_DIR%:/root/.cache/ aquasec/trivy:latest fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 --format table /workspace/%%M > %REPORT_DIR%/%%M-fs.txt
    docker run --rm -v "%cd%":/workspace -v %REPORT_DIR%:/root/.cache/ aquasec/trivy:latest fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 /workspace/%%M 1>nul 2>nul
    if errorlevel 1 (
      echo Vulnerabilidades HIGH/CRITICAL encontradas en %%M
    )
  ) else (
    trivy fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 --format table %%M > %REPORT_DIR%/%%M-fs.txt
    trivy fs --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 %%M 1>nul 2>nul
    if errorlevel 1 (
      echo Vulnerabilidades HIGH/CRITICAL encontradas en %%M
    )
  )
)

echo --- Construyendo imagenes (si aplica) ---
REM Este bloque asume que ya existen Dockerfiles en cada microservicio y se construyen con tag local
for %%I in (api-gateway proxy-client user-service product-service favourite-service order-service shipping-service payment-service cloud-config service-discovery) do (
  if exist %%I\Dockerfile (
    echo Build de imagen %%I:local-scan
    docker build -q -t %%I:local-scan %%I
  )
)

echo --- Escaneo de imagenes ---
for %%I in (api-gateway proxy-client user-service product-service favourite-service order-service shipping-service payment-service cloud-config service-discovery) do (
  docker image inspect %%I:local-scan >nul 2>&1
  if not errorlevel 1 (
    echo Escaneando imagen %%I:local-scan ...
    if "%USE_DOCKER%"=="1" (
      docker run --rm -v %REPORT_DIR%:/root/.cache/ aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 --format table %%I:local-scan > %REPORT_DIR%/%%I-image.txt
      docker run --rm -v %REPORT_DIR%:/root/.cache/ aquasec/trivy:latest image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 %%I:local-scan 1>nul 2>nul
      if errorlevel 1 (
        echo Vulnerabilidades HIGH/CRITICAL en imagen %%I:local-scan
      )
    ) else (
      trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 0 --format table %%I:local-scan > %REPORT_DIR%/%%I-image.txt
      trivy image --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 %%I:local-scan 1>nul 2>nul
      if errorlevel 1 (
        echo Vulnerabilidades HIGH/CRITICAL en imagen %%I:local-scan
      )
    )
  )
)

echo --- Reportes generados en %REPORT_DIR% ---
ENDLOCAL

