terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "stage-rg"
  region              = var.region
  prefix              = var.prefix_name
  aks_subnet_prefixes = var.aks_subnet_prefixes
}

module "security" {
  source              = "../../modules/security"
  prefix              = var.prefix_name
  location            = module.network.location
  resource_group_name = module.network.resource_group_name
}

module "vm" {
  source              = "../../modules/vm"
  servers             = var.servers
  size_servers        = var.vm_size
  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  subnet_id           = module.network.subnet_id
  prefix_name         = var.prefix_name
  user                = var.user
  password            = var.password
}

module "backup" {
  source       = "../../modules/backup"
  prefix       = var.prefix_name
  env          = "stage"
  azure_region = var.region
  vm_names     = var.servers
}

module "traffic_manager" {
  source              = "../../modules/traffic_manager"
  prefix              = var.prefix_name
  env                 = "stage"
  resource_group_name = module.network.resource_group_name
  primary_fqdn        = "primary-stage.example.com"
  secondary_fqdn      = "secondary-stage.example.com"
}

module "acr" {
  source              = "../../modules/acr"
  prefix              = var.prefix_name
  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  sku                 = var.acr_sku
}

module "aks" {
  source              = "../../modules/aks"
  prefix              = var.prefix_name
  resource_group_name = module.network.resource_group_name
  location            = module.network.location
  dns_prefix          = coalesce(var.aks_dns_prefix, "${var.prefix_name}-aks")
  aks_subnet_id       = module.network.aks_subnet_id
  node_count          = var.aks_node_count
  vm_size             = var.aks_vm_size
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.acr.id
  role_definition_name = "AcrPull"
  principal_id         = module.aks.kubelet_identity_object_id
}
