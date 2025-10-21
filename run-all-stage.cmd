@echo off
setlocal enabledelayedexpansion

echo [run-all-stage] Iniciando servicios core (Zipkin, Eureka, Config Server) con perfil stage...
docker-compose -f core.yml -f core.stage.yml up -d
if errorlevel 1 (
  echo [run-all-stage] ERROR: Fallo al levantar core.yml + core.stage.yml
  exit /b 1
)

REM Obtener IDs de contenedor reales creados por docker-compose (overlay stage)
for /f %%i in ('docker-compose -f core.yml -f core.stage.yml ps -q service-discovery-container') do set EUREKA_ID=%%i
for /f %%i in ('docker-compose -f core.yml -f core.stage.yml ps -q cloud-config-container') do set CONFIG_ID=%%i

echo [run-all-stage] Eureka ID: %EUREKA_ID%
echo [run-all-stage] Config  ID: %CONFIG_ID%

REM Esperar a que Eureka este listo
call :wait_logs "%EUREKA_ID%" "Finished initializing remote region registries" "Tomcat started on port(s): 8761" 120 "Eureka"

REM Esperar a que Config Server este listo
call :wait_logs "%CONFIG_ID%" "Tomcat started on port(s): 9296" "Started" 120 "Config Server"

echo [run-all-stage] Iniciando servicios de aplicacion (perfil stage)...
docker-compose -f compose.yml -f compose.stage.yml up -d
if errorlevel 1 (
  echo [run-all-stage] ERROR: Fallo al levantar compose.yml + compose.stage.yml
  exit /b 1
)

echo.
echo [run-all-stage] Servicios (stage) levantados. Contenedores en ejecucion:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
exit /b 0

:wait_logs
REM Args: %1=CONTAINER_ID, %2=PATTERN1, %3=PATTERN2, %4=TIMEOUT, %5=NAME
set CID=%~1
set PAT1=%~2
set PAT2=%~3
set /a TIMEOUT=%~4
set NAME=%~5
if "%TIMEOUT%"=="" set TIMEOUT=120
if "%CID%"=="" (
  echo [run-all-stage] ADVERTENCIA: no se obtuvo ID de %NAME%; se omitira espera.
  exit /b 0
)
echo [run-all-stage] Esperando a %NAME% (%CID%) hasta %TIMEOUT%s...
for /l %%i in (1,1,%TIMEOUT%) do (
  docker logs %CID% 2>&1 | findstr /C:"%PAT1%" >nul && goto :ready
  docker logs %CID% 2>&1 | findstr /C:"%PAT2%" >nul && goto :ready
  if %%i lss %TIMEOUT% (
    >nul ping -n 2 127.0.0.1
  )
)
echo [run-all-stage] AVISO: Timeout esperando %NAME%.
goto :end
:ready
echo [run-all-stage] %NAME% listo.
:end
exit /b 0

