variable "prefix" { type = string }
variable "env" { type = string }
variable "resource_group_name" { type = string }
variable "primary_fqdn" { type = string }
variable "secondary_fqdn" { type = string }

variable "endpoint_location" {
  type        = string
  description = "Ubicación Azure para los endpoints de Traffic Manager (debe ser una región válida)."
  default     = "mexicocentral"
}
