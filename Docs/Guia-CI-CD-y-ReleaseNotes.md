Guía de Infraestructura, CI/CD y Release Notes

Resumen
Este documento explica cómo:
- Provisionar 2 VMs en Azure (Terraform)
- Configurar y desplegar microservicios y stack de CI (Ansible)
- Configurar Jenkins y la pipeline incluida (Jenkinsfile)
- Detectar cambios mayores y generar Release Notes
- (Opcional) Auto-tag (bump mayor) y publicar Releases en GitHub

Prerequisitos
- Windows con cmd o PowerShell y/o WSL Ubuntu
- Azure CLI: https://aka.ms/installazurecliwindows
- Terraform: https://developer.hashicorp.com/terraform/downloads
- Ansible en WSL Ubuntu (recomendado):
  sudo apt update && sudo apt install -y ansible rsync sshpass
- Jenkins: instancia corriendo (se instala en la VM CI automáticamente con k3s + Helm), usar un agente Linux para esta pipeline.
- Git y herramientas GNU (git, grep, sed) disponibles en el agente.

1) Provisionar Azure con Terraform
- Autentícate y selecciona la suscripción:
  az login
  az account set --subscription "<tu-subscription>"
- Variables:
  - Contraseña por defecto: P@ssword1-2025!
  - Puedes editar infra/azure/terraform/terraform.tfvars.example y copiarlo a terraform.tfvars.
- Despliegue:
  cd infra/azure/terraform
  terraform init
  terraform plan -out tfplan
  terraform apply tfplan
- Outputs:
  - vm_app_public_ip: IP pública de la VM App (microservicios)
  - vm_ci_public_ip: IP pública de la VM CI (k3s + Jenkins + Sonar + Trivy)

Puertos abiertos por NSG
- App VM: 22 (SSH), 8080 (Gateway), 8761 (Eureka), 9296 (Config), 9411 (Zipkin)
- CI VM: 32080 (Jenkins), 32000 (SonarQube)

2) Despliegue con Ansible
- Edita infra/ansible/inventory.ini e introduce las IPs públicas de cada VM.
- Credenciales por defecto (group_vars/all.yml):
  - Usuario: azureuser
  - Contraseña: P@ssword1-2025!
- Ejecuta el playbook completo (desde la raíz del repo):
  ansible -i infra/ansible/inventory.ini all -m ping
  ansible-playbook -i infra/ansible/inventory.ini infra/ansible/site.yml -e repo_src=.
- Resultado:
  - VM App: Docker/Compose instalados y microservicios arriba (core.yml, espera Eureka/Config y luego compose.yml)
  - VM CI: k3s + Helm; Jenkins, SonarQube y Trivy Operator desplegados.

Accesos después del despliegue
- App VM
  - Gateway: http://<vm_app_public_ip>:8080/app
  - Eureka:  http://<vm_app_public_ip>:8761/
  - Config:  http://<vm_app_public_ip>:9296/
  - Zipkin:  http://<vm_app_public_ip>:9411/
- CI VM
  - Jenkins:   http://<vm_ci_public_ip>:32080
    - Password inicial Jenkins:
      ssh azureuser@<vm_ci_public_ip> "sudo kubectl -n ci exec -it deploy/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword"
  - SonarQube: http://<vm_ci_public_ip>:32000 (admin/admin, cambia al primer login)

3) Configurar Jenkins (pipeline)
- El repositorio incluye un Jenkinsfile en la raíz.
- Opciones para crear el job:
  Opción A: Job DSL seed (recomendado)
  - Abre Jenkins > New Item > Freestyle Project "seed-job"
  - Añade un paso "Process Job DSLs" apuntando a: infra/ci/seed.groovy
  - Edita previamente infra/ci/seed.groovy y define REPO_URL (y CREDENTIALS_ID si usas credenciales):
    - REPO_URL por ejemplo: https://github.com/tu-org/ecommerce-microservice-backend-app.git
    - CREDENTIALS_ID (opcional) si tu repo requiere credenciales en Jenkins
  - Construye "seed-job" para generar el pipeline "ecommerce-ms-pipeline"

  Opción B: Crear Pipeline manualmente
  - New Item > Pipeline > "ecommerce-ms-pipeline"
  - Pipeline script from SCM > Git
    - Repo: URL del repo
    - Credenciales (si aplica)
    - Script Path: Jenkinsfile

Parámetros de la pipeline
- RUN_SONAR (bool): Ejecuta análisis SonarQube con Maven.
  - SONAR_HOST_URL: http://<vm_ci_public_ip>:32000
  - SONAR_TOKEN: crea un token en SonarQube (usar Credentials de Jenkins es ideal).
- RUN_TRIVY (bool): Ejecuta trivy fs en el workspace y archiva SARIF.
- AUTO_TAG (bool): Crea y push de un tag mayor automáticamente si hay cambios mayores.
  - TAG_PREFIX: prefijo de tag (por defecto v, generará vX.0.0)
