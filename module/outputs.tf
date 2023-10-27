output "vnet_name" {
  value = data.azurerm_virtual_network.vnet.name
}

output "private_ip_address" {
  value = azurerm_network_interface.vm_nic[*].ip_configuration[0].private_ip_address
}

output "subnet_name" {
  value = data.azurerm_subnet.subnet.name
}

output "vm_names" {
  value = [for i in range(var.no_of_vm) : azurerm_linux_virtual_machine.ado_agent[i].name]
}

output "vm_ids" {
  value = [for i in range(var.no_of_vm) : azurerm_linux_virtual_machine.ado_agent[i].id]
}

output "agent_name" {
  value = data.template_file.init.*.vars.AGENTNAME
}

output "resource_group_name" {
  value = azurerm_resource_group.vm_rg.name
}
