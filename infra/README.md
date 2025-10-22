inInfraestructura con Terraform (Azure - Mexico Central)

Resumen
- Crea una red básica en Azure y un conjunto de VMs Linux (Ubuntu 20.04 LTS Gen2) cuyo nombre proviene de la lista variable "servers".
- Cada VM es Standard_B2s (límite compatible con Azure Student) y recibe IP pública estática (SKU Standard).
- Reglas NSG preconfiguradas para facilitar el uso de CI/CD: SSH (22), HTTP (80), HTTPS (443), Jenkins (8080), SonarQube (9000) y Kubernetes API (6443).
- Pensado para que luego configures las VMs con Ansible (instalación de Docker, Jenkins, SonarQube, Helm/K3s, etc.).

Estructura
- main.tf: RG, VNet, Subnet y consumo del módulo de VMs.
- providers.tf: proveedor azurerm (~> 3.x) y versión mínima de Terraform.
- variables.tf: variables de entrada del módulo raíz (región, prefijo, credenciales, servidores).
- outputs.tf: salidas públicas (public_ips, vm_ids).
- modules/vm: módulo reutilizable que crea IPs públicas, NICs, NSG y VMs por nombre.

Prerrequisitos
1) Terraform >= 1.0.0
2) Azure CLI instalado y con sesión iniciada

```cmd
az login
az account show
```

3) Una contraseña que cumpla políticas de Azure (o adapta el módulo a SSH keys si prefieres). Actualmente se usa autenticación con contraseña.

Variables principales (archivo terraform.tfvars)
Ejemplo recomendado:

```hcl
region      = "Mexico Central"
prefix_name = "devops"
user        = "adminuser"
password    = "P@ssw0rd1234"   # Debe cumplir complejidad de Azure
servers     = ["ci", "app"]   # Nombres de las VMs a crear
```

Qué se crea
- Resource Group: <prefix>-rg
- Virtual Network: <prefix>-network (10.0.0.0/16)
- Subnet: <prefix>-subnet (10.0.1.0/24)
- Por cada nombre en servers:
  - Public IP (Standard, estática): <server>-public-ip
  - NIC: <server>-nic
  - VM Linux (Ubuntu 20.04 LTS Gen2): <server>-machine (tamaño Standard_B2s)
- NSG común (<prefix>-sg) con reglas de entrada:
  - 22 (SSH), 80 (HTTP), 443 (HTTPS), 8080 (Jenkins), 9000 (SonarQube), 6443 (Kubernetes API)

Seguridad y mínimo privilegio
- De fábrica, las reglas permiten acceso desde cualquier origen (0.0.0.0/0) para facilitar pruebas del taller.
- Para endurecer (recomendado):
  - Restringe SSH (22) a tu IP pública (X.X.X.X/32).
  - Si usarás Jenkins/Sonar/Ingress solo en la VM "ci", considera mover reglas por VM o separar NSGs.
  - Puedes ajustar las reglas en `modules/vm/main.tf` antes de aplicar.

Cómo desplegar (Windows cmd)
1) Ubícate en la carpeta infra:
```cmd
cd infra
```

2) Revisa/ajusta `terraform.tfvars` con tus valores.

3) Inicializa, planifica y aplica:
```cmd
terraform init
terraform plan
terraform apply -auto-approve
```

Salidas útiles
- public_ips: mapa nombre -> IP pública
- vm_ids: mapa nombre -> ID de VM

Consultas rápidas:
```cmd
terraform output public_ips
terraform output vm_ids
terraform output -json public_ips
```

Integración rápida con Ansible
- Crea un inventario con las IPs dadas por `public_ips`. Ejemplo (Ansible/inventory.ini):

```ini
[ci]
ci ansible_host=<IP_de_ci> ansible_user=adminuser ansible_password=P@ssw0rd1234

[app]
app ansible_host=<IP_de_app> ansible_user=adminuser ansible_password=P@ssw0rd1234
```

- Con el `ansible.cfg` ya presente (host_key_checking=False), prueba conectividad:
```cmd
cd Ansible
ansible all -i inventory.ini -m ping
```

Limpieza
```cmd
terraform destroy -auto-approve
```

Notas y troubleshooting
- Región: el valor recomendado es "Mexico Central". Si tu suscripción no tiene capacidad, prueba otra región.
- Cuotas Azure Student: se limita a tamaños pequeños y pocos recursos (este setup usa 2x Standard_B2s).
- Contraseña inválida: si falla la creación de la VM, revisa la complejidad de `password`.
- Puertos no accesibles: comprueba que la IP pública corresponda a la VM esperada y que las reglas NSG estén aplicadas.

Siguientes pasos (sugerencias)
- Instalar en la VM "ci" con Ansible: Docker, Jenkins (8080), SonarQube (9000) con Postgres, y un cluster ligero (K3s) + Helm para despliegue.
- Opcional: cerrar puertos no usados y exponer solo los necesarios a Internet; usar un Ingress Controller en la VM "ci" si vas a publicar endpoints HTTP/HTTPS.

