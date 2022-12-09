# Create a Resource Group if it doesn’t exist
resource "azurerm_resource_group" "labbrazil" {
  name     = "My-Lab-Brazil"
  location = "Brazil South"
}

# Create a Virtual Network
resource "azurerm_virtual_network" "labbrazil" {
  name                = "lab-brazil-vnet"
  location            = azurerm_resource_group.labbrazil.location
  resource_group_name = azurerm_resource_group.labbrazil.name
  address_space       = ["10.0.0.0/16"]

  tags = {
    environment = "lab-brazil-env"
  }
}

# Create a Subnet in the Virtual Network
resource "azurerm_subnet" "labbrazil" {
  name                 = "lab-brazil-subnet"
  resource_group_name  = azurerm_resource_group.labbrazil.name
  virtual_network_name = azurerm_virtual_network.labbrazil.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Public IP
resource "azurerm_public_ip" "labbrazil" {
  name                = "lab-brazil-public-ip"
  location            = azurerm_resource_group.labbrazil.location
  resource_group_name = azurerm_resource_group.labbrazil.name
  allocation_method   = "Static"

  tags = {
    environment = "lab-brazil-env"
  }
}

# Create a Network Security Group and rule
resource "azurerm_network_security_group" "labbrazil" {
  name                = "lab-brazil-nsg"
  location            = azurerm_resource_group.labbrazil.location
  resource_group_name = azurerm_resource_group.labbrazil.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "lab-brazil-env"
  }
}

# Create a Network Interface
resource "azurerm_network_interface" "labbrazil" {
  name                = "lab-brazil"
  location            = azurerm_resource_group.labbrazil.location
  resource_group_name = azurerm_resource_group.labbrazil.name

  ip_configuration {
    name                          = "lab-brazil-nic-ip-config"
    subnet_id                     = azurerm_subnet.labbrazil.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.labbrazil.id
  }

  tags = {
    environment = "lab-brazil-env"
  }
}

# Create a Network Interface Security Group association
resource "azurerm_network_interface_security_group_association" "tfexample" {
  network_interface_id      = azurerm_network_interface.labbrazil.id
  network_security_group_id = azurerm_network_security_group.labbrazil.id
}

# Create a Virtual Machine
resource "azurerm_linux_virtual_machine" "labbrazil" {
  name                            = "LAB-BRAZIL"
  location                        = azurerm_resource_group.labbrazil.location
  resource_group_name             = azurerm_resource_group.labbrazil.name
  network_interface_ids           = [azurerm_network_interface.labbrazil.id]
  size                            = "Standard_DS1_v2"
  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name                 = "my-terraform-os-disk"
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  tags = {
    environment = "lab-brazil-env"
  }
}

# Configurate to run automated tasks in the VM start-up
resource "azurerm_virtual_machine_extension" "labbrazil" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_linux_virtual_machine.labbrazil.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
      "commandToExecute": "echo 'Hello, World' > index.html ; nohup busybox httpd -f -p 8080 &"
    }
  SETTINGS

  tags = {
    environment = "lab-brazil-env"
  }
}
