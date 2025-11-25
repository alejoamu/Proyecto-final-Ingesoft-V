#!/bin/bash

# Script para encontrar información del cluster AKS

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Buscando información de AKS ===${NC}"
echo ""

# Verificar que Azure CLI está instalado
if ! command -v az &> /dev/null; then
    echo "Error: Azure CLI no está instalado"
    echo "Instálalo con: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
    exit 1
fi

# Verificar login
echo -e "${YELLOW}1. Verificando login en Azure...${NC}"
if ! az account show &> /dev/null; then
    echo "No estás logueado. Ejecutando az login..."
    az login
else
    echo -e "${GREEN}✓ Logueado en Azure${NC}"
    echo ""
    az account show --query "{Subscription:name, User:user.name}" -o table
    echo ""
fi

# Listar todos los clusters AKS
echo -e "${YELLOW}2. Buscando clusters AKS en todas las suscripciones...${NC}"
echo ""

# Obtener suscripción actual
SUBSCRIPTION=$(az account show --query id -o tsv)
echo "Suscripción actual: $SUBSCRIPTION"
echo ""

# Listar todos los clusters AKS
echo "Clusters AKS encontrados:"
echo ""

CLUSTERS=$(az aks list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, Status:provisioningState}" -o table)

if [ -z "$CLUSTERS" ] || [ "$CLUSTERS" = "" ]; then
    echo "No se encontraron clusters AKS en esta suscripción."
    echo ""
    echo "Para buscar en otras suscripciones:"
    echo "  1. Listar suscripciones: az account list -o table"
    echo "  2. Cambiar suscripción: az account set --subscription <subscription-id>"
    echo "  3. Volver a ejecutar este script"
    exit 1
else
    echo "$CLUSTERS"
fi

echo ""
echo -e "${YELLOW}3. Información detallada de cada cluster:${NC}"
echo ""

# Obtener lista de clusters con más detalles
az aks list --query "[].{Name:name, ResourceGroup:resourceGroup, Location:location, Status:provisioningState, PowerState:powerState.code}" -o table

echo ""
echo -e "${BLUE}=== Variables a exportar ===${NC}"
echo ""

# Intentar detectar el cluster más probable (el que tiene "dev" o "aks" en el nombre)
PRIMARY_CLUSTER=$(az aks list --query "[0].{Name:name, RG:resourceGroup}" -o tsv 2>/dev/null || echo "")

if [ -n "$PRIMARY_CLUSTER" ]; then
    CLUSTER_NAME=$(echo "$PRIMARY_CLUSTER" | cut -f1)
    RESOURCE_GROUP=$(echo "$PRIMARY_CLUSTER" | cut -f2)
    
    echo "Cluster detectado (primero en la lista):"
    echo ""
    echo -e "${GREEN}export AKS_RESOURCE_GROUP=\"$RESOURCE_GROUP\"${NC}"
    echo -e "${GREEN}export AKS_CLUSTER_NAME=\"$CLUSTER_NAME\"${NC}"
    echo -e "${GREEN}export AKS_KUBECONFIG=~/.kube/aks-config${NC}"
    echo -e "${GREEN}export KUBECONFIG=~/.kube/aks-config${NC}"
    echo ""
    echo "Para usar este cluster, copia y pega estos comandos:"
    echo ""
    echo "export AKS_RESOURCE_GROUP=\"$RESOURCE_GROUP\""
    echo "export AKS_CLUSTER_NAME=\"$CLUSTER_NAME\""
    echo "export AKS_KUBECONFIG=~/.kube/aks-config"
    echo "export KUBECONFIG=~/.kube/aks-config"
    echo ""
    echo "Luego obtén las credenciales:"
    echo "az aks get-credentials -g \"$RESOURCE_GROUP\" -n \"$CLUSTER_NAME\" --file ~/.kube/aks-config --overwrite-existing"
else
    echo "No se pudo detectar automáticamente. Elige un cluster de la lista arriba."
fi

echo ""
echo -e "${YELLOW}4. Para obtener información de un cluster específico:${NC}"
echo ""
echo "az aks show \\"
echo "  --resource-group <RESOURCE_GROUP> \\"
echo "  --name <CLUSTER_NAME> \\"
echo "  --query '{Name:name, ResourceGroup:resourceGroup, Status:provisioningState, PowerState:powerState.code}' \\"
echo "  -o table"

