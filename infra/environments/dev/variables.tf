variable "region" { type = string }
variable "prefix_name" { type = string }
variable "servers" { type = list(string) }
variable "user" { type = string }
variable "password" { type = string }
variable "vm_size" { type = string default = "Standard_B1ms" }

