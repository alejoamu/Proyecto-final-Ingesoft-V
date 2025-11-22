# Terraform Infrastructure

Este directorio contiene la infraestructura como código modular para Azure (y recursos auxiliares multi-cloud) organizada por ambientes: `dev`, `stage`, `prod`.

## Estructura
```
infra/
  providers.tf
  variables.tf (legacy root vars)
  modules/
    network/        # RG, VNet, Subnet
    vm/             # Public IP, NIC, Linux VM
    security/       # Network Security Group parametrizable
    backup/         # Bucket S3 (simulación backup cross-cloud)
    traffic_manager/# Azure Traffic Manager endpoints externos
  environments/
    dev/
    stage/
    prod/
```

## Objetivos Implementados
- Modularización: separación de red, seguridad, cómputo, backup y balanceo.
- Multi-ambiente: carpetas `dev`, `stage`, `prod` con su propio `main.tf` y backend remoto (state).
- Backend remoto: configurado (placeholder) en cada ambiente para usar Azure Storage (ajusta RG, storage y container reales antes de `terraform init`).
- Estrategia de respaldo: módulo `backup` simula exportación de metadatos de VMs hacia S3 (multi-cloud). Puede extenderse a Recovery Services o Data Factory.
- Balanceo multi-región/proveedor: módulo `traffic_manager` crea perfil de Azure Traffic Manager con endpoints externos (simulados) para failover.
- Seguridad parametrizable: reglas definidas en `modules/security` con lista dinámica.

## Pre-requisitos
1. Crear Storage Account para estados remotos:
```bash
az group create -n tfstate-rg -l eastus
az storage account create -n tfstateaccount -g tfstate-rg -l eastus --sku Standard_LRS
az storage container create --name tfstate --account-name tfstateaccount
```
2. Exportar credenciales Azure (si usas Service Principal):
```bash
export ARM_CLIENT_ID=xxxx
export ARM_CLIENT_SECRET=xxxx
export ARM_TENANT_ID=xxxx
export ARM_SUBSCRIPTION_ID=xxxx
```
3. (Opcional AWS para backup):
```bash
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx
export AWS_REGION=us-east-1
```

## Uso por Ambiente
Dentro de `infra/environments/<env>`:
```bash
cd infra/environments/dev
terraform init
terraform plan -var="region=eastus" -var="prefix_name=ecdev" -var="servers=[\"devops1\",\"devops2\"]" -var="user=adminuser" -var="password=SuperSegura123" -out plan.tfplan
terraform apply plan.tfplan
```
Para stage:
```bash
cd infra/environments/stage
terraform init
terraform plan -var="region=centralus" -var="prefix_name=ecstage" -var="servers=[\"stage1\"]" -var="user=adminuser" -var="password=OtroPass123" -out plan.tfplan
terraform apply plan.tfplan
```
Para prod (ejemplo multi subnet y tamaño distinto):
```bash
cd infra/environments/prod
terraform init
terraform plan -var="region=eastus2" -var="prefix_name=ecprod" -var="servers=[\"prod1\",\"prod2\",\"prod3\"]" -var="user=adminuser" -var="password=ProdPass123!" -out plan.tfplan
terraform apply plan.tfplan
```

## Salidas Clave
- `modules/vm` expone `public_ips` y `vm_ids` (en root legacy o extender outputs en ambientes si se requiere).
- `modules/network` entrega `resource_group_name`, `location`, `subnet_id`.
- `modules/security` entrega `nsg_id` (puedes asociarlo a NICs si extiendes módulo vm).
- `modules/backup` `backup_bucket_name` para verificación cross-cloud.
- `modules/traffic_manager` `traffic_manager_dns_name` para endpoint global.

## Extensiones Sugeridas
- Asociar NSG a NICs: añadir recurso `azurerm_network_interface_security_group_association` en ambientes usando `for_each` sobre NICS del módulo vm.
- Recovery Services Vault: reemplazar el módulo `backup` por configuración real en Azure + replicación geo.
- Private Endpoints y Firewall: agregar módulos para reforzar seguridad en producción.
- Observabilidad: módulo de Log Analytics + Diagnostic Settings para VMs.

## Balanceo Entre Proveedores
La configuración actual crea un perfil de Traffic Manager con endpoints externos. Para balanceo real entre nubes:
1. Aprovisionar un segundo stack (ej. en AWS con ALB / EC2) y obtener su FQDN.
2. Actualizar `primary_fqdn` y `secondary_fqdn` (prod) con los FQDN reales.
3. Cambiar método de enrutamiento a `Performance` o `Priority` según necesidad.

## Estrategia de Respaldo Multi-Cloud
- Actualmente se simula exportando metadatos de VMs a S3.
- Producción real: usar Azure Backup / Snapshot + replicación incremental a segunda región y exportar snapshots periódicos a S3 (requiere tooling adicional).
- Validar integridad: scripts Lambda o funciones Azure que verifiquen objetos.

## Diagrama (Descripción)
```
+----------------------+          +----------------------+
|  Azure RG (env)      |          |    AWS Account       |
|  - VNet/Subnet       |          |  S3 Bucket (backup)  |
|  - NSG (rules)       |          +----------+-----------+
|  - VMs (Linux)       |                     ^
|  - Traffic Manager --+----(DNS Failover)---+
|                      |                     |
|  Storage Account     |<---- remote state-->|
+----------------------+                     |
             ^                                |
             | Terraform Backend              |
             +--------------------------------+
```

## Seguridad
- No commit de credenciales en archivos `.tfvars`.
- Usar `Key Vault` para secretos y referenciar con data sources.
- Limitar puertos de NSG en prod (ej. cerrar Sonar/Locust).
- Habilitar `Just-In-Time` acceso para SSH en producción.

## Limpieza
```bash
terraform destroy -var="region=eastus" -var="prefix_name=ecdev" -var="servers=[\"devops1\",\"devops2\"]" -var="user=adminuser" -var="password=SuperSegura123"
```

## Migración Legacy Root
El archivo `infra/main.tf` existente puede ser deprecado; mover su lógica a ambientes. Mantenerlo sólo para referencia histórica.

## Próximos Pasos
1. Implementar asociación NSG ↔ NIC en ambientes.
2. Añadir módulo de base de datos (Azure Database for MySQL/Postgres) con backups automáticos.
3. Añadir módulo de Container Registry (ACR) y enlazarlo a pipeline CI/CD.
4. Crear pipeline Terraform (GitHub Actions) separado por ambiente con validación y plan PR.
5. Integrar escaneo de seguridad (tfsec / checkov) antes de aplicar.
