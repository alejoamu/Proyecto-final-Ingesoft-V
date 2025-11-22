variable "prefix" { type = string }
variable "env" { type = string }
variable "azure_region" { type = string }
variable "vm_names" { type = list(string) }
variable "aws_region" { type = string default = "us-east-1" }

