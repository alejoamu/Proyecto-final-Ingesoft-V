terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "stage.tfstate"
  }
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "stage-rg"
  region              = var.region
  prefix              = var.prefix_name
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

