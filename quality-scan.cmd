@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

if "%SONAR_HOST_URL%"=="" (
  echo SONAR_HOST_URL no definido. Usando http://localhost:9000
  set SONAR_HOST_URL=http://localhost:9000
)
if "%SONAR_TOKEN%"=="" (
  echo ERROR: Debes definir SONAR_TOKEN (token generado en SonarQube UI).
  echo Usa: set SONAR_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  exit /b 1
)

echo --- Ejecutando build y tests con cobertura ---
call mvnw clean verify -DskipTests=false -DfailIfNoTests=false
if errorlevel 1 (
  echo FALLA: Build/Test fallaron.
  exit /b 1
)

echo --- Ejecutando analisis SonarQube (Maven) ---
call mvnw sonar:sonar -Dsonar.host.url=%SONAR_HOST_URL% -Dsonar.login=%SONAR_TOKEN%
if errorlevel 1 (
  echo FALLA: Analisis SonarQube fallo.
  exit /b 1
)

echo --- Analisis completado. Revisa Quality Gate en %SONAR_HOST_URL% ---
ENDLOCAL

