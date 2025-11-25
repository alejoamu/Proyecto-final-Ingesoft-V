#!/bin/bash
set -e

echo "================================================"
echo "OWASP Dependency-Check Security Scan"
echo "================================================"
echo

REPORT_DIR="security-reports/owasp"
mkdir -p "$REPORT_DIR"

echo "Running OWASP Dependency-Check for all modules..."
echo "This may take several minutes on first run..."
echo

# El plugin está configurado en el pom.xml padre y se ejecutará para cada módulo
export JAVA_OPTS="-Xmx2048m"
./mvnw org.owasp:dependency-check-maven:check \
  -DfailBuildOnCVSS=0 \
  -DautoUpdate=true \
  -Dformat=HTML \
  -Dformat=JSON \
  -Dformat=XML || {
    echo
    echo "WARNING: OWASP Dependency-Check found vulnerabilities!"
    echo "Check the reports in {module}/target/dependency-check-report.html for details."
}

echo
echo "Collecting reports..."
for module in service-discovery cloud-config api-gateway proxy-client user-service product-service favourite-service order-service shipping-service payment-service; do
  if [ -f "$module/target/dependency-check-report.html" ]; then
    echo "Copying report from $module..."
    cp "$module/target/dependency-check-report.html" "$REPORT_DIR/${module}-report.html" 2>/dev/null || true
    cp "$module/target/dependency-check-report.json" "$REPORT_DIR/${module}-report.json" 2>/dev/null || true
    cp "$module/target/dependency-check-report.xml" "$REPORT_DIR/${module}-report.xml" 2>/dev/null || true
  fi
done

echo
echo "Reports generated in: $REPORT_DIR"
echo

