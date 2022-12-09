# Output variable: Name for Virtual Machine 
output "name_avm" {
  value = azurerm_linux_virtual_machine.labbrazil.name
}

# Output variable: Location for Virtual Machine 
output "location" {
  value = azurerm_linux_virtual_machine.labbrazil.location
}

# Output variable: Public IP address
output "public_ip" {
  value = data.azurerm_public_ip.labbrazil.ip_address
}

# Output variable: Name group
output "name_group" {
  value = azurerm_resource_group.labbrazil.name
}

# Output variable: Security group
output "security_group" {
  value = azurerm_network_security_group.labbrazil.name
}