output "public_ips" {
  description = "IP públicas por servidor"
  value = { for k, v in azurerm_public_ip.devops_ip : k => v.ip_address }
}

output "vm_ids" {
  description = "IDs de las VMs por servidor"
  value = { for k, v in azurerm_linux_virtual_machine.vm_devops : k => v.id }
}