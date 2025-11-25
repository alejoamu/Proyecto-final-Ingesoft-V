@echo off
setlocal enabledelayedexpansion

REM Script de ayuda para Windows: despliegue del entorno dev (backend local).
REM Debe ejecutarse desde la carpeta raiz del repo o directamente dentro de infra.

REM Cambiar al directorio del script (infra/)
cd /d "%~dp0"

set REGION=mexicocentral
set PREFIX_NAME=ecdev
set USER=adminuser
set PASSWORD=SuperSegura123

echo === Desplegar entorno dev (backend local) ===
cd environments\dev

terraform init
if %errorlevel% neq 0 goto :error

terraform plan ^
  -var="region=%REGION%" ^
  -var="prefix_name=%PREFIX_NAME%" ^
  -var="servers=[\"devops1\",\"devops2\"]" ^
  -var="user=%USER%" ^
  -var="password=%PASSWORD%" ^
  -out=plan.tfplan
if %errorlevel% neq 0 goto :error

terraform apply plan.tfplan
if %errorlevel% neq 0 goto :error

echo.
echo Despliegue de infra dev completado correctamente.
goto :eof

:error
echo.
echo [ERROR] Se produjo un error durante la ejecución de Terraform.
exit /b 1
