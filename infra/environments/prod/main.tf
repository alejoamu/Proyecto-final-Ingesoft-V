terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }

  backend "local" {
    path = "./terraform.tfstate"
  }
}

module "network" {
  source              = "../../modules/network"
  resource_group_name = "prod-rg"
  region              = var.region
  prefix              = var.prefix_name
  address_space       = ["10.20.0.0/16"]
  subnet_prefixes     = ["10.20.1.0/24", "10.20.2.0/24"]
}

module "security" {
  source              = "../../modules/security"
  prefix              = var.prefix_name
  location            = module.network.location
  resource_group_name = module.network.resource_group_name
  security_rules = concat([
    { name = "SSH", priority = 1001, protocol = "Tcp", port = 22 },
    { name = "HTTPS", priority = 1002, protocol = "Tcp", port = 443 },
    { name = "K8SAPI", priority = 1003, protocol = "Tcp", port = 6443 }
  ])
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
  env          = "prod"
  azure_region = var.region
  vm_names     = var.servers
}

module "traffic_manager" {
  source              = "../../modules/traffic_manager"
  prefix              = var.prefix_name
  env                 = "prod"
  resource_group_name = module.network.resource_group_name
  primary_fqdn        = "primary-prod.example.com"
  secondary_fqdn      = "secondary-prod.example.com"
}
