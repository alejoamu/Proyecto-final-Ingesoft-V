@echo off
setlocal enabledelayedexpansion

REM Limpieza opcional de contenedores viejos con nombres fijos (si quedaron de intentos anteriores)
echo [run-all] Verificando contenedores previos (zipkin, service-discovery-container, cloud-config-container)...
for %%C in (zipkin service-discovery-container cloud-config-container) do (
  docker inspect %%C >nul 2>&1 && (
    echo [run-all] Eliminando contenedor previo: %%C
    docker rm -f %%C >nul 2>&1
  )
)

echo [run-all] Iniciando servicios core (Zipkin, Eureka, Config Server)...
docker-compose -f core.yml up -d
if errorlevel 1 (
  echo [run-all] ERROR: Fallo al levantar core.yml
  exit /b 1
)

REM Obtener IDs de contenedor reales creados por docker-compose
for /f %%i in ('docker-compose -f core.yml ps -q service-discovery-container') do set EUREKA_ID=%%i
for /f %%i in ('docker-compose -f core.yml ps -q cloud-config-container') do set CONFIG_ID=%%i

echo [run-all] Eureka ID: %EUREKA_ID%
echo [run-all] Config  ID: %CONFIG_ID%

REM Esperar a que Eureka este listo
call :wait_eureka 120

REM Esperar a que Config Server este listo
call :wait_config 120


echo [run-all] Iniciando servicios de aplicacion...
docker-compose -f compose.yml up -d
if errorlevel 1 (
  echo [run-all] ERROR: Fallo al levantar compose.yml
  exit /b 1
)

echo.
echo [run-all] Servicios levantados. Contenedores en ejecucion:
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
exit /b 0

:wait_eureka
REM Arguments: %1 = timeout (segundos)
set /a TIMEOUT=%~1
if "%TIMEOUT%"=="" set TIMEOUT=120
if not defined EUREKA_ID (
  echo [run-all] ADVERTENCIA: No se obtuvo el ID de Eureka; se usara el nombre del servicio
  set EUREKA_ID=service-discovery-container
)
echo [run-all] Esperando a Eureka (%EUREKA_ID%) hasta %TIMEOUT%s...
for /l %%i in (1,1,%TIMEOUT%) do (
  docker logs %EUREKA_ID% 2>&1 | findstr /C:"Finished initializing remote region registries" >nul && goto :eureka_ready
  docker logs %EUREKA_ID% 2>&1 | findstr /C:"Started" >nul && goto :eureka_ready
  if %%i lss %TIMEOUT% (
    >nul ping -n 2 127.0.0.1
  )
)
echo [run-all] AVISO: Timeout esperando Eureka; se continuara de todas formas.
goto :eureka_end
:eureka_ready
echo [run-all] Eureka listo.
:eureka_end
exit /b 0

:wait_config
REM Arguments: %1 = timeout (segundos)
set /a TIMEOUT=%~1
if "%TIMEOUT%"=="" set TIMEOUT=120
if not defined CONFIG_ID (
  echo [run-all] ADVERTENCIA: No se obtuvo el ID de Config Server; se usara el nombre del servicio
  set CONFIG_ID=cloud-config-container
)
echo [run-all] Esperando a Config Server (%CONFIG_ID%) hasta %TIMEOUT%s...
for /l %%i in (1,1,%TIMEOUT%) do (
  docker logs %CONFIG_ID% 2>&1 | findstr /C:"Tomcat started on port(s): 9296" >nul && goto :config_ready
  docker logs %CONFIG_ID% 2>&1 | findstr /C:"Started" >nul && goto :config_ready
  if %%i lss %TIMEOUT% (
    >nul ping -n 2 127.0.0.1
  )
)
echo [run-all] AVISO: Timeout esperando Config Server; se continuara de todas formas.
goto :config_end
:config_ready
echo [run-all] Config Server listo.
:config_end
exit /b 0
