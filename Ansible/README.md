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
