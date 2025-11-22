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

- `playbook.yml`: Playbook principal que instala Docker, SonarQube, Locust, Trivy, K3s
- `inventory.ini`: Inventario de servidores
- `nginx.conf.j2`: Template de configuración de Nginx
- `docker-compose.yml`: Stack de Docker Compose con SonarQube, Locust, Trivy

## Servidores

El playbook configura dos tipos de servidores:
- **CI**: Servidor de CI/CD con SonarQube, Locust, Trivy, K3s
- **nginx**: Servidor con Nginx como reverse proxy

