variable "region" { type = string }
variable "prefix_name" { type = string }
variable "servers" { type = list(string) }
variable "user" { type = string }
variable "password" { type = string }
variable "vm_size" { type = string default = "Standard_B2s" }

variable "aks_subnet_prefixes" {
  type    = list(string)
  default = ["10.20.3.0/24"]
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
