# Ansible Playbooks

Este directorio contiene los playbooks de Ansible para configurar y desplegar la infraestructura.

## Configuración

1. **Configurar inventario:**
   - Editar `inventory.ini` con las IPs de tus servidores
   - Usar Ansible Vault para credenciales (ver abajo)

2. **Crear archivo vault con credenciales:**
   ```bash
   ansible-vault create group_vars/all/vault.yml
   ```
   
   Contenido del vault:
   ```yaml
   vault_ci_password: "tu_password_ci"
   vault_code_password: "tu_password_code"
   ```

3. **Ejecutar playbook:**
   ```bash
   ansible-playbook -i inventory.ini playbook.yml --ask-vault-pass
   ```

## Seguridad

⚠️ **IMPORTANTE**: 
- Usa Ansible Vault para almacenar credenciales
- No commitees archivos con passwords en texto plano
- El archivo `vault.yml` debe estar encriptado

## Estructura

- `playbook.yml`: Playbook principal que instala Docker, SonarQube, Locust, Trivy, Prometheus, Grafana, Alertmanager, Elasticsearch y Filebeat en la VM de CI y aplica manifests/charts en AKS desde el controlador
- `inventory.ini`: Inventario con el host `ci` y el host `local` (localhost para comandos `kubectl/helm`)
- `nginx.conf.j2`: Template de configuración de Nginx
- `docker-compose.yml`: Stack de Docker Compose con SonarQube, Locust, Trivy, Prometheus, Grafana, Alertmanager, Elasticsearch y Filebeat
- `monitoring/`: Configuraciones de Prometheus y Alertmanager para la VM

## Servidores / Componentes

El playbook ahora espera:
- **CI**: única VM (grupo `ci`) con:
  - **Calidad de código**: SonarQube/Postgres
  - **Pruebas de carga**: Locust (master + worker)
  - **Seguridad**: Trivy
  - **Monitoreo**: Prometheus, Grafana, Alertmanager
  - **Logs**: Elasticsearch, Filebeat
  - **Proxy reverso**: Nginx
- **AKS**: clúster administrado en Azure, gestionado desde el controlador local exportando `AKS_RESOURCE_GROUP` y `AKS_CLUSTER_NAME` para las tareas de `kubectl`/`helm`

## Herramientas disponibles en la VM

Después de ejecutar el playbook, las siguientes herramientas estarán disponibles en la VM:

### Calidad y Seguridad
- **SonarQube**: http://VM_IP/sonar/ (puerto 9000 directo)
  - Usuario/contraseña por defecto: `admin/admin` (cambiar en primer inicio)
- **Trivy**: CLI instalado, contenedor disponible con perfil `tools`

### Pruebas de Carga
- **Locust**: http://VM_IP:8089/
  - Interfaz web para ejecutar pruebas de carga

### Monitoreo
- **Prometheus**: http://VM_IP/prometheus/ (puerto 9090 directo)
  - Métricas y consultas PromQL
- **Grafana**: http://VM_IP/grafana/ (puerto 3000 directo)
  - Usuario: `admin` / Contraseña: `admin`
  - Dashboards pre-configurados para monitoreo
- **Alertmanager**: http://VM_IP/alertmanager/ (puerto 9093 directo)
  - Gestión de alertas de Prometheus

### Logs
- **Elasticsearch**: http://VM_IP/elasticsearch/ (puerto 9200 directo)
  - API REST para búsqueda de logs
- **Filebeat**: Recolecta logs de contenedores Docker automáticamente

### Proxy Reverso
- **Nginx**: http://VM_IP/ (puerto 80)
  - Redirige a SonarQube por defecto
  - Rutas disponibles:
    - `/sonar/` → SonarQube
    - `/prometheus/` → Prometheus
    - `/grafana/` → Grafana
    - `/alertmanager/` → Alertmanager
    - `/elasticsearch/` → Elasticsearch

## Ejecución recomendada

### Desde Linux/Mac/WSL

```bash
# Navegar al directorio Ansible
cd Ansible

# Exportar variables para el play de AKS
export AKS_RESOURCE_GROUP="dev-rg"
export AKS_CLUSTER_NAME="ecdev-aks"

# Ejecutar playbook completo
ansible-playbook -i inventory.ini playbook.yml
```

### Solo ejecutar playbook de CI (sin AKS)

```bash
ansible-playbook -i inventory.ini playbook.yml --limit ci
```

### Ejecutar solo playbook de AKS (desde localhost)

```bash
export AKS_RESOURCE_GROUP="dev-rg"
export AKS_CLUSTER_NAME="ecdev-aks"
ansible-playbook -i inventory.ini playbook.yml --limit local
```

> **Nota para usuarios de WSL**: Ver [WSL_SETUP.md](WSL_SETUP.md) para una guía completa de instalación y configuración en WSL.

## Solución de problemas

### Error: "no such host" o "Unable to connect to the server"

Si acabas de **recrear el cluster AKS** o el DNS ha cambiado, el playbook ahora **detecta automáticamente** este error y refresca las credenciales. Sin embargo, si quieres forzar la actualización manualmente:

**Opción 1: Forzar actualización automática (recomendado)**
```bash
# El playbook detectará el error y actualizará automáticamente
env AKS_RESOURCE_GROUP="dev-rg" AKS_CLUSTER_NAME="ecdev-aks" ansible-playbook -i inventory.ini playbook.yml
```

**Opción 2: Forzar actualización manual antes de ejecutar**
```bash
# Eliminar kubeconfig antiguo
rm ~/.kube/aks-config

# O especificar una ruta diferente
export AKS_KUBECONFIG=~/.kube/aks-config-new

# Ejecutar playbook
env AKS_RESOURCE_GROUP="dev-rg" AKS_CLUSTER_NAME="ecdev-aks" ansible-playbook -i inventory.ini playbook.yml
```

**Opción 3: Usar variable para forzar refresh**
```bash
# El playbook refrescará las credenciales si aks_refresh_credentials=true
env AKS_RESOURCE_GROUP="dev-rg" AKS_CLUSTER_NAME="ecdev-aks" \
    ansible-playbook -i inventory.ini playbook.yml -e "aks_refresh_credentials=true"
```

**Opción 4: Actualizar manualmente con Azure CLI**
```bash
# Obtener credenciales frescas del cluster
az aks get-credentials -g dev-rg -n ecdev-aks --file ~/.kube/aks-config --overwrite-existing

# Verificar conexión
kubectl --kubeconfig ~/.kube/aks-config get nodes
```