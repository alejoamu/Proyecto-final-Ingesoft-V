output "public_ips" {
  value = module.vm.public_ips
}

output "vm_ids" {
  description = "IDs de las VMs por servidor"
  value       = module.vm.vm_ids
}
