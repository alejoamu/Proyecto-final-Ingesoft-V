# Puertos para NSG de Azure - Servicios de Monitoreo

## Puertos que Necesitas Agregar al NSG

Los nuevos servicios de monitoreo usan los siguientes puertos:

| Servicio | Puerto | Protocolo | Descripción | Acceso |
|----------|--------|-----------|-------------|--------|
| **Prometheus** | 9090 | TCP | Métricas y consultas PromQL | Directo o vía Nginx |
| **Grafana** | 3000 | TCP | Dashboards de monitoreo | Directo o vía Nginx |
| **Alertmanager** | 9093 | TCP | Gestión de alertas | Directo o vía Nginx |
| **Elasticsearch** | 9200 | TCP | API REST de búsqueda | Directo o vía Nginx |
| **Elasticsearch** | 9300 | TCP | Comunicación entre nodos | Solo interno (opcional) |

## Nota Importante

**Estos servicios también están disponibles vía Nginx (puerto 80) que ya está abierto:**
- Prometheus: `http://VM_IP/prometheus/`
- Grafana: `http://VM_IP/grafana/`
- Alertmanager: `http://VM_IP/alertmanager/`
- Elasticsearch: `http://VM_IP/elasticsearch/`

**Si solo usas Nginx, NO necesitas abrir estos puertos adicionales.**

## Configuración en Azure Portal

### Opción 1: Agregar Reglas Individuales (Recomendado)

1. Ve a Azure Portal → Tu Resource Group → Network Security Group
2. Click en "Inbound security rules" o "Reglas de seguridad de entrada"
3. Click en "Add" o "Agregar"

**Regla para Prometheus (9090):**
- Name: `Allow-Prometheus`
- Priority: `1010`
- Source: `Any` o `Internet`
- Destination: `Any`
- Service: `Custom`
- Protocol: `TCP`
- Port range: `9090`
- Action: `Allow`

**Regla para Grafana (3000):**
- Name: `Allow-Grafana`
- Priority: `1011`
- Source: `Any` o `Internet`
- Destination: `Any`
- Service: `Custom`
- Protocol: `TCP`
- Port range: `3000`
- Action: `Allow`

**Regla para Alertmanager (9093):**
- Name: `Allow-Alertmanager`
- Priority: `1012`
- Source: `Any` o `Internet`
- Destination: `Any`
- Service: `Custom`
- Protocol: `TCP`
- Port range: `9093`
- Action: `Allow`

**Regla para Elasticsearch (9200):**
- Name: `Allow-Elasticsearch`
- Priority: `1013`
- Source: `Any` o `Internet`
- Destination: `Any`
- Service: `Custom`
- Protocol: `TCP`
- Port range: `9200`
- Action: `Allow`

### Opción 2: Agregar Todas las Reglas con Azure CLI

```bash
# Reemplaza <resource-group> y <nsg-name> con tus valores
RESOURCE_GROUP="tu-resource-group"
NSG_NAME="tu-nsg-name"

# Prometheus
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Prometheus \
  --priority 1010 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 9090

# Grafana
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Grafana \
  --priority 1011 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 3000

# Alertmanager
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Alertmanager \
  --priority 1012 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 9093

# Elasticsearch
az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Elasticsearch \
  --priority 1013 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 9200
```

### Opción 3: Script Completo para Agregar Todos los Puertos

