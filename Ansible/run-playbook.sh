#!/bin/bash

# Script para ejecutar el playbook de Ansible desde WSL
# Uso: ./run-playbook.sh [opciones]

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo "Uso: $0 [OPCIONES]"
    echo ""
    echo "Opciones:"
    echo "  --ci-only          Ejecutar solo el playbook de CI (sin AKS)"
    echo "  --aks-only         Ejecutar solo el playbook de AKS"
    echo "  --check            Ejecutar en modo check (dry-run)"
    echo "  --verbose          Ejecutar con output verbose (-v)"
    echo "  --very-verbose     Ejecutar con output muy verbose (-vvv)"
    echo "  --help             Mostrar esta ayuda"
    echo ""
    echo "Variables de entorno requeridas para AKS:"
    echo "  AKS_RESOURCE_GROUP  Grupo de recursos de Azure"
    echo "  AKS_CLUSTER_NAME    Nombre del cluster AKS"
    echo ""
    echo "Ejemplos:"
    echo "  # Solo CI"
    echo "  $0 --ci-only"
    echo ""
    echo "  # Completo con AKS"
    echo "  export AKS_RESOURCE_GROUP='dev-rg'"
    echo "  export AKS_CLUSTER_NAME='ecdev-aks'"
    echo "  $0"
    echo ""
    echo "  # Solo AKS"
    echo "  export AKS_RESOURCE_GROUP='dev-rg'"
    echo "  export AKS_CLUSTER_NAME='ecdev-aks'"
    echo "  $0 --aks-only"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "playbook.yml" ]; then
    echo -e "${RED}Error: playbook.yml no encontrado.${NC}"
    echo "Asegúrate de estar en el directorio Ansible"
    exit 1
fi

# Verificar que Ansible está instalado
if ! command -v ansible-playbook &> /dev/null; then
    echo -e "${RED}Error: ansible-playbook no está instalado.${NC}"
    echo "Instala Ansible primero:"
    echo "  pip3 install ansible"
    echo "  o"
    echo "  sudo apt install ansible"
    exit 1
fi

# Parsear argumentos
CI_ONLY=false
AKS_ONLY=false
CHECK_MODE=false
VERBOSE=""
LIMIT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --ci-only)
            CI_ONLY=true
            LIMIT="ci"
            shift
            ;;
        --aks-only)
            AKS_ONLY=true
            LIMIT="local"
            shift
            ;;
        --check)
            CHECK_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE="-v"
            shift
            ;;
        --very-verbose)
            VERBOSE="-vvv"
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Verificar variables de AKS si es necesario
if [ "$CI_ONLY" = false ] && [ "$AKS_ONLY" = true ]; then
    if [ -z "$AKS_RESOURCE_GROUP" ] || [ -z "$AKS_CLUSTER_NAME" ]; then
        echo -e "${RED}Error: Variables de AKS no configuradas${NC}"
        echo "Exporta AKS_RESOURCE_GROUP y AKS_CLUSTER_NAME antes de ejecutar"
        exit 1
    fi
elif [ "$CI_ONLY" = false ] && [ -z "$AKS_RESOURCE_GROUP" ] || [ -z "$AKS_CLUSTER_NAME" ]; then
    echo -e "${YELLOW}Advertencia: Variables de AKS no configuradas${NC}"
    echo "Ejecutando solo playbook de CI..."
    LIMIT="ci"
fi

# Mostrar información
echo -e "${BLUE}=== Ejecutando Playbook de Ansible ===${NC}"
echo ""

if [ "$CI_ONLY" = true ]; then
    echo -e "${GREEN}Modo: Solo CI${NC}"
elif [ "$AKS_ONLY" = true ]; then
    echo -e "${GREEN}Modo: Solo AKS${NC}"
    echo "  AKS_RESOURCE_GROUP: $AKS_RESOURCE_GROUP"
    echo "  AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"
else
    echo -e "${GREEN}Modo: Completo${NC}"
    if [ -n "$AKS_RESOURCE_GROUP" ] && [ -n "$AKS_CLUSTER_NAME" ]; then
        echo "  AKS_RESOURCE_GROUP: $AKS_RESOURCE_GROUP"
        echo "  AKS_CLUSTER_NAME: $AKS_CLUSTER_NAME"
    fi
fi

if [ "$CHECK_MODE" = true ]; then
    echo -e "${YELLOW}Modo: Check (dry-run)${NC}"
fi

echo ""

# Construir comando
CMD="ansible-playbook -i inventory.ini playbook.yml"

if [ -n "$LIMIT" ]; then
    CMD="$CMD --limit $LIMIT"
fi

if [ "$CHECK_MODE" = true ]; then
    CMD="$CMD --check"
fi

if [ -n "$VERBOSE" ]; then
    CMD="$CMD $VERBOSE"
fi

# Ejecutar comando
echo -e "${BLUE}Comando: $CMD${NC}"
echo ""

eval $CMD

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo -e "${GREEN}=== Playbook completado exitosamente ===${NC}"
else
    echo ""
    echo -e "${RED}=== Playbook falló con código de salida: $EXIT_CODE ===${NC}"
    exit $EXIT_CODE
fi

