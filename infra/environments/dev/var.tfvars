# Variables por defecto para el entorno dev. Ajusta según necesidad local.
region      = "mexicocentral"
prefix_name = "ecdev"
servers     = ["ci"]
user        = "adminuser"
password    = "Password@1"
vm_size     = "Standard_B1ms"

aks_subnet_prefixes = ["10.10.2.0/24"]
acr_sku             = "Basic"
aks_dns_prefix      = "ecdev-aks"
aks_node_count      = 1
aks_vm_size         = "Standard_B2s"