```bash
#!/bin/bash
# Script para agregar todos los puertos de monitoreo al NSG

RESOURCE_GROUP="${1:-tu-resource-group}"
NSG_NAME="${2:-tu-nsg-name}"

if [ "$RESOURCE_GROUP" = "tu-resource-group" ] || [ "$NSG_NAME" = "tu-nsg-name" ]; then
    echo "Uso: $0 <resource-group> <nsg-name>"
    echo ""
    echo "Para encontrar el NSG:"
    echo "  az network nsg list --resource-group <resource-group> --query '[].name' -o tsv"
    exit 1
fi

echo "Agregando reglas al NSG: $NSG_NAME en RG: $RESOURCE_GROUP"
echo ""

PORTS=(
    "1010:9090:Prometheus"
    "1011:3000:Grafana"
    "1012:9093:Alertmanager"
    "1013:9200:Elasticsearch"
)

for port_config in "${PORTS[@]}"; do
    IFS=':' read -r priority port name <<< "$port_config"
    
    echo "Agregando regla para $name (puerto $port)..."
    
    az network nsg rule create \
      --resource-group "$RESOURCE_GROUP" \
      --nsg-name "$NSG_NAME" \
      --name "Allow-$name" \
      --priority "$priority" \
      --access Allow \
      --protocol Tcp \
      --direction Inbound \
      --source-address-prefixes '*' \
      --source-port-ranges '*' \
      --destination-address-prefixes '*' \
      --destination-port-ranges "$port" \
      --output none
    
    if [ $? -eq 0 ]; then
        echo "✓ Regla para $name agregada exitosamente"
    else
        echo "✗ Error agregando regla para $name"
    fi
    echo ""
done

echo "Verificando reglas agregadas:"
az network nsg rule list \
  --resource-group "$RESOURCE_GROUP" \
  --nsg-name "$NSG_NAME" \
  --query "[?priority>=1010 && priority<=1020].{Name:name,Port:destinationPortRange,Priority:priority}" \
  --output table
```

## Resumen de Puertos Existentes vs Nuevos

### Puertos Ya Configurados (deberían estar):
- **22** - SSH
- **80** - HTTP (Nginx)
- **8089** - Locust
- **9000** - SonarQube (opcional, si se accede directo)

### Puertos Nuevos a Agregar:
- **9090** - Prometheus
- **3000** - Grafana
- **9093** - Alertmanager
- **9200** - Elasticsearch

## Verificar Reglas Actuales

```bash
# Listar todas las reglas del NSG
az network nsg rule list \
  --resource-group <resource-group> \
  --nsg-name <nsg-name> \
  --query "[].{Name:name,Port:destinationPortRange,Priority:priority,Access:access}" \
  --output table

# Ver solo reglas de entrada
az network nsg rule list \
  --resource-group <resource-group> \
  --nsg-name <nsg-name> \
  --query "[?direction=='Inbound'].{Name:name,Port:destinationPortRange,Priority:priority,Access:access}" \
  --output table
```

## Prioridades Recomendadas

Para evitar conflictos, usa estas prioridades:
- 1001 - SSH (22)
- 1002 - HTTP (80)
- 1003 - HTTPS (443) - si lo usas
- 1004 - SonarQube (9000) - si lo usas
- 1005 - Locust (8089)
- **1010 - Prometheus (9090)** ← NUEVO
- **1011 - Grafana (3000)** ← NUEVO
- **1012 - Alertmanager (9093)** ← NUEVO
- **1013 - Elasticsearch (9200)** ← NUEVO

## Nota de Seguridad

Si quieres restringir el acceso por IP en lugar de `Any`:

```bash
# Ejemplo: Solo permitir desde tu IP
MY_IP=$(curl -s ifconfig.me)

az network nsg rule create \
  --resource-group $RESOURCE_GROUP \
  --nsg-name $NSG_NAME \
  --name Allow-Prometheus-Restricted \
  --priority 1010 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes "$MY_IP/32" \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 9090
```

## Verificación Después de Agregar Reglas

```bash
# Probar desde tu máquina local
curl -I http://VM_IP:9090/-/healthy  # Prometheus
curl -I http://VM_IP:3000/api/health  # Grafana
curl -I http://VM_IP:9093/-/healthy   # Alertmanager
curl http://VM_IP:9200/_cluster/health  # Elasticsearch
```

## Alternativa: Usar Solo Nginx (Sin Abrir Puertos Adicionales)

Si prefieres **NO abrir puertos adicionales** por seguridad, puedes acceder a todos los servicios vía Nginx (puerto 80):

- `http://VM_IP/prometheus/` → Prometheus
- `http://VM_IP/grafana/` → Grafana
- `http://VM_IP/alertmanager/` → Alertmanager
- `http://VM_IP/elasticsearch/` → Elasticsearch

**Ventajas:**
- ✅ Solo necesitas el puerto 80 abierto
- ✅ Más seguro
- ✅ Un solo punto de entrada

**Desventajas:**
- ❌ No puedes acceder directamente a los servicios
- ❌ Algunas herramientas pueden necesitar acceso directo

