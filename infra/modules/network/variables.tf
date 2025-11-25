variable "resource_group_name" {
  type = string
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.10.1.0/24"]
}

variable "address_space" {
  type    = list(string)
  default = ["10.10.0.0/16"]
}

variable "prefix" {
  type = string
}

variable "region" {
  type = string
}

variable "aks_subnet_prefixes" {
  type    = list(string)
  default = []
}
