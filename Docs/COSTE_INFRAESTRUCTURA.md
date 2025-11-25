# Estimación de Coste de Infraestructura (Azure) - Actualizado 2025

Este documento estima los costos de la infraestructura completa del proyecto, incluyendo:
- **VM de CI/DevOps**: Con herramientas de calidad, monitoreo y pruebas
- **Azure Kubernetes Service (AKS)**: Cluster para despliegue de microservicios
- **Azure Container Registry (ACR)**: Registro de imágenes Docker
- **Infraestructura de red**: VNet, subnets, NSG, IPs públicas

## Arquitectura Actual

### VM de CI/DevOps
La VM de CI ejecuta los siguientes servicios en contenedores Docker:
- **Calidad de código**: SonarQube + PostgreSQL
- **Pruebas de carga**: Locust (master + worker)
- **Seguridad**: Trivy
- **Monitoreo**: Prometheus, Grafana, Alertmanager
- **Logs**: Elasticsearch, Filebeat
- **Proxy reverso**: Nginx

### Azure Kubernetes Service (AKS)
- Cluster AKS con nodos para ejecutar microservicios
- Configuración por defecto: `Standard_B2s` (2 vCPU, 4GB RAM)
- Load Balancer estándar

### Azure Container Registry (ACR)
- Registro privado para imágenes Docker
- SKU: Basic

## Componentes Terraform

- `infra/modules/traffic_manager/main.tf` → Perfil de Traffic Manager
- `infra/modules/security/main.tf` → NSG y reglas
- `infra/modules/network/main.tf` → Resource Group, VNet, Subnet
- `infra/modules/vm/main.tf` → VMs Linux
- `infra/modules/aks/main.tf` → Cluster AKS
- `infra/modules/acr/main.tf` → Azure Container Registry
- `infra/environments/dev/main.tf` → Orquesta todos los módulos

## Recomendaciones para reducir costes en un entorno académico

1. **Apagar recursos cuando no se usen**: 
   - VMs: `az vm deallocate --name <vm-name> --resource-group <rg>`
   - AKS: Escalar a 0 nodos o eliminar temporalmente
   
2. **Usar tamaños mínimos**:
   - VM CI: `Standard_B2ms` (mínimo recomendado para todos los servicios)
   - AKS: `Standard_B2s` (1 nodo para desarrollo)

3. **Uso horario**: 
   - Si solo usas 8 horas/día × 20 días/mes, el coste efectivo se reduce a ~1/3

4. **Región**: 
   - `mexicocentral` tiene precios similares a `eastus`
   - Algunas regiones pueden ser ligeramente más económicas

5. **Automation**: 
   - Automatizar `terraform destroy` al finalizar prácticas
   - Usar principalmente el entorno `dev`

## Cómo recalcular el coste si cambias la config

1. **Número de VMs**: cada VM extra añade ~20 USD/mes (B2ms) o ~14.5 USD/mes (B1ms)
2. **Tamaño de VM**: multiplica por el ratio de precio de la nueva SKU
3. **Nodos AKS**: cada nodo B2s añade ~30 USD/mes
4. **Región**: revisa el calculador de precios de Azure

## Coste Total Estimado por Entorno

### Entorno Dev (Recomendado para desarrollo)

| Componente | Cantidad | Especificación | Coste aprox. (USD/mes) |
|------------|----------|----------------|-------------------------|
| **VM CI/DevOps** | 1 | Standard_B2ms (2 vCPU, 8GB RAM) | ~ 20 |
| **Disco OS VM CI** | 1 | Standard_LRS 128GB | ~ 6 |
| **IP Pública VM CI** | 1 | Standard | ~ 2.5 |
| **AKS Cluster** | 1 | Control plane (gratis primeros 5 nodos) | ~ 0 |
| **Nodos AKS** | 1 | Standard_B2s (2 vCPU, 4GB RAM) | ~ 30 |
| **ACR Basic** | 1 | 10GB incluidos | ~ 5 |
| **Load Balancer AKS** | 1 | Standard (5 reglas básicas) | ~ 18 |
| **Almacenamiento AKS** | ~50GB | Managed Disks Premium | ~ 7 |
| **VNet, Subnet, NSG** | 1 set | Networking básico | ~ 1 |
| **Traffic Manager** | 1 | Perfil básico | ~ 1 |
| **Storage Terraform** | 1 | State remoto | ~ 1 |
| **TOTAL DEV** | | | **~ 91 USD/mes** |

**Nota**: La VM CI requiere `Standard_B2ms` (8GB RAM) debido a los múltiples servicios:
- SonarQube: ~2GB RAM
- Elasticsearch: ~512MB-1GB RAM
- Prometheus: ~500MB RAM
- Grafana: ~200MB RAM
- PostgreSQL: ~200MB RAM
- Otros servicios: ~1GB RAM
- Sistema operativo: ~1GB RAM

