Infraestructura para despliegue en Azure (2 VMs)

Resumen
- VM App: Ubuntu 22.04 con Docker y Docker Compose (para ejecutar tus microservicios con los compose existentes).
- VM CI/K8s: Ubuntu 22.04 con k3s (Kubernetes ligero) + Helm. Se instalan Jenkins, SonarQube y Trivy Operator vía Helm.

Arquitectura
- Red virtual única con una subred para ambas VMs.
- NSG con reglas de entrada mínimas necesarias:
  - SSH (22) para administración.
  - API Gateway (8080), Eureka (8761), Config Server (9296), Zipkin (9411) en VM App.
  - Jenkins (32080) y SonarQube (32000) expuestos como NodePort en VM CI.

Requisitos previos
- Cuenta de Azure con permisos para crear recursos.
- Azure CLI instalado (para autenticación): https://aka.ms/installazurecliwindows
- Terraform instalado en tu Windows (cmd.exe): https://developer.hashicorp.com/terraform/downloads
- Usaremos autenticación por contraseña (menos segura). Define una contraseña fuerte.

Autenticación en Azure (una vez por equipo)
- Abre cmd.exe y ejecuta:
  az login
  az account set --subscription "<tu-subscription-name-o-id>"

Variables principales (Terraform)
- location: región de Azure (por defecto eastus).
- prefix: prefijo de nombres de recursos (por defecto ecom-ms).
- admin_username: usuario admin en las VMs (por defecto azureuser).
- admin_password: contraseña del usuario admin (obligatoria si no usas SSH keys). Debe cumplir políticas de Azure.
- ssh_public_key: opcional, si quieres además permitir login por clave pública.
- allowed_source_ip: tu IP pública/CIDR para restringir SSH/HTTP (por defecto 0.0.0.0/0 abierto).

Ejemplo rápido de terraform.tfvars (usa el archivo de ejemplo incluido)
- Revisa y copia: infra\azure\terraform\terraform.tfvars.example
- Ajusta admin_password a una contraseña robusta.

Pasos rápidos (Windows cmd.exe)
1) Inicializar y aplicar Terraform:
   cd infra\azure\terraform
   terraform init
   terraform plan -out tfplan
   terraform apply tfplan

2) Al finalizar, Terraform mostrará las IPs públicas de ambas VMs:
   - vm_app_public_ip: IP pública de la VM de microservicios
   - vm_ci_public_ip: IP pública de la VM k3s + Helm

3) Conectarte por SSH con contraseña (se habilitó PasswordAuthentication en cloud-init):
   ssh azureuser@<vm_app_public_ip>
   ssh azureuser@<vm_ci_public_ip>
   (ingresa la contraseña que definiste en admin_password)

4) Desplegar microservicios en la VM App (opcional si no usarás Ansible):
   Opción A (copiar repo y usar Docker Compose)
     scp -r . azureuser@<vm_app_public_ip>:/opt/ecommerce
     En la VM App:
       cd /opt/ecommerce
       docker compose -f core.yml up -d
       docker compose -f compose.yml up -d
   Opción B (helper):
     sudo /usr/local/bin/run-stack.sh

   Puertos expuestos por defecto:
   - API Gateway: http://<vm_app_public_ip>:8080/app
   - Eureka: http://<vm_app_public_ip>:8761/
   - Config Server: http://<vm_app_public_ip>:9296/
   - Zipkin: http://<vm_app_public_ip>:9411/

5) Verificar CI en la VM CI (k3s + Helm):
   - Jenkins:    http://<vm_ci_public_ip>:32080
     Password inicial:
       sudo kubectl -n ci exec -it deploy/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
   - SonarQube:  http://<vm_ci_public_ip>:32000 (usuario admin / pass admin por defecto; te pedirá cambiarla)
   - Trivy Operator: kubectl -n trivy-system get deploy,pods

Notas de seguridad
- Usar contraseñas para acceso SSH es menos seguro. Restringe el acceso con allowed_source_ip y usa contraseñas robustas.
- Considera migrar a claves SSH o Azure Key Vault en entornos productivos.
- Para dominios/HTTPS, añade un Ingress Controller y TLS; evita publicar NodePorts a Internet.

Limpieza
- Para destruir toda la infraestructura creada por Terraform:
  cd infra\azure\terraform
  terraform destroy

Soporte y ajustes
- Cambia tamaños de VM, imagen, puertos, etc., en los .tf.
- Si prefieres AKS + ACR, se puede adaptar esta solución en una siguiente iteración.