- PUBLISH_RELEASE (bool): Publica release en GitHub usando GH_TOKEN.
  - GH_TOKEN: token con permisos repo para crear releases.

4) Detección de cambios mayores (Major)
La pipeline detecta cambios mayores si desde el último tag encuentra alguno de estos patrones:
- Commits con "!:" en el título (convencional commits: feat!: …)
- Cuerpo del commit contiene "BREAKING CHANGE"
- Título del commit empieza con "Feat:" o "Test:" (primera mayúscula)

Consejos:
- Crea un tag inicial (por ejemplo v1.0.0) para tener un rango claro.
  git tag v1.0.0
  git push --tags
- Usa títulos de commit consistentes:
  - Major: feat!: / BREAKING CHANGE / Feat: / Test:
  - Feature: feat(scope): …
  - Fix: fix(scope): …

5) Release Notes
- Si hay cambios mayores se genera un archivo markdown:
  release-notes-<version-maven>-<YYYY-MM-DD>.md
- Secciones:
  - Breaking Changes
  - Features
  - Fixes
  - Tests
  - Full log (resumen de commits)
- Se archiva como artefacto del build.

6) Auto Tag (opcional)
- Si AUTO_TAG = true, calcula el siguiente tag mayor y lo empuja al remoto.
- Requisitos:
  - El job debe tener credenciales para pushear a origin (SSH key o credenciales HTTPS en el checkout).
  - TAG_PREFIX (por defecto v): generará v2.0.0, v3.0.0, etc.

7) Publicar Release en GitHub (opcional)
- Si PUBLISH_RELEASE = true y GH_TOKEN presente, crea un release en GitHub usando los release notes.
- Requisitos:
  - El remoto debe ser GitHub (se infiere desde git remote origin url).
  - GH_TOKEN con permiso "repo".

8) Troubleshooting
- Jenkins agente Windows: esta pipeline usa grep/sed; usa un agente Linux o instala herramientas GNU/WSL.
- Shallow clones: la etapa Prepare fuerza fetch de historial y tags.
- No detecta tags: crea un tag inicial y pushea.
- SonarQube falla: valida SONAR_HOST_URL y TOKEN; verifica conectividad y que SonarQube esté arriba.
- Trivy no instalado: el stage imprime un aviso y continúa.
- Push de tags falla: configura credenciales de push en Jenkins (SSH key o usuario/token HTTPS).
- Publish Release dice "no es GitHub": tu repositorio remoto no es GitHub; se omite.

9) Seguridad
- La contraseña por defecto es P@ssword1-2025!. Restringe el NSG a tu IP (allowed_source_ip = "X.X.X.X/32").
- Considera migrar a claves SSH y TLS/Ingress en la VM CI para producción.

10) Credenciales en Jenkins y GH_TOKEN
- Plugins: Ansible instala automáticamente los plugins necesarios (Job DSL, Pipeline, Git, GitHub, JUnit y Credentials Binding) cuando despliega Jenkins.

A) Obtener GH_TOKEN (GitHub Personal Access Token)
- Ve a GitHub (mismo usuario dueño del repo):
  - Settings > Developer settings > Personal access tokens
  - Recomendado: Fine-grained token o PAT classic
    - Para repos públicos: public_repo suele bastar
    - Para repos privados y creación de releases: repo (lectura/escritura)
  - Copia el token generado (guárdalo en lugar seguro)

B) Registrar GH_TOKEN en Jenkins
- Opción 1 (Pipeline param): pásalo en el parámetro GH_TOKEN del job (menos seguro).
- Opción 2 (Recomendada) Credentials Binding:
  - Jenkins > Manage Jenkins > Credentials > (Global) > Add Credentials
  - Kind: Secret text
  - Secret: (pega GH_TOKEN)
  - ID: github-token    (o el ID que prefieras)
  - En la pipeline, deja vacío el parámetro GH_TOKEN y usa GITHUB_CREDENTIALS_ID=github-token para que use la credencial.

C) Credenciales SCM para push de tags (Auto Tag)
- El stage Auto Tag hace git push del nuevo tag.
- Configura el pipeline para clonar con credenciales de escritura en GitHub:
  - Si usas el seed (Job DSL), define la variable de entorno CREDENTIALS_ID en el seed-job antes de ejecutarlo, con el ID de una credencial Jenkins válida para tu repo (HTTPS con usuario/token o SSH key).
  - Alternativa: edita el job generado y agrega las credenciales en el SCM del pipeline.

11) Referencias rápidas
- Ruta Jenkinsfile: /Jenkinsfile
- Seed DSL: /infra/ci/seed.groovy (por defecto apunta a tu repo GitHub)
- Terraform: /infra/azure/terraform
- Ansible: /infra/ansible
