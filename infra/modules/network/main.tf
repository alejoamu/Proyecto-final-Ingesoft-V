resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_prefixes
}

resource "azurerm_subnet" "aks" {
  count                = length(var.aks_subnet_prefixes) > 0 ? 1 : 0
  name                 = "${var.prefix}-aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.aks_subnet_prefixes
}

output "resource_group_name" { value = azurerm_resource_group.rg.name }
output "location" { value = azurerm_resource_group.rg.location }
output "subnet_id" { value = azurerm_subnet.subnet.id }
output "aks_subnet_id" {
  value       = try(azurerm_subnet.aks[0].id, null)
  description = "ID de la subred reservada para AKS (null si no se definió)."
}