### Entorno Stage

| Componente | Cantidad | Especificación | Coste aprox. (USD/mes) |
|------------|----------|----------------|-------------------------|
| VM CI/DevOps | 1 | Standard_B2ms | ~ 20 |
| Disco OS | 1 | Standard_LRS 128GB | ~ 6 |
| IP Pública | 1 | Standard | ~ 2.5 |
| AKS Cluster | 1 | Control plane | ~ 0 |
| Nodos AKS | 1 | Standard_B2s | ~ 30 |
| ACR Basic | 1 | 10GB | ~ 5 |
| Load Balancer | 1 | Standard | ~ 18 |
| Almacenamiento | ~50GB | Managed Disks | ~ 7 |
| Networking | 1 set | VNet, Subnet, NSG | ~ 1 |
| Traffic Manager | 1 | Perfil básico | ~ 1 |
| Storage Terraform | 1 | State remoto | ~ 1 |
| **TOTAL STAGE** | | | **~ 91 USD/mes** |

### Entorno Prod

| Componente | Cantidad | Especificación | Coste aprox. (USD/mes) |
|------------|----------|----------------|-------------------------|
| VM CI/DevOps | 1 | Standard_B2ms | ~ 20 |
| Disco OS | 1 | Standard_LRS 128GB | ~ 6 |
| IP Pública | 1 | Standard | ~ 2.5 |
| AKS Cluster | 1 | Control plane | ~ 0 |
| Nodos AKS | 3 | Standard_B2s (alta disponibilidad) | ~ 90 |
| ACR Basic | 1 | 10GB | ~ 5 |
| Load Balancer | 1 | Standard | ~ 18 |
| Almacenamiento | ~150GB | Managed Disks Premium | ~ 21 |
| Networking | 1 set | VNet, Subnet, NSG | ~ 1 |
| Traffic Manager | 1 | Perfil básico | ~ 1 |
| Storage Terraform | 1 | State remoto | ~ 1 |
| **TOTAL PROD** | | | **~ 168 USD/mes** |

## Coste Total Estimado (Dev + Stage + Prod)

| Entorno | Coste aprox. (USD/mes) |
|---------|-------------------------|
| dev     | ~ 91                    |
| stage   | ~ 91                    |
| prod    | ~ 168                   |
| **Total** | **~ 350 USD/mes**      |

> **Nota importante**: Estos costos asumen 24/7. Si apagas recursos cuando no se usan o solo usas 8 horas/día, el coste efectivo puede reducirse a ~1/3 (~117 USD/mes total).

## Desglose Detallado de Componentes

### 1. Resource Group, VNet, Subnet y NSG

- **Resource Group**: sin coste directo
- **Virtual Network + Subnet**: coste prácticamente nulo para uso estándar
- **NSG**: sin coste directo
- **Estimación**: ~ 1 USD/mes (costos indirectos mínimos)

### 2. Máquinas Virtuales Linux

#### VM CI/DevOps: `Standard_B2ms`
- **Especificaciones**: 2 vCPU, 8 GiB RAM
- **Precio aproximado**: ~ **0.027 USD/hora** → ~ **20 USD/mes** (730 h/mes)
- **Justificación**: Requiere más RAM para ejecutar todos los servicios de CI/CD, monitoreo y logging

#### VM CI/DevOps: `Standard_B1ms` (mínimo, no recomendado)
- **Especificaciones**: 1 vCPU, 2 GiB RAM
- **Precio aproximado**: ~ **0.02 USD/hora** → ~ **14.5 USD/mes**
- **Nota**: Puede ser insuficiente para todos los servicios simultáneos

### 3. Discos OS (Standard HDD `Standard_LRS`)

- **VM CI**: 128GB recomendado (para volúmenes Docker)
  - Precio: ~ **6 USD/mes** por disco
- **VM CI mínima**: 64GB
  - Precio: ~ **3 USD/mes** por disco

### 4. Public IPs (`Standard`)

- Precio aproximado: ~ **0.0035 USD/hora** → ~ **2.5 USD/mes** por IP
- Cada VM necesita 1 IP pública

### 5. Azure Traffic Manager

- Perfil de Traffic Manager con pocos endpoints y tráfico bajo
- Precio aproximado: ~ **1 USD/mes** para uso académico

### 6. Almacenamiento de Estado Terraform (Azure Storage)

- Storage account `Standard_LRS` con pocos GB para estado remoto
- Contenedor `tfstate` con uno o pocos blobs
- Coste estimado: << **1 USD/mes** (despreciable)

