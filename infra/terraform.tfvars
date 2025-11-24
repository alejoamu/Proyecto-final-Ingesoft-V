# terraform.tfvars.example
# Copy this file to terraform.tfvars and fill in the values
# DO NOT commit terraform.tfvars to the repository

region = "Mexico Central"
user = "adminuser"
# password should be set via environment variable or terraform.tfvars (not committed)
# export TF_VAR_password="your_password"
password = "Password@1" # Set via environment variable TF_VAR_password
prefix_name = "devops"
servers = ["CI", "Code"]