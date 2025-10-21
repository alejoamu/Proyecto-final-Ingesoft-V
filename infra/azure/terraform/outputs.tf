output "resource_group" {
  value       = azurerm_resource_group.rg.name
  description = "Nombre del Resource Group"
}

output "vm_app_public_ip" {
  value       = azurerm_public_ip.app_pip.ip_address
  description = "IP pública de la VM App (microservicios)"
}

output "vm_ci_public_ip" {
  value       = azurerm_public_ip.ci_pip.ip_address
  description = "IP pública de la VM CI (k3s + Helm)"
}

