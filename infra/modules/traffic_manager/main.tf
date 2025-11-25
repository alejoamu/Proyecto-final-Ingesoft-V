# Azure Traffic Manager profile for multi-region/load balancing
resource "azurerm_traffic_manager_profile" "tm" {
  name                = "${var.prefix}-tm-${var.env}"
  resource_group_name = var.resource_group_name
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

  tags = {
    Environment = var.env
  }
}

# Endpoints externos simulados (por FQDN)
resource "azurerm_traffic_manager_external_endpoint" "primary" {
  name              = "primary-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm.id
  endpoint_location = var.endpoint_location
  target            = var.primary_fqdn
  priority          = 1
}

resource "azurerm_traffic_manager_external_endpoint" "secondary" {
  name              = "secondary-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm.id
  endpoint_location = var.endpoint_location
  target            = var.secondary_fqdn
  priority          = 2
}

output "traffic_manager_profile_id" {
  value = azurerm_traffic_manager_profile.tm.id
}
