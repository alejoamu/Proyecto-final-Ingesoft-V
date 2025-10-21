Ansible para desplegar 2 VMs (Microservicios y CI)

Contenido
- inventory.ini: inventario con las IPs de tus VMs (app y ci) y credenciales (contraseña o llave SSH).
- ansible.cfg: configuraciones útiles (desactivar host key checking, ruta por defecto).
- site.yml: playbook principal con dos plays (app_vm y ci_vm).
- roles/docker: instala Docker y Docker Compose plugin.
- roles/microservices: sincroniza el repo a /opt/ecommerce y ejecuta core.yml y compose.yml.
- roles/ci_stack: instala k3s + Helm y despliega Jenkins, SonarQube, Trivy Operator.
- setup-ci-token-wsl.sh y setup-ci-token.cmd: automatizan la creación de la credencial GH_TOKEN en Jenkins (vía JCasC) usando un .env local.

Requisitos del nodo de control Ansible
- Opción WSL (recomendado en Windows): instalar Ubuntu desde la Microsoft Store, luego:
  sudo apt update && sudo apt install -y ansible rsync sshpass
  (sshpass es necesario para autenticación por contraseña en SSH)
- Opción Docker (sin WSL):
  docker run --rm -it -v %CD%:/work -w /work cytopia/ansible:latest bash

Preparación
1) Asegúrate de tener las VMs creadas con Terraform (ver ../azure/terraform). Terraform ya habilita PasswordAuthentication en SSH.
2) Edita inventory.ini con las IPs, usuario (por defecto azureuser) y añade ansible_password para cada host si no usas group_vars.

Automatizar la credencial GH_TOKEN (JCasC) vía .env
- En esta carpeta hay un .env.example; cópialo a .env y rellena GH_TOKEN con tu token de GitHub (PAT). El archivo .env ya está en .gitignore y no se sube al repositorio.
  GH_TOKEN=<tu_token_github>
- Ejecuta uno de los scripts para crear/actualizar Jenkins en la VM CI con la credencial incluida:
  - Windows (cmd + WSL):
    setup-ci-token.cmd
  - WSL/Ubuntu:
    bash ./setup-ci-token-wsl.sh
- Esto aplica sólo el stack CI (ci_vm), instala/actualiza Jenkins y crea la credencial Secret text con ID github-token mediante JCasC (puedes cambiar el ID ajustando jenkins_github_token_id con -e si lo necesitas).

Ejecución general (desde la raíz del repo)
- Playbook completo (ambas VMs). Pasa repo_src=. para sincronizar este repositorio completo:
  ansible-playbook -i infra/ansible/inventory.ini infra/ansible/site.yml -e repo_src=.

- Solo microservicios (VM App):
  ansible-playbook -i infra/ansible/inventory.ini infra/ansible/site.yml -e repo_src=. --limit app_vm

- Solo CI (VM k3s+Helm):
  ansible-playbook -i infra/ansible/inventory.ini infra/ansible/site.yml --limit ci_vm

Variables útiles (-e VAR=valor)
- repo_src: ruta local del repo que se sincroniza a /opt/ecommerce en la VM App (default: .)
- app_dir: ruta remota destino en la VM App (default: /opt/ecommerce)
- jenkins_nodeport: 32080 (por defecto)
- sonarqube_nodeport: 32000 (por defecto)
- jenkins_create_github_token_credential: true/false (por defecto false): si true y pasas jenkins_github_token, crea la credencial en Jenkins vía JCasC.
- jenkins_github_token: (string) token de GitHub que se inyectará como credencial (no se loguea por seguridad).

Comprobaciones rápidas
- App VM: 
  http://<vm_app_public_ip>:8080/app  (Gateway)
  http://<vm_app_public_ip>:8761/     (Eureka)
  http://<vm_app_public_ip>:9296/     (Config Server)
  http://<vm_app_public_ip>:9411/     (Zipkin)
- CI VM:
  Jenkins:    http://<vm_ci_public_ip>:32080
  SonarQube:  http://<vm_ci_public_ip>:32000
  Password Jenkins:
    ssh azureuser@<vm_ci_public_ip> "sudo kubectl -n ci exec -it deploy/jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword"

Notas
- Si Ansible indica que sudo requiere contraseña, agrega ansible_become_password en el inventario.
- La sincronización usa rsync (instalado en remoto por el rol) vía synchronize + ssh. Excluimos .git/ e infra/ansible/ por defecto.
- Considera usar claves SSH en producción; el uso de contraseñas es menos seguro.
