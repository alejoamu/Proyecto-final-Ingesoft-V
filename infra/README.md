# Terraform Infrastructure

Este directorio contiene la configuración de Terraform para desplegar la infraestructura en Azure.

## Configuración

1. **Copiar archivo de variables de ejemplo:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configurar variables:**
   - Editar `terraform.tfvars` con tus valores
   - O usar variables de entorno:
     ```bash
     export TF_VAR_region="Mexico Central"
     export TF_VAR_user="adminuser"
     export TF_VAR_password="your_password"
     export TF_VAR_prefix_name="devops"
     ```

3. **Inicializar Terraform:**
   ```bash
   terraform init
   ```

4. **Planificar cambios:**
   ```bash
   terraform plan -out=tfplan
   ```

5. **Aplicar cambios:**
   ```bash
   terraform apply tfplan
   ```

## Variables Requeridas

- `region`: Región de Azure donde desplegar
- `user`: Usuario SSH para las VMs
- `password`: Contraseña SSH (usar variable de entorno para seguridad)
- `prefix_name`: Prefijo para nombres de recursos
- `servers`: Lista de nombres de servidores a crear

## Seguridad

⚠️ **IMPORTANTE**: Nunca commitees `terraform.tfvars` con credenciales reales. Usa variables de entorno o un sistema de gestión de secretos.
