# Solución: kubectl no se conecta al cluster AKS

## Problema

```
The connection to the server localhost:8080 was refused
```

Este error significa que `kubectl` está intentando conectarse a `localhost:8080` en lugar de tu cluster AKS. Esto ocurre cuando:

1. La variable `KUBECONFIG` no está definida o apunta a un archivo incorrecto
2. El archivo kubeconfig no existe o está corrupto
3. Las credenciales del cluster expiraron o el cluster fue recreado

## Solución Rápida

### Paso 1: Verificar y exportar variables

```bash
# Verificar que las variables estén definidas
echo $AKS_RESOURCE_GROUP
echo $AKS_CLUSTER_NAME
echo $AKS_KUBECONFIG

# Si no están definidas, exportarlas
export AKS_RESOURCE_GROUP="tu-resource-group"
export AKS_CLUSTER_NAME="tu-cluster-name"
export AKS_KUBECONFIG="${AKS_KUBECONFIG:-~/.kube/aks-config}"
```

### Paso 2: Obtener credenciales frescas

```bash
# Obtener credenciales del cluster
az aks get-credentials \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --file "$(eval echo $AKS_KUBECONFIG)" \
  --overwrite-existing
```

### Paso 3: Verificar conexión

```bash
# Exportar KUBECONFIG
export KUBECONFIG="$(eval echo $AKS_KUBECONFIG)"

# Verificar conexión
kubectl cluster-info
kubectl get nodes
```

## Solución Automatizada

Usa el script de diagnóstico:

```bash
cd Ansible
chmod +x fix-kubectl-config.sh

# Asegúrate de tener las variables exportadas
export AKS_RESOURCE_GROUP="tu-resource-group"
export AKS_CLUSTER_NAME="tu-cluster-name"

# Ejecutar script
./fix-kubectl-config.sh

# O forzar actualización de credenciales
./fix-kubectl-config.sh --refresh
```

## Solución Manual Paso a Paso

### 1. Verificar que estás logueado en Azure

```bash
az account show
```

Si no estás logueado:
```bash
az login
```

### 2. Verificar que el cluster existe

```bash
az aks show \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --query "{name:name,provisioningState:provisioningState,powerState:powerState.code}" \
  -o json
```

### 3. Obtener credenciales

```bash
# Definir ruta del kubeconfig
KUBECONFIG_PATH=~/.kube/aks-config

# Obtener credenciales
az aks get-credentials \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --file "$KUBECONFIG_PATH" \
  --overwrite-existing
```

### 4. Usar el kubeconfig

```bash
# Opción 1: Exportar variable
export KUBECONFIG=~/.kube/aks-config

# Opción 2: Usar en cada comando
KUBECONFIG=~/.kube/aks-config kubectl get pods -n ecommerce

# Opción 3: Copiar al kubeconfig por defecto (no recomendado si tienes múltiples clusters)
cp ~/.kube/aks-config ~/.kube/config
```

## Verificar que funciona

```bash
# Ver información del cluster
kubectl cluster-info

# Ver nodos
kubectl get nodes

# Ver pods en el namespace ecommerce
kubectl get pods -n ecommerce

# Ver todos los recursos
kubectl get all -n ecommerce
```

## Hacer la configuración permanente

Agrega al final de `~/.bashrc` o `~/.zshrc`:

```bash
# Configuración de AKS
export AKS_RESOURCE_GROUP="tu-resource-group"
export AKS_CLUSTER_NAME="tu-cluster-name"
export AKS_KUBECONFIG=~/.kube/aks-config
export KUBECONFIG="$AKS_KUBECONFIG"

# Recargar configuración
source ~/.bashrc  # o source ~/.zshrc
```

## Problemas Comunes

### Error: "cluster not found"

```bash
# Verificar que el cluster existe
az aks list --resource-group "$AKS_RESOURCE_GROUP" -o table

# Si no existe, verifica el nombre y resource group
az aks list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o table
```

### Error: "unauthorized" o "forbidden"

```bash
# Verificar permisos
az aks check-acr \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME"

# Verificar que tienes el rol necesario
az role assignment list \
  --assignee $(az account show --query user.name -o tsv) \
  --scope $(az aks show -g "$AKS_RESOURCE_GROUP" -n "$AKS_CLUSTER_NAME" --query id -o tsv)
```

### Error: "dial tcp: lookup ... no such host"

El DNS del cluster cambió (cluster recreado). El playbook debería detectarlo automáticamente, pero puedes forzarlo:

```bash
# Eliminar kubeconfig antiguo
rm ~/.kube/aks-config

# Obtener credenciales frescas
az aks get-credentials \
  --resource-group "$AKS_RESOURCE_GROUP" \
  --name "$AKS_CLUSTER_NAME" \
  --file ~/.kube/aks-config \
  --overwrite-existing
```

### kubectl sigue usando localhost:8080

```bash
# Verificar qué kubeconfig está usando
kubectl config view

# Verificar variable KUBECONFIG
echo $KUBECONFIG

# Si está vacía, exportarla
export KUBECONFIG=~/.kube/aks-config

# Verificar que apunta al cluster correcto
kubectl config get-contexts
```

## Comandos Útiles

```bash
# Ver contexto actual
kubectl config current-context

# Ver todos los contextos
kubectl config get-contexts

# Cambiar contexto
kubectl config use-context <nombre-contexto>

# Ver configuración completa
kubectl config view

# Ver información del servidor
kubectl cluster-info

# Ver versión del servidor
kubectl version --short
```

## Verificación Rápida

Ejecuta este comando para verificar todo:

```bash
#!/bin/bash
echo "=== Verificación de kubectl ==="
echo ""
echo "1. Variables de entorno:"
echo "   AKS_RESOURCE_GROUP: ${AKS_RESOURCE_GROUP:-NO DEFINIDA}"
echo "   AKS_CLUSTER_NAME: ${AKS_CLUSTER_NAME:-NO DEFINIDA}"
echo "   KUBECONFIG: ${KUBECONFIG:-NO DEFINIDA}"
echo ""
echo "2. Azure CLI:"
az account show --query "{User:user.name, Subscription:name}" -o table 2>/dev/null || echo "   No logueado"
echo ""
echo "3. Cluster AKS:"
if [ -n "$AKS_RESOURCE_GROUP" ] && [ -n "$AKS_CLUSTER_NAME" ]; then
    az aks show -g "$AKS_RESOURCE_GROUP" -n "$AKS_CLUSTER_NAME" --query "{Name:name, State:powerState.code, Provisioning:provisioningState}" -o table 2>/dev/null || echo "   Cluster no encontrado"
else
    echo "   Variables no definidas"
fi
echo ""
echo "4. kubectl:"
if [ -n "$KUBECONFIG" ] && [ -f "$KUBECONFIG" ]; then
    kubectl cluster-info 2>/dev/null | head -1 || echo "   No se puede conectar"
    kubectl get nodes 2>/dev/null | head -2 || echo "   Error obteniendo nodos"
else
    echo "   KUBECONFIG no configurado o archivo no existe"
fi
```

