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

- `playbook.yml`: Playbook principal que instala Docker, SonarQube, Locust, Trivy en la VM de CI y aplica manifests/charts en AKS desde el controlador
- `inventory.ini`: Inventario con el host `ci` y el host `local` (localhost para comandos `kubectl/helm`)
- `nginx.conf.j2`: Template de configuración de Nginx
- `docker-compose.yml`: Stack de Docker Compose con SonarQube, Locust, Trivy

## Servidores / Componentes

El playbook ahora espera:
- **CI**: única VM (grupo `ci`) con SonarQube/Postgres vía Docker, Locust, Trivy y Nginx
- **AKS**: clúster administrado en Azure, gestionado desde el controlador local exportando `AKS_RESOURCE_GROUP` y `AKS_CLUSTER_NAME` para las tareas de `kubectl`/`helm`

## Ejecución recomendada

```bash
# exporta las variables para el play de AKS
env AKS_RESOURCE_GROUP="dev-rg" AKS_CLUSTER_NAME="ecdev-aks" ansible-playbook -i inventory.ini playbook.yml
```

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