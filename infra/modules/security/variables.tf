variable "prefix" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }

variable "security_rules" {
  description = "Lista de reglas de seguridad"
  type = list(object({
    name     = string
    priority = number
    protocol = string
    port     = number
  }))
  default = [
    { name = "SSH", priority = 1001, protocol = "Tcp", port = 22 },
    { name = "HTTP", priority = 1002, protocol = "Tcp", port = 80 },
    { name = "HTTPS", priority = 1003, protocol = "Tcp", port = 443 },
    { name = "SONAR", priority = 1004, protocol = "Tcp", port = 9000 },
    { name = "LOCUST", priority = 1005, protocol = "Tcp", port = 8089 },
    { name = "K8SAPI", priority = 1006, protocol = "Tcp", port = 6443 }
  ]
}

