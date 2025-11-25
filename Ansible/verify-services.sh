#!/bin/bash

# Script de verificación de servicios en la VM CI
# Uso: ./verify-services.sh [VM_IP] [USER]

set -e

VM_IP="${1:-158.23.84.89}"
USER="${2:-adminuser}"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Verificación de Servicios en VM CI${NC}"
echo -e "${BLUE}========================================${NC}"
echo "VM IP: $VM_IP"
echo "Usuario: $USER"
echo ""

# Función para verificar servicio HTTP
check_http_service() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    echo -n "Verificando $name... "
    response=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$url" || echo "000")
    
    if [ "$response" = "$expected_status" ] || [ "$response" = "302" ] || [ "$response" = "301" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
        return 0
    else
        echo -e "${RED}✗ FALLO${NC} (HTTP $response)"
        return 1
    fi
}

# Función para verificar contenedor
check_container() {
    local name=$1
    echo -n "Verificando contenedor $name... "
    
    status=$(ssh "$USER@$VM_IP" "docker ps --filter name=$name --format '{{.Status}}' 2>/dev/null" || echo "")
    
    if [ -n "$status" ] && echo "$status" | grep -q "Up"; then
        echo -e "${GREEN}✓ OK${NC} ($status)"
        return 0
    else
        echo -e "${RED}✗ FALLO${NC} (no está corriendo)"
        return 1
    fi
}

# Contadores
TOTAL=0
PASSED=0
FAILED=0

echo -e "${YELLOW}=== 1. Verificando Contenedores Docker ===${NC}"
echo ""

# Verificar contenedores principales
containers=("postgres" "sonarqube" "nginx" "prometheus" "grafana" "alertmanager" "elasticsearch" "filebeat" "locust-master" "locust-worker")

for container in "${containers[@]}"; do
    TOTAL=$((TOTAL + 1))
    if check_container "$container"; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo -e "${YELLOW}=== 2. Verificando Servicios HTTP ===${NC}"
echo ""

# Verificar servicios HTTP
TOTAL=$((TOTAL + 1))
if check_http_service "SonarQube" "http://$VM_IP/sonar/" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Prometheus" "http://$VM_IP/prometheus/-/healthy" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Grafana" "http://$VM_IP/grafana/api/health" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Alertmanager" "http://$VM_IP/alertmanager/-/healthy" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Elasticsearch" "http://$VM_IP/elasticsearch/_cluster/health" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Locust" "http://$VM_IP:8089/" "200"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

TOTAL=$((TOTAL + 1))
if check_http_service "Nginx (raíz)" "http://$VM_IP/" "302"; then
    PASSED=$((PASSED + 1))
else
    FAILED=$((FAILED + 1))
fi

echo ""
echo -e "${YELLOW}=== 3. Verificando Estado de Docker Compose ===${NC}"
echo ""

TOTAL=$((TOTAL + 1))
echo -n "Verificando docker compose ps... "
compose_status=$(ssh "$USER@$VM_IP" "cd ~ && docker compose ps --format json 2>/dev/null | jq -r '.[] | select(.State != \"running\") | .Name' | wc -l" || echo "999")

if [ "$compose_status" = "0" ]; then
    echo -e "${GREEN}✓ OK${NC} (todos los servicios corriendo)"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FALLO${NC} ($compose_status servicios no corriendo)"
    FAILED=$((FAILED + 1))
    echo "Servicios no corriendo:"
    ssh "$USER@$VM_IP" "cd ~ && docker compose ps | grep -v 'Up' || true"
fi

echo ""
echo -e "${YELLOW}=== 4. Verificando Recursos del Sistema ===${NC}"
echo ""

TOTAL=$((TOTAL + 1))
echo -n "Verificando uso de memoria... "
memory_usage=$(ssh "$USER@$VM_IP" "free -m | awk 'NR==2{printf \"%.1f\", \$3*100/\$2}'" || echo "999")

if (( $(echo "$memory_usage < 90" | bc -l) )); then
    echo -e "${GREEN}✓ OK${NC} (${memory_usage}% usado)"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ ADVERTENCIA${NC} (${memory_usage}% usado - puede estar alto)"
    PASSED=$((PASSED + 1))
fi

TOTAL=$((TOTAL + 1))
echo -n "Verificando espacio en disco... "
disk_usage=$(ssh "$USER@$VM_IP" "df -h / | awk 'NR==2{print \$5}' | sed 's/%//'" || echo "999")

if [ "$disk_usage" -lt 90 ]; then
    echo -e "${GREEN}✓ OK${NC} (${disk_usage}% usado)"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ ADVERTENCIA${NC} (${disk_usage}% usado - puede estar alto)"
    PASSED=$((PASSED + 1))
fi

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Resumen de Verificación${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Total de verificaciones: $TOTAL"
echo -e "${GREEN}Exitosas: $PASSED${NC}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Fallidas: $FAILED${NC}"
else
    echo -e "${GREEN}Fallidas: $FAILED${NC}"
fi

if [ $FAILED -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Todos los servicios están funcionando correctamente!${NC}"
    echo ""
    echo -e "${BLUE}URLs disponibles:${NC}"
    echo "  - SonarQube:      http://$VM_IP/sonar/"
    echo "  - Prometheus:     http://$VM_IP/prometheus/"
    echo "  - Grafana:        http://$VM_IP/grafana/ (admin/admin)"
    echo "  - Alertmanager:   http://$VM_IP/alertmanager/"
    echo "  - Elasticsearch:  http://$VM_IP/elasticsearch/"
    echo "  - Locust:         http://$VM_IP:8089/"
    exit 0
else
    echo ""
    echo -e "${RED}✗ Algunos servicios no están funcionando correctamente${NC}"
    echo ""
    echo -e "${YELLOW}Para diagnosticar problemas:${NC}"
    echo "  1. Conectarse a la VM: ssh $USER@$VM_IP"
    echo "  2. Ver logs: cd ~ && docker compose logs [servicio]"
    echo "  3. Ver estado: cd ~ && docker compose ps"
    echo "  4. Reiniciar servicio: cd ~ && docker compose restart [servicio]"
    exit 1
fi

