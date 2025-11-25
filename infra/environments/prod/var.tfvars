# Variables por defecto para el entorno prod.
region      = "mexicocentral"
prefix_name = "ecprod"
servers     = ["ci"]
user        = "adminuser"
password    = "Password@1"
vm_size     = "Standard_B2s"

aks_subnet_prefixes = ["10.20.3.0/24"]
acr_sku             = "Basic"
aks_dns_prefix      = "ecprod-aks"
aks_node_count      = 1
aks_vm_size         = "Standard_B2s"
