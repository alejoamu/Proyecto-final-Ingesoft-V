# Solución: Servicios Rechazan la Conexión

Si todos los servicios rechazan la conexión, sigue estos pasos en orden:

## Diagnóstico Rápido

### Paso 1: Verificar que los servicios están corriendo

```bash
ssh adminuser@158.23.84.89
cd ~
docker compose ps
```

**Esperado:** Todos los contenedores deben estar en estado "Up"

**Si no están corriendo:**
```bash
# Levantar todos los servicios
docker compose up -d

# Ver logs de errores
docker compose logs | grep -i error
```

### Paso 2: Verificar que los servicios responden LOCALMENTE en la VM

```bash
# Desde dentro de la VM
curl http://localhost:9000/sonar/  # SonarQube
curl http://localhost:9090/-/healthy  # Prometheus
curl http://localhost:3000/api/health  # Grafana
curl http://localhost/  # Nginx
```

**Si estos fallan:** El problema es con los servicios, no con el firewall.

**Si estos funcionan:** El problema es con el firewall o NSG de Azure.

## Solución: Firewall de Azure (NSG)

### Verificar y Configurar NSG en Azure Portal

1. **Ir a Azure Portal:**
   - Busca tu Resource Group
   - Busca el Network Security Group (NSG) asociado a tu VM

2. **Verificar reglas de entrada (Inbound):**
   - Debe haber reglas permitiendo:
     - Puerto **22** (SSH) - Source: Any
     - Puerto **80** (HTTP) - Source: Any
     - Puerto **8089** (Locust) - Source: Any
     - Puerto **9000** (SonarQube directo, opcional) - Source: Any

3. **Agregar reglas si faltan:**
   - Click en "Add" o "Agregar"
   - Crear regla para puerto 80:
     - Name: `Allow-HTTP`
     - Priority: `1002`
     - Source: `Any` o `Internet`
     - Destination: `Any`
     - Service: `Custom`
     - Protocol: `TCP`
     - Port range: `80`
     - Action: `Allow`

   - Crear regla para puerto 8089:
     - Name: `Allow-Locust`
     - Priority: `1005`
     - Source: `Any` o `Internet`
     - Destination: `Any`
     - Service: `Custom`
     - Protocol: `TCP`
     - Port range: `8089`
     - Action: `Allow`

### Configurar NSG con Azure CLI

```bash
# Obtener el nombre del NSG
az network nsg list --resource-group <tu-resource-group> --query "[].name" -o tsv

# Agregar regla para HTTP (puerto 80)
az network nsg rule create \
  --resource-group <tu-resource-group> \
  --nsg-name <nombre-nsg> \
  --name Allow-HTTP \
  --priority 1002 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 80

# Agregar regla para Locust (puerto 8089)
az network nsg rule create \
  --resource-group <tu-resource-group> \
  --nsg-name <nombre-nsg> \
  --name Allow-Locust \
  --priority 1005 \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --source-address-prefixes '*' \
  --source-port-ranges '*' \
  --destination-address-prefixes '*' \
  --destination-port-ranges 8089
```

## Solución: Firewall UFW en la VM

Si UFW está habilitado y bloqueando conexiones:

### Verificar estado de UFW

```bash
ssh adminuser@158.23.84.89
sudo ufw status
```

### Si UFW está activo y bloqueando:

**Opción 1: Deshabilitar UFW temporalmente (para pruebas)**
```bash
sudo ufw disable
```

**Opción 2: Agregar reglas necesarias**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 8089/tcp
sudo ufw allow 22/tcp
sudo ufw reload
```

**Opción 3: Verificar que las reglas están correctas**
```bash
sudo ufw status numbered
```

## Solución: Verificar que Nginx está funcionando

```bash
ssh adminuser@158.23.84.89
cd ~

# Verificar que Nginx está corriendo
docker compose ps nginx

# Ver logs de Nginx
docker compose logs nginx

# Verificar configuración
docker compose exec nginx nginx -t

# Reiniciar Nginx si es necesario
docker compose restart nginx
```

## Solución: Verificar mapeo de puertos

```bash
ssh adminuser@158.23.84.89

# Ver qué puertos están escuchando
sudo netstat -tlnp | grep -E ':(80|3000|8089|9090|9093|9200)'

