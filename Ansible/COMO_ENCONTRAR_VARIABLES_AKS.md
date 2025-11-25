# Cómo Encontrar las Variables de AKS

## Método 1: Listar todos los clusters AKS (Recomendado)

```bash
# Listar todos los clusters AKS en tu suscripción
az aks list -o table
```

Esto mostrará algo como:
```
Name              ResourceGroup    Location          KubernetesVersion    ProvisioningState    Fqdn
----------------  ---------------  ----------------  -------------------  -------------------  ----------------------------------------
ecdev-aks         dev-rg           mexicocentral     1.28.0               Succeeded            ecdev-aks-ny276rt1.hcp.mexicocentral...
```

De ahí puedes ver:
- **AKS_CLUSTER_NAME**: `ecdev-aks` (columna Name)
- **AKS_RESOURCE_GROUP**: `dev-rg` (columna ResourceGroup)

## Método 2: Usar el script automatizado

```bash
cd Ansible
chmod +x find-aks-info.sh
./find-aks-info.sh
```

Este script:
1. Verifica que estés logueado en Azure
2. Lista todos tus clusters AKS
3. Te muestra los comandos exactos para exportar las variables

## Método 3: Buscar por nombre (si conoces parte del nombre)

```bash
# Buscar clusters que contengan "dev" o "aks" en el nombre
az aks list --query "[?contains(name, 'dev') || contains(name, 'aks')].{Name:name, ResourceGroup:resourceGroup}" -o table
```

## Método 4: Buscar en un Resource Group específico

Si sabes el Resource Group:

```bash
# Reemplaza "dev-rg" con tu resource group
az aks list --resource-group dev-rg -o table
```

## Método 5: Ver información detallada de un cluster

Si ya tienes una idea del nombre:

```bash
# Listar todos los resource groups primero
az group list --query "[].name" -o table

# Luego buscar clusters en un resource group específico
az aks list --resource-group <nombre-del-rg> -o table
```

## Método 6: Buscar en Azure Portal

1. Ve a [Azure Portal](https://portal.azure.com)
2. Busca "Kubernetes services" o "AKS"
3. Verás la lista de tus clusters
4. Click en un cluster para ver:
   - **Nombre del cluster** (en la parte superior)
   - **Resource group** (en "Essentials")

## Una vez que tengas los valores

Exporta las variables:

```bash
# Reemplaza con tus valores reales
export AKS_RESOURCE_GROUP="dev-rg"
export AKS_CLUSTER_NAME="ecdev-aks"
export AKS_KUBECONFIG=~/.kube/aks-config
export KUBECONFIG=~/.kube/aks-config
```

Luego obtén las credenciales:

```bash
az aks get-credentials \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --file ~/.kube/aks-config \
  --overwrite-existing
```

## Verificar que funcionó

```bash
# Ver información del cluster
kubectl cluster-info

# Ver nodos
kubectl get nodes

# Ver pods
kubectl get pods -n ecommerce
```

## Si tienes múltiples suscripciones

```bash
# Listar todas las suscripciones
az account list -o table

# Cambiar a otra suscripción
az account set --subscription <subscription-id>

# Luego buscar clusters
az aks list -o table
```

## Comandos Útiles Adicionales

```bash
# Ver información detallada de un cluster específico
az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query "{Name:name, ResourceGroup:resourceGroup, Status:provisioningState, PowerState:powerState.code, Location:location}" \
  -o table

# Ver el FQDN del cluster (útil para verificar DNS)
az aks show \
  --resource-group <resource-group> \
  --name <cluster-name> \
  --query "fqdn" \
  -o tsv
```

## Ejemplo Completo

```bash
# 1. Listar clusters
az aks list -o table

# Salida:
# Name        ResourceGroup    Location
# ----------  --------------  ------------
# ecdev-aks   dev-rg          mexicocentral

# 2. Exportar variables
export AKS_RESOURCE_GROUP="dev-rg"
export AKS_CLUSTER_NAME="ecdev-aks"
export AKS_KUBECONFIG=~/.kube/aks-config
export KUBECONFIG=~/.kube/aks-config

# 3. Obtener credenciales
az aks get-credentials \
  --resource-group "dev-rg" \
  --name "ecdev-aks" \
  --file ~/.kube/aks-config \
  --overwrite-existing

# 4. Verificar
kubectl get nodes
```

