#!/bin/bash

# Script de diagnóstico de problemas de conexión
# Uso: ./diagnose-connection.sh [VM_IP] [USER]

set -e

VM_IP="${1:-158.23.84.89}"
USER="${2:-adminuser}"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Diagnóstico de Problemas de Conexión${NC}"
echo -e "${BLUE}========================================${NC}"
echo "VM IP: $VM_IP"
echo ""

echo -e "${YELLOW}=== 1. Verificando Contenedores ===${NC}"
echo ""
ssh "$USER@$VM_IP" "cd ~ && docker compose ps" || echo "Error conectando a la VM"
echo ""

echo -e "${YELLOW}=== 2. Verificando Puertos Locales ===${NC}"
echo ""
ssh "$USER@$VM_IP" "netstat -tlnp 2>/dev/null | grep -E ':(80|3000|8089|9090|9093|9200)' || ss -tlnp | grep -E ':(80|3000|8089|9090|9093|9200)'" || echo "No se pueden verificar puertos"
echo ""

echo -e "${YELLOW}=== 3. Verificando Servicios desde dentro de la VM ===${NC}"
echo ""
echo "Probando SonarQube (puerto 9000):"
ssh "$USER@$VM_IP" "curl -s -o /dev/null -w '%{http_code}' http://localhost:9000/sonar/ || echo 'FALLO'"
echo ""

echo "Probando Prometheus (puerto 9090):"
ssh "$USER@$VM_IP" "curl -s -o /dev/null -w '%{http_code}' http://localhost:9090/-/healthy || echo 'FALLO'"
echo ""

echo "Probando Grafana (puerto 3000):"
ssh "$USER@$VM_IP" "curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/api/health || echo 'FALLO'"
echo ""

echo "Probando Nginx (puerto 80):"
ssh "$USER@$VM_IP" "curl -s -o /dev/null -w '%{http_code}' http://localhost/ || echo 'FALLO'"
echo ""

echo -e "${YELLOW}=== 4. Verificando Firewall (UFW) ===${NC}"
echo ""
ssh "$USER@$VM_IP" "sudo ufw status || echo 'UFW no está instalado o no está activo'"
echo ""

echo -e "${YELLOW}=== 5. Verificando Logs de Nginx ===${NC}"
echo ""
ssh "$USER@$VM_IP" "cd ~ && docker compose logs nginx --tail=20" || echo "Error obteniendo logs"
echo ""

echo -e "${YELLOW}=== 6. Verificando NSG de Azure (desde fuera) ===${NC}"
echo ""
echo "Probando conexión desde fuera:"
curl -s -o /dev/null -w "HTTP %{http_code} - Tiempo: %{time_total}s\n" --connect-timeout 5 "http://$VM_IP/" || echo "❌ No se puede conectar desde fuera"
echo ""

echo -e "${YELLOW}=== 7. Verificando Reglas de Firewall de Azure ===${NC}"
echo ""
echo "⚠️  IMPORTANTE: Verifica en Azure Portal que las siguientes reglas de NSG estén abiertas:"
echo "   - Puerto 80 (HTTP) - Entrada - Permitir"
echo "   - Puerto 8089 (Locust) - Entrada - Permitir"
echo "   - Puerto 22 (SSH) - Entrada - Permitir"
echo ""

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Resumen${NC}"
echo -e "${BLUE}========================================${NC}"

