# Variables por defecto para el entorno stage.
region      = "mexicocentral"
prefix_name = "ecstage"
servers     = ["ci"]
user        = "adminuser"
password    = "Password@1"
vm_size     = "Standard_B1ms"

aks_subnet_prefixes = ["10.11.2.0/24"]
acr_sku             = "Basic"
aks_dns_prefix      = "ecstage-aks"
aks_node_count      = 1
aks_vm_size         = "Standard_B2s"

