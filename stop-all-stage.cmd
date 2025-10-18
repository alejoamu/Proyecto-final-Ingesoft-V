@echo off
setlocal

echo [stop-all-stage] Deteniendo servicios de aplicacion (stage)...
docker-compose -f compose.yml -f compose.stage.yml down --remove-orphans
if errorlevel 1 (
  echo [stop-all-stage] AVISO: Problema al detener compose.yml + compose.stage.yml (puede que no estuvieran levantados)
)

echo [stop-all-stage] Deteniendo servicios core (stage)...
docker-compose -f core.yml -f core.stage.yml down --remove-orphans
if errorlevel 1 (
  echo [stop-all-stage] AVISO: Problema al detener core.yml + core.stage.yml (puede que no estuvieran levantados)
)

echo [stop-all-stage] Listo.
exit /b 0

