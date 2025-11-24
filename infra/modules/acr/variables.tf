variable "prefix" {
  type        = string
  description = "Prefijo para los recursos del ACR."
}

variable "resource_group_name" {
  type        = string
  description = "Grupo de recursos donde residirá el ACR."
}

variable "location" {
  type        = string
  description = "Región de despliegue."
}

variable "sku" {
  type        = string
  default     = "Basic"
  description = "SKU del Azure Container Registry."
}

