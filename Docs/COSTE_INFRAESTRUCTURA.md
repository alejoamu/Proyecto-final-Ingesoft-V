# Estimación de Coste de Infraestructura (Azure)
Estos recursos son la base para estimar los costes descritos.

- `infra/modules/traffic_manager/main.tf` → Perfil de Traffic Manager.
- `infra/modules/security/main.tf` → NSG y reglas.
- `infra/modules/network/main.tf` → Resource Group, VNet, Subnet.
  - `azurerm_linux_virtual_machine.vm_devops`
  - `azurerm_network_interface.devops_nic`
  - `azurerm_public_ip.devops_ip`
- `infra/modules/vm/main.tf` → define:
- `infra/environments/dev/main.tf` → orquesta módulos `network`, `security`, `vm`, `traffic_manager`.

## Anexo: componentes Terraform relevantes

---

- Automatizar `terraform destroy` cuando termine una práctica/laboratorio.
- Usar tamaños de VM pequeños (`B1s`, `B1ms`) y discos estándar.
- **Apagar VMs cuando no se usen** (desde el portal o con `az vm deallocate`).
- **Usar un solo entorno `dev`** para la mayor parte de las pruebas.

## Recomendaciones para reducir costes en un entorno académico

---

   - Esta estimación asume 24/7. Si solo usas las VMs, por ejemplo, 8 horas al día durante 20 días/mes (laboral), el coste efectivo se reduce aproximadamente a ~1/3.
4. **Uso horario**:

   - Algunas regiones son ligeramente más caras o baratas; revisa siempre el calculador de precios de Azure para afinar.
3. **Región (`region`)**:

   - Si cambias a tamaños mayores (por ejemplo `Standard_B2s`, `D-series`, etc.), multiplica el coste por el ratio de precio de la nueva SKU.
2. **Tamaño de VM (`vm_size`)**:

   - ~ 2.5 USD/mes de IP pública.
   - ~ 3 USD/mes de disco.
   - ~ 14.5 USD/mes de cómputo.
1. **Número de VMs (`servers`)**: cada VM extra añade aproximadamente:

## Cómo recalcular el coste si cambias la config

---

> De nuevo, esto es un cálculo orientativo, sin descuentos ni créditos educativos. En un contexto académico es frecuente levantar solo `dev` (o apagar VMs cuando no se usan) para reducir el coste efectivo.

| **Total** | **~ 126 USD/mes**      |
| prod    | ~ 62                    |
| stage   | ~ 22                    |
| dev     | ~ 42                    |
|---------|-------------------------|
| Entorno | Coste aprox. (USD/mes) |

## Coste total estimado (dev + stage + prod)

---

**Total prod aprox.: ~ 62 USD/mes**

- Traffic Manager + network + storage: ~ 2 USD/mes
- IPs: 3 × 2.5 ≈ 7.5 USD/mes
- Discos: 3 × 3 ≈ 9 USD/mes
- VMs: 3 × 14.5 ≈ 43.5 USD/mes

Si `prod` usa 3 VMs (`servers = ["prod1","prod2","prod3"]`):

### Prod

**Total stage aprox.: ~ 22 USD/mes**

- Traffic Manager + network + storage: ~ 2 USD/mes
- IP: ~ 2.5 USD/mes
- Disco: ~ 3 USD/mes
- VMs: ~ 14.5 USD/mes

Si `stage` usa 1 sola VM (`servers = ["stage1"]`):

### Stage

## Escalado a otros entornos

---

> Redondeando, podemos considerar **~ 40–45 USD/mes** para un entorno dev típico con 2 VMs corriendo 24/7.

| **Total estimado entorno dev**         |          | **~ 42 USD/mes**        |
| VNet, Subnet, NSG, RG, Storage (state) | 1 set    | ~ 1                     |
| Traffic Manager                        | 1        | ~ 1                     |
| Public IPs estáticas `Standard`        | 2        | ~ 5                     |
| Discos OS `Standard_LRS`               | 2        | ~ 6                     |
| VMs `Standard_B1ms`                    | 2        | ~ 29                    |
|----------------------------------------|----------|-------------------------|
| Componente                              | Cantidad | Coste aprox. (USD/mes) |

## Resumen de coste estimado (entorno dev con 2 VMs)

---

> Coste estimado: << **1 USD/mes** (despreciable comparado con VMs).

- Contenedor `tfstate` con uno o pocos blobs.
- Storage account `Standard_LRS` con pocos GB para estado remoto.

### 6. Almacenamiento de estado Terraform (Azure Storage)

  - Precio aproximado: muy bajo, ~ **1 USD/mes** para uso académico.
- Perfil de Traffic Manager con pocos endpoints y tráfico bajo:

### 5. Azure Traffic Manager

- 2 × 2.5 ≈ **5 USD/mes**

Para **2 IPs**:

- Precio aproximado IP pública estática estándar: ~ **0.0035 USD/hora** → ~ **2.5 USD/mes** por IP.

Cada VM tiene una IP pública estática `Standard` (`azurerm_public_ip`).

### 4. Public IPs (`Standard`)

- 2 × 3 ≈ **6 USD/mes**

Para **2 discos**:

- Precio aproximado `Standard HDD` 64 GiB: ~ **3 USD/mes** por disco.

Cada VM tiene 1 disco OS estándar (`Standard_LRS`), tamaño por defecto ~ 64 GiB.

### 3. Discos OS (Standard HDD `Standard_LRS`)

Incluye solo el cómputo; el almacenamiento del disco OS se estima aparte.

- 2 × 14.5 ≈ **29 USD/mes**

Para **2 VMs**:

  - ~ **0.02 USD/hora** → ~ **14.5 USD/mes** por VM (asumiendo 730 h/mes).
- Precio aproximado en `eastus`:
- Tipo: `Standard_B1ms` (1 vCPU, 2 GiB RAM) – serie B (burstable).

### 2. Máquinas Virtuales Linux `Standard_B1ms`

> **Estimación:** ~ 0 USD/mes (ignoramos tráfico saliente para simplificar).

- **NSG**: sin coste directo.
- **Virtual Network + Subnet**: coste prácticamente nulo para uso estándar (el coste principal viene del tráfico de datos, no estimado aquí).
- **Resource Group**: sin coste directo.

### 1. Resource Group, VNet, Subnet y NSG

## Componentes y costes estimados (por entorno dev)

---

> Fuente de precios: portal de Azure (referencia 2025), aproximados en USD.

- `servers = ["devops1","devops2"]` → **2 VMs**.
- Región: `mexicocentral`.

A continuación se estima el coste mensual aproximado para un entorno típico **dev** con:

- 1 perfil de Azure Traffic Manager con 2 endpoints externos simulados.
- 1 Public IP + 1 NIC por VM.
- N Máquinas Virtuales Linux (Ubuntu 20.04) tamaño `Standard_B1ms` (por defecto), una por nombre en `servers`.
- 1 Network Security Group (NSG) con reglas básicas.
- 1 Virtual Network + 1 Subnet.
- 1 Resource Group.

La infraestructura gestionada por Terraform en este proyecto (carpeta `infra/`) despliega, por entorno (`dev`, `stage`, `prod`):

## Alcance

> Nota: Este documento es **estimado** y orientativo para fines académicos. Los precios reales dependen de la suscripción, región, descuentos (student/credits) y fecha.

Para los ejemplos de comandos Terraform en los distintos entornos, asume región `mexicocentral` en lugar de `eastus` (los precios de referencia son similares y el cálculo sigue siendo orientativo).
