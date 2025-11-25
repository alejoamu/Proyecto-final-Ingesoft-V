variable "prefix" {
  type        = string
  description = "Prefijo común para nombres de recursos."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group donde se desplegará AKS."
}

variable "location" {
  type        = string
  description = "Región de Azure para el cluster."
}

variable "dns_prefix" {
  type        = string
  description = "Prefijo DNS único para el API server."
}

variable "aks_subnet_id" {
  type        = string
  description = "ID de la subred donde residirán los nodos AKS."
}

variable "node_count" {
  type        = number
  default     = 1
  description = "Cantidad de nodos en el pool default."
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "SKU de los nodos del pool default."
}
