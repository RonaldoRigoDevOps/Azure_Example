# Data source to access the properties of an existing Azure Public IP Address
data "azurerm_public_ip" "labbrazil" {
  name                = azurerm_public_ip.labbrazil.name
  resource_group_name = azurerm_linux_virtual_machine.labbrazil.resource_group_name
}