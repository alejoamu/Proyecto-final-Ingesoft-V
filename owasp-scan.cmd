@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

echo ================================================
echo OWASP Dependency-Check Security Scan
echo ================================================
echo.

set REPORT_DIR=security-reports\owasp
if not exist %REPORT_DIR% mkdir %REPORT_DIR%

echo Running OWASP Dependency-Check for all modules...
echo This may take several minutes on first run...
echo.

REM Ejecutar dependency-check para todos los módulos
REM Nota: El plugin está configurado en el pom.xml padre y se ejecutará para cada módulo
call mvnw.cmd org.owasp:dependency-check-maven:check -DfailBuildOnCVSS=0 -DautoUpdate=true

if errorlevel 1 (
    echo.
    echo WARNING: OWASP Dependency-Check found vulnerabilities!
    echo Check the reports in {module}/target/dependency-check-report.html for details.
) else (
    echo.
    echo OWASP Dependency-Check completed successfully.
)

echo.
echo Collecting reports...
for %%M in (service-discovery cloud-config api-gateway proxy-client user-service product-service favourite-service order-service shipping-service payment-service) do (
    if exist %%M\target\dependency-check-report.html (
        echo Copying report from %%M...
        copy /Y %%M\target\dependency-check-report.html %REPORT_DIR%\%%M-report.html >nul 2>&1
        copy /Y %%M\target\dependency-check-report.json %REPORT_DIR%\%%M-report.json >nul 2>&1
        copy /Y %%M\target\dependency-check-report.xml %REPORT_DIR%\%%M-report.xml >nul 2>&1
    )
)

echo.
echo Reports generated in: %REPORT_DIR%
echo.
ENDLOCAL