# O con ss
sudo ss -tlnp | grep -E ':(80|3000|8089|9090|9093|9200)'

# Verificar puertos de Docker
docker compose ps
# Debe mostrar algo como: 0.0.0.0:80->80/tcp
```

## Solución Completa: Script de Reparación

Crea y ejecuta este script en la VM:

```bash
ssh adminuser@158.23.84.89
cat > ~/fix-connection.sh << 'EOF'
#!/bin/bash
set -e

echo "=== Reparando conexiones ==="

# 1. Asegurar que todos los servicios están corriendo
cd ~
docker compose up -d

# 2. Verificar UFW
if sudo ufw status | grep -q "Status: active"; then
    echo "UFW está activo, agregando reglas..."
    sudo ufw allow 80/tcp
    sudo ufw allow 8089/tcp
    sudo ufw allow 22/tcp
    sudo ufw reload
else
    echo "UFW no está activo"
fi

# 3. Verificar que los servicios responden localmente
echo "Verificando servicios locales..."
curl -s http://localhost:9000/sonar/ > /dev/null && echo "✓ SonarQube OK" || echo "✗ SonarQube FALLO"
curl -s http://localhost:9090/-/healthy > /dev/null && echo "✓ Prometheus OK" || echo "✗ Prometheus FALLO"
curl -s http://localhost:3000/api/health > /dev/null && echo "✓ Grafana OK" || echo "✗ Grafana FALLO"
curl -s http://localhost/ > /dev/null && echo "✓ Nginx OK" || echo "✗ Nginx FALLO"

# 4. Mostrar puertos abiertos
echo ""
echo "Puertos escuchando:"
sudo ss -tlnp | grep -E ':(80|3000|8089|9090|9093|9200)' || echo "No se encontraron puertos"

echo ""
echo "=== Verificar en Azure Portal que el NSG tiene reglas para puertos 80 y 8089 ==="
EOF

chmod +x ~/fix-connection.sh
~/fix-connection.sh
```

## Verificación Final

Después de aplicar las soluciones:

```bash
# Desde tu máquina local
curl -I http://158.23.84.89/
curl -I http://158.23.84.89/sonar/
curl http://158.23.84.89/prometheus/-/healthy
curl http://158.23.84.89:8089/
```

## Checklist de Verificación

- [ ] Contenedores Docker están corriendo (`docker compose ps`)
- [ ] Servicios responden localmente en la VM (`curl http://localhost:...`)
- [ ] UFW permite puertos 80 y 8089 (`sudo ufw status`)
- [ ] NSG de Azure tiene reglas para puertos 80 y 8089 (Azure Portal)
- [ ] Nginx está corriendo y configurado correctamente
- [ ] Puertos están mapeados correctamente (`docker compose ps` muestra 0.0.0.0:80->80/tcp)

## Comandos de Diagnóstico Rápido

```bash
# Ejecutar todos estos comandos en la VM
ssh adminuser@158.23.84.89 << 'ENDSSH'
cd ~
echo "=== Estado de contenedores ==="
docker compose ps

echo ""
echo "=== Servicios locales ==="
curl -s -o /dev/null -w "SonarQube: %{http_code}\n" http://localhost:9000/sonar/
curl -s -o /dev/null -w "Prometheus: %{http_code}\n" http://localhost:9090/-/healthy
curl -s -o /dev/null -w "Grafana: %{http_code}\n" http://localhost:3000/api/health
curl -s -o /dev/null -w "Nginx: %{http_code}\n" http://localhost/

echo ""
echo "=== Estado de UFW ==="
sudo ufw status

echo ""
echo "=== Puertos escuchando ==="
sudo ss -tlnp | grep -E ':(80|3000|8089|9090|9093|9200)'
ENDSSH
```

## Si Nada Funciona

1. **Verificar que la VM tiene IP pública:**
   ```bash
   az vm show -d -g <resource-group> -n <vm-name> --query publicIps -o tsv
   ```

2. **Verificar conectividad básica:**
   ```bash
   ping 158.23.84.89
   telnet 158.23.84.89 80
   ```

3. **Revisar logs del sistema:**
   ```bash
   ssh adminuser@158.23.84.89
   sudo journalctl -u docker --no-pager | tail -50
   ```

4. **Reiniciar servicios:**
   ```bash
   cd ~
   docker compose down
   docker compose up -d
   ```

