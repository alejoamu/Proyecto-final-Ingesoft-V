#!/bin/bash

# Script para verificar y corregir configuración de kubectl para AKS

set -e

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Diagnóstico de Configuración de kubectl ===${NC}"
echo ""

# Verificar variables de entorno
echo -e "${YELLOW}1. Verificando variables de entorno...${NC}"
if [ -z "$AKS_RESOURCE_GROUP" ]; then
    echo -e "${RED}✗ AKS_RESOURCE_GROUP no está definida${NC}"
    echo "  Exporta la variable: export AKS_RESOURCE_GROUP='tu-resource-group'"
    exit 1
else
    echo -e "${GREEN}✓ AKS_RESOURCE_GROUP: $AKS_RESOURCE_GROUP${NC}"
fi

if [ -z "$AKS_CLUSTER_NAME" ]; then
    echo -e "${RED}✗ AKS_CLUSTER_NAME no está definida${NC}"
    echo "  Exporta la variable: export AKS_CLUSTER_NAME='tu-cluster-name'"
    exit 1
else
    echo -e "${GREEN}✓ AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME${NC}"
fi

# Verificar kubeconfig
echo ""
echo -e "${YELLOW}2. Verificando kubeconfig...${NC}"
AKS_KUBECONFIG="${AKS_KUBECONFIG:-~/.kube/aks-config}"
AKS_KUBECONFIG_EXPANDED=$(eval echo "$AKS_KUBECONFIG")

if [ ! -f "$AKS_KUBECONFIG_EXPANDED" ]; then
    echo -e "${YELLOW}⚠ Kubeconfig no existe: $AKS_KUBECONFIG_EXPANDED${NC}"
    echo "  Se obtendrán las credenciales ahora..."
    GET_CREDS=true
else
    echo -e "${GREEN}✓ Kubeconfig existe: $AKS_KUBECONFIG_EXPANDED${NC}"
    GET_CREDS=false
fi

# Verificar Azure CLI
echo ""
echo -e "${YELLOW}3. Verificando Azure CLI...${NC}"
if ! command -v az &> /dev/null; then
    echo -e "${RED}✗ Azure CLI no está instalado${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Azure CLI instalado${NC}"
fi

# Verificar login
echo ""
echo -e "${YELLOW}4. Verificando login en Azure...${NC}"
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}⚠ No estás logueado en Azure${NC}"
    echo "  Ejecutando: az login"
    az login
else
    echo -e "${GREEN}✓ Logueado en Azure${NC}"
    az account show --query "{Subscription:name, User:user.name}" -o table
fi

# Obtener credenciales
if [ "$GET_CREDS" = true ] || [ "${1}" = "--refresh" ]; then
    echo ""
    echo -e "${YELLOW}5. Obteniendo credenciales de AKS...${NC}"
    echo "  Cluster: $AKS_CLUSTER_NAME"
    echo "  Resource Group: $AKS_RESOURCE_GROUP"
    echo "  Kubeconfig: $AKS_KUBECONFIG_EXPANDED"
    
    az aks get-credentials \
        --resource-group "$AKS_RESOURCE_GROUP" \
        --name "$AKS_CLUSTER_NAME" \
        --file "$AKS_KUBECONFIG_EXPANDED" \
        --overwrite-existing
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Credenciales obtenidas exitosamente${NC}"
    else
        echo -e "${RED}✗ Error obteniendo credenciales${NC}"
        exit 1
    fi
else
    echo ""
    echo -e "${YELLOW}5. Omitiendo obtención de credenciales (ya existe kubeconfig)${NC}"
    echo "  Para forzar actualización, ejecuta: $0 --refresh"
fi

# Verificar conexión
echo ""
echo -e "${YELLOW}6. Verificando conexión al cluster...${NC}"
export KUBECONFIG="$AKS_KUBECONFIG_EXPANDED"

if kubectl cluster-info &> /dev/null; then
    echo -e "${GREEN}✓ Conexión exitosa al cluster${NC}"
    kubectl cluster-info | head -2
else
    echo -e "${RED}✗ No se puede conectar al cluster${NC}"
    echo ""
    echo "Posibles causas:"
    echo "  1. El cluster no existe o fue eliminado"
    echo "  2. No tienes permisos para acceder al cluster"
    echo "  3. Problemas de red/DNS"
    echo ""
    echo "Verifica el cluster:"
    echo "  az aks show -g $AKS_RESOURCE_GROUP -n $AKS_CLUSTER_NAME"
    exit 1
fi

# Mostrar información del cluster
echo ""
echo -e "${YELLOW}7. Información del cluster:${NC}"
kubectl get nodes -o wide

echo ""
echo -e "${BLUE}=== Configuración completada ===${NC}"
echo ""
echo -e "${GREEN}Para usar kubectl, exporta la variable:${NC}"
echo "  export KUBECONFIG=\"$AKS_KUBECONFIG_EXPANDED\""
echo ""
echo "O úsala directamente:"
echo "  KUBECONFIG=\"$AKS_KUBECONFIG_EXPANDED\" kubectl get pods -n ecommerce"
echo ""
echo "O agrega al ~/.bashrc:"
echo "  export KUBECONFIG=\"$AKS_KUBECONFIG_EXPANDED\""

