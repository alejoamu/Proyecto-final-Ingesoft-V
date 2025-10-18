@echo off
setlocal

echo [stop-all] Deteniendo servicios de aplicacion...
docker-compose -f compose.yml down --remove-orphans
if errorlevel 1 (
  echo [stop-all] AVISO: Problema al detener compose.yml (puede que no estuviera levantado)
)

echo [stop-all] Deteniendo servicios core (Zipkin, Eureka, Config Server)...
docker-compose -f core.yml down --remove-orphans
if errorlevel 1 (
  echo [stop-all] AVISO: Problema al detener core.yml (puede que no estuviera levantado)
)

echo [stop-all] Listo.
exit /b 0