### 7. Azure Kubernetes Service (AKS)

#### Control Plane (Gratis)
- Los primeros 5 nodos del control plane son **gratis**
- Coste: **0 USD/mes** para clusters pequeños

#### Nodos del Pool (`Standard_B2s`)
- **Especificaciones**: 2 vCPU, 4 GiB RAM por nodo
- **Precio aproximado**: ~ **0.041 USD/hora** → ~ **30 USD/mes** por nodo
- **Recomendación**:
  - Dev/Stage: 1 nodo
  - Prod: 3 nodos (alta disponibilidad)

#### Load Balancer Estándar
- **Precio base**: ~ **0.025 USD/hora** → ~ **18 USD/mes**
- **Reglas adicionales**: ~ 0.01 USD/hora por regla (primeras 5 incluidas)
- **Tráfico procesado**: ~ 0.005 USD/GB (puede variar)

#### Almacenamiento AKS (Managed Disks)
- **Premium SSD**: ~ **0.15 USD/GB/mes**
- **Estimación**:
  - Dev/Stage: ~50GB → ~ **7 USD/mes**
  - Prod: ~150GB → ~ **21 USD/mes**

### 8. Azure Container Registry (ACR)

#### SKU Basic
- **Precio**: ~ **5 USD/mes**
- **Incluye**: 10GB de almacenamiento
- **Almacenamiento adicional**: ~ 0.167 USD/GB/mes
- **Nota**: Suficiente para desarrollo y pruebas

#### SKU Standard (opcional para producción)
- **Precio**: ~ **25 USD/mes**
- **Incluye**: 100GB de almacenamiento
- **Características adicionales**: Geo-replicación, webhooks

### 9. Volúmenes Docker en VM CI

Los servicios en la VM CI crean volúmenes Docker que ocupan espacio:
- **SonarQube**: ~5-10GB (datos, extensiones)
- **PostgreSQL**: ~2-5GB (datos de SonarQube)
- **Prometheus**: ~5-10GB (métricas, 30 días retención)
- **Grafana**: ~500MB (dashboards, config)
- **Elasticsearch**: ~5-10GB (índices de logs)
- **Filebeat**: ~1GB (datos de estado)
- **Total estimado**: ~20-40GB adicionales

**Recomendación**: Disco OS de 128GB para la VM CI

## Comparación: Arquitectura Anterior vs Actual

### Arquitectura Anterior (Solo VMs)
- 2 VMs `Standard_B1ms`: ~29 USD/mes
- Discos: ~6 USD/mes
- IPs: ~5 USD/mes
- **Total**: ~42 USD/mes (dev)

### Arquitectura Actual (VM CI + AKS)
- 1 VM CI `Standard_B2ms`: ~20 USD/mes
- 1 Nodo AKS `Standard_B2s`: ~30 USD/mes
- ACR: ~5 USD/mes
- Load Balancer: ~18 USD/mes
- Almacenamiento adicional: ~7 USD/mes
- **Total**: ~91 USD/mes (dev)

**Incremento**: ~49 USD/mes adicionales por las capacidades de Kubernetes y monitoreo completo

## Optimizaciones de Costo

### Para Desarrollo/Pruebas
1. **Usar solo entorno Dev**: ~91 USD/mes
2. **Apagar AKS cuando no se use**: Ahorro de ~30 USD/mes
3. **Reducir retención de Prometheus**: De 30 a 7 días → Ahorro de ~2 USD/mes
4. **Usar ACR Basic**: Suficiente para desarrollo

### Para Producción
1. **Reserved Instances**: Hasta 72% de descuento en VMs y nodos AKS
2. **Spot Instances AKS**: Hasta 90% de descuento (para workloads no críticos)
3. **Auto-scaling**: Escalar a 0 nodos en horarios de bajo uso
4. **Storage optimization**: Usar discos estándar donde sea posible

## Resumen Ejecutivo

| Escenario | Coste Mensual (USD) | Uso Recomendado |
|-----------|---------------------|-----------------|
| **Dev completo** | ~91 | Desarrollo activo |
| **Dev mínimo** (AKS apagado) | ~61 | Desarrollo sin K8s |
| **Stage completo** | ~91 | Pre-producción |
| **Prod completo** | ~168 | Producción |
| **Todos los entornos** | ~350 | Multi-ambiente completo |

> **Nota final**: Estos costos son estimaciones orientativas. Los precios reales dependen de:
> - Suscripción (descuentos educativos, créditos)
> - Región seleccionada
> - Uso real de recursos
> - Descuentos por compromiso (Reserved Instances)
> - Fecha de consulta (precios pueden variar)

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
