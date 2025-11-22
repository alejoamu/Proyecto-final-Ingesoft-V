# Azure Traffic Manager profile for multi-region load balancing
resource "azurerm_traffic_manager_profile" "tm" {
  name                = "${var.prefix}-tm-${var.env}"
  resource_group_name = var.resource_group_name
  location            = "global"
  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "${var.prefix}-tm-${var.env}"
    ttl           = 30
  }
  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
  tags = { Environment = var.env }
}

resource "azurerm_traffic_manager_endpoint" "primary" {
  name               = "primary-endpoint"
  profile_name       = azurerm_traffic_manager_profile.tm.name
  resource_group_name= var.resource_group_name
  type               = "externalEndpoints"
  target             = var.primary_fqdn
  priority           = 1
}

resource "azurerm_traffic_manager_endpoint" "secondary" {
  name               = "secondary-endpoint"
  profile_name       = azurerm_traffic_manager_profile.tm.name
  resource_group_name= var.resource_group_name
  type               = "externalEndpoints"
  target             = var.secondary_fqdn
  priority           = 2
}

output "traffic_manager_dns_name" { value = azurerm_traffic_manager_profile.tm.dns_config[0].fqdn }

