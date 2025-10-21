locals {
  rg_name        = "${var.prefix}-rg"
  vnet_name      = "${var.prefix}-vnet"
  subnet_name    = "${var.prefix}-subnet"
  nsg_name       = "${var.prefix}-nsg"
  app_vm_name    = "${var.prefix}-app-vm"
  ci_vm_name     = "${var.prefix}-ci-vm"
  # Nuevos: manejo opcional de password y ssh key
  admin_password_effective = length(trimspace(var.admin_password)) > 0 ? var.admin_password : null
  ssh_public_key_effective = length(trimspace(var.ssh_public_key)) > 0 ? var.ssh_public_key : null
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
  tags = {
    project = var.prefix
    env     = "dev"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = local.vnet_name
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = local.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = local.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  # Puertos App VM (API Gateway 8080, Eureka 8761, Config 9296, Zipkin 9411)
  security_rule {
    name                       = "Allow-App-8080"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App-8761"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8761"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App-9296"
    priority                   = 112
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9296"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-App-9411"
    priority                   = 113
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9411"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  # Puertos CI VM (NodePorts Jenkins 32080, SonarQube 32000)
  security_rule {
    name                       = "Allow-CI-32080"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "32080"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-CI-32000"
    priority                   = 121
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "32000"
    source_address_prefix      = var.allowed_source_ip
    destination_address_prefix = "*"
  }
}

# IPs Públicas
resource "azurerm_public_ip" "app_pip" {
  name                = "${var.prefix}-app-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "ci_pip" {
  name                = "${var.prefix}-ci-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NICs
resource "azurerm_network_interface" "app_nic" {
  name                = "${var.prefix}-app-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "app_nic_nsg" {
  network_interface_id      = azurerm_network_interface.app_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface" "ci_nic" {
  name                = "${var.prefix}-ci-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ci_pip.id
  }
}

resource "azurerm_network_interface_security_group_association" "ci_nic_nsg" {
  network_interface_id      = azurerm_network_interface.ci_nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Imágenes Ubuntu 22.04
data "azurerm_platform_image" "ubuntu2204" {
  location  = azurerm_resource_group.rg.location
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts"
}

# VM App (microservicios)
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                = local.app_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.app_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.app_nic.id
  ]

  # Habilitar password opcionalmente
  disable_password_authentication = local.admin_password_effective == null
  admin_password                  = local.admin_password_effective

  # SSH key solo si se proporciono
  dynamic "admin_ssh_key" {
    for_each = local.ssh_public_key_effective == null ? [] : [1]
    content {
      username   = var.admin_username
      public_key = local.ssh_public_key_effective
    }
  }

  os_disk {
    name                 = "${var.prefix}-app-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu2204.publisher
    offer     = data.azurerm_platform_image.ubuntu2204.offer
    sku       = data.azurerm_platform_image.ubuntu2204.sku
    version   = data.azurerm_platform_image.ubuntu2204.version
  }

  computer_name  = "appvm"

  custom_data = base64encode(file("${path.module}/cloud-init-app.yaml"))

  tags = {
    role = "app"
  }
}

# VM CI (k3s + Helm + Jenkins + SonarQube + Trivy)
resource "azurerm_linux_virtual_machine" "ci_vm" {
  name                = local.ci_vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.ci_vm_size
  admin_username      = var.admin_username
  network_interface_ids = [
    azurerm_network_interface.ci_nic.id
  ]

  disable_password_authentication = local.admin_password_effective == null
  admin_password                  = local.admin_password_effective

  dynamic "admin_ssh_key" {
    for_each = local.ssh_public_key_effective == null ? [] : [1]
    content {
      username   = var.admin_username
      public_key = local.ssh_public_key_effective
    }
  }

  os_disk {
    name                 = "${var.prefix}-ci-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = data.azurerm_platform_image.ubuntu2204.publisher
    offer     = data.azurerm_platform_image.ubuntu2204.offer
    sku       = data.azurerm_platform_image.ubuntu2204.sku
    version   = data.azurerm_platform_image.ubuntu2204.version
  }

  computer_name  = "civm"

  custom_data = base64encode(file("${path.module}/cloud-init-ci.yaml"))

  tags = {
    role = "ci"
  }
}
