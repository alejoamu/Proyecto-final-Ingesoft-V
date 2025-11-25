inInfraestructura con Terraform (Azure - Mexico Central)


Este directorio contiene la infraestructura como código modular para **Azure** organizada por ambientes: `dev`, `stage`, `prod`.

## Estructura
```
infra/
  providers.tf
  variables.tf (legacy root vars)
  backend_bootstrap.tf  # Bootstrap opcional para crear el backend de Terraform en Azure
  modules/
    network/        # RG, VNet, Subnet en Azure
    vm/             # Public IP, NIC, Linux VM en Azure
    security/       # Network Security Group parametrizable en Azure
    backup/         # Módulo legacy (sin uso actual)
    traffic_manager/# Azure Traffic Manager endpoints externos
  environments/
    dev/
    stage/
    prod/
```

## Objetivos Implementados
- Modularización: separación de red, seguridad, cómputo, backup y balanceo.
- Multi-ambiente: carpetas `dev`, `stage`, `prod` con su propio `main.tf` y backend remoto (state).
- Backend remoto: se puede crear y gestionar de forma automatizada con Terraform (`backend_bootstrap.tf`), evitando pasos manuales en Azure CLI.
- Seguridad parametrizable: reglas definidas en `modules/security` con lista dinámica.

## Flujo de uso recomendado

### 1. (Opcional) Bootstrap del backend de Terraform en Azure

criocAntes de usar los entornos, puedes crear automáticamente el Resource Group y Storage Account para el estado remoto. Para ello, usa el proyecto de bootstrap:

```bash
cd infra/backend-bootstrap
terraform init
terraform apply \
  -var="backend_location=mexicocentral" \
  -var="backend_resource_group_name=tfstate-rg" \
  -var="backend_storage_account_name=tfstateaccount" \
  -var="backend_container_name=tfstate"
```

Al finalizar, ya existirán `tfstate-rg`, `tfstateaccount` y `tfstate`, que son los valores usados en los bloques backend `azurerm` de los entornos.

> Si ya tienes creado el backend (por ejemplo, en otra práctica), puedes saltarte este paso o volver a aplicar aquí para recrearlo.

### 2. Desplegar un entorno (dev/stage/prod)

Dentro de `infra/environments/<env>`:

```bash
cd infra/environments/dev
terraform init
terraform plan -var="region=mexicocentral" -var="prefix_name=ecdev" -var="servers=[\"devops1\",\"devops2\"]" -var="user=adminuser" -var="password=SuperSegura123" -out plan.tfplan
terraform apply plan.tfplan
```

Para stage:

```bash
cd infra/environments/stage
terraform init
terraform plan -var="region=mexicocentral" -var="prefix_name=ecstage" -var="servers=[\"stage1\"]" -var="user=adminuser" -var="password=OtroPass123" -out plan.tfplan
terraform apply plan.tfplan
```

Para prod (ejemplo multi subnet y tamaño distinto):

```bash
cd infra/environments/prod
terraform init
terraform plan -var="region=mexicocentral" -var="prefix_name=ecprod" -var="servers=[\"prod1\",\"prod2\",\"prod3\"]" -var="user=adminuser" -var="password=ProdPass123!" -out plan.tfplan
terraform apply plan.tfplan
```

## Salidas Clave
- `modules/vm` expone `public_ips` y `vm_ids` (en root legacy o extender outputs en ambientes si se requiere).
- `modules/network` entrega `resource_group_name`, `location`, `subnet_id`.
- `modules/security` entrega `nsg_id` (puedes asociarlo a NICs si extiendes módulo vm).
- `modules/traffic_manager` `traffic_manager_dns_name` para endpoint global.

## Extensiones Sugeridas
- Asociar NSG a NICs: añadir recurso `azurerm_network_interface_security_group_association` en ambientes usando `for_each` sobre NICS del módulo vm.
- Recovery Services Vault: reemplazar el módulo `backup` legacy por configuración real en Azure + replicación geo.
- Private Endpoints y Firewall: agregar módulos para reforzar seguridad en producción.
- Observabilidad: módulo de Log Analytics + Diagnostic Settings para VMs.

## Seguridad
- No commit de credenciales en archivos `.tfvars`.
- Usar `Key Vault` para secretos y referenciar con data sources.
- Limitar puertos de NSG en prod (ej. cerrar Sonar/Locust).
- Habilitar `Just-In-Time` acceso para SSH en producción.

## Limpieza
```bash
terraform destroy -var="region=mexicocentral" -var="prefix_name=ecdev" -var="servers=[\"devops1\",\"devops2\"]" -var="user=adminuser" -var="password=SuperSegura123"
```

## Migración Legacy Root
El archivo `infra/main.tf` existente puede ser deprecado; mover su lógica a ambientes. Mantenerlo sólo para referencia histórica.

## Próximos Pasos
1. Implementar asociación NSG ↔ NIC en ambientes.
2. Añadir módulo de base de datos (Azure Database for MySQL/Postgres) con backups automáticos.
3. Añadir módulo de Container Registry (ACR) y enlazarlo a pipeline CI/CD.
4. Crear pipeline Terraform (GitHub Actions) separado por ambiente con validación y plan PR.
5. Integrar escaneo de seguridad (tfsec / checkov) antes de aplicar.
=======
Resumen
- Crea una red básica en Azure y un conjunto de VMs Linux (Ubuntu 20.04 LTS Gen2) cuyo nombre proviene de la lista variable "servers".
- Cada VM es Standard_B2s (límite compatible con Azure Student) y recibe IP pública estática (SKU Standard).
- Reglas NSG preconfiguradas para facilitar el uso de CI/CD: SSH (22), HTTP (80), HTTPS (443), SonarQube (9000), Locust (8089) y Kubernetes API (6443).
- Pensado para que luego configures las VMs con Ansible (instalación de Docker, SonarQube, Helm/K3s, etc.).

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
  - 22 (SSH), 80 (HTTP), 443 (HTTPS), 9000 (SonarQube), 8089 (Locust), 6443 (Kubernetes API)

Seguridad y mínimo privilegio
- De fábrica, las reglas permiten acceso desde cualquier origen (0.0.0.0/0) para facilitar pruebas del taller.
- Para endurecer (recomendado):
  - Restringe SSH (22) a tu IP pública (X.X.X.X/32).
  - Si usarás Sonar/Ingress/Locust solo en la VM "ci", considera mover reglas por VM o separar NSGs.
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
- Instalar en la VM "ci" con Ansible: Docker, SonarQube (9000) con Postgres, Locust (8089), y un cluster ligero (K3s) + Helm para despliegue.
- Opcional: cerrar puertos no usados y exponer solo los necesarios a Internet; usar un Ingress Controller en la VM "ci" si vas a publicar endpoints HTTP/HTTPS.

