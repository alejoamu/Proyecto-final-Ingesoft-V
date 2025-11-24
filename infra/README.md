# Terraform Infrastructure

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
