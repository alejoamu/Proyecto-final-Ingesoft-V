terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "backend_resource_group_name" {
  type        = string
  description = "Nombre del resource group que almacenará el Storage Account para el backend de Terraform"
  default     = "tfstate-rg"
}

variable "backend_storage_account_name" {
  type        = string
  description = "Nombre del Storage Account para el backend de Terraform (debe ser único en Azure)."
  default     = "tfstateaccount"
}

variable "backend_container_name" {
  type        = string
  description = "Nombre del contenedor de blobs para los archivos .tfstate."
  default     = "tfstate"
}

variable "backend_location" {
  type        = string
  description = "Región Azure donde se creará el backend (p.ej. mexicocentral)."
  default     = "mexicocentral"
}

resource "azurerm_resource_group" "backend" {
  name     = var.backend_resource_group_name
  location = var.backend_location
}

resource "azurerm_storage_account" "backend" {
  name                     = var.backend_storage_account_name
  resource_group_name      = azurerm_resource_group.backend.name
  location                 = azurerm_resource_group.backend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "backend" {
  name                  = var.backend_container_name
  storage_account_name  = azurerm_storage_account.backend.name
  container_access_type = "private"
}

