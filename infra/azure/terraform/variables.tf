variable "prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "ecom-ms"
}

variable "location" {
  description = "Región de Azure"
  type        = string
  default     = "eastus"
}

variable "admin_username" {
  description = "Usuario administrador para las VMs"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Contraseña del usuario administrador para las VMs (menos seguro que SSH keys). Si se establece, se habilita el login por contraseña."
  type        = string
  default     = "P@ssword1-2025!"
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Contenido de la llave pública SSH para acceder a las VMs"
  type        = string
  default     = ""
  sensitive   = true
}

variable "allowed_source_ip" {
  description = "IP/CIDR permitido para acceder a los puertos publicados (por ejemplo, 1.2.3.4/32)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "app_vm_size" {
  description = "Tamaño de la VM para microservicios"
  type        = string
  default     = "Standard_B2s"
}

variable "ci_vm_size" {
  description = "Tamaño de la VM para k3s + Jenkins + SonarQube"
  type        = string
  default     = "Standard_B4ms"
}
