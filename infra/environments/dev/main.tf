terraform {
  backend "local" {
    path = "./terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = "52aed73f-daaf-4e1b-8cc5-a1975f49cd85"
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "dev-rg"
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

module "traffic_manager" {
  source              = "../../modules/traffic_manager"
  prefix              = var.prefix_name
  env                 = "dev"
  resource_group_name = module.network.resource_group_name
  primary_fqdn        = "primary-dev.example.com"
  secondary_fqdn      = "secondary-dev.example.com"
}
