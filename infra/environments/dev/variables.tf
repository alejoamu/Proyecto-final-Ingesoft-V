variable "region" { type = string }
variable "prefix_name" { type = string }
variable "servers" { type = list(string) }
variable "user" { type = string }
variable "password" { type = string }
variable "vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "aks_subnet_prefixes" {
  type    = list(string)
  default = ["10.10.2.0/24"]
}

variable "acr_sku" {
  type    = string
  default = "Basic"
}

variable "aks_dns_prefix" {
  type    = string
  default = null
}

variable "aks_node_count" {
  type    = number
  default = 1
}

variable "aks_vm_size" {
  type    = string
  default = "Standard_B2s"
}
