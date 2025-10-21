@echo off
setlocal ENABLEDELAYEDEXPANSION
cd /d %~dp0

if not exist .env (
  echo [ERROR] No se encontro .env. Copia .env.example a .env y define GH_TOKEN (y opcionalmente SCM_CREDENTIALS_ID).
  exit /b 1
)

where wsl >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo [ERROR] WSL no encontrado. Abre Ubuntu (WSL) y ejecuta: bash ./setup-ci-token-wsl.sh
  exit /b 1
)

REM Ejecutar el script de WSL en esta misma carpeta
wsl bash -lc "cd \"$(wslpath -u '%CD%')\" && chmod +x setup-ci-token-wsl.sh && ./setup-ci-token-wsl.sh"

endlocal

