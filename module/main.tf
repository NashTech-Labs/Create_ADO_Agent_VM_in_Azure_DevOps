resource "azurerm_resource_group" "vm_rg" {
  name     = local.resource_group_name_vv
  location = var.location_vv
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.no_of_vm_vv
  name                = "${local.nic_name_vv}-${count.index_vv}"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = local.nic_ip_config_name
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = var.nic_ip_config_private_ip_addr_allocation_vv
  }
}

resource "azurerm_linux_virtual_machine" "ado_agent" {
  count                           = var.no_of_vm_vv
  name                            = "${var.name_vv}-${count.index}"
  location                        = azurerm_resource_group.vm_rg.location
  resource_group_name             = azurerm_resource_group.vm_rg.name
  network_interface_ids           = [azurerm_network_interface.vm_nic.*.id[count.index]]
  size                            = var.vm_size_vv
  computer_name                   = "${local.vm_computer_name_vv}${count.index}"
  admin_username                  = var.vm_user_vv
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.init.*.rendered[count.index])

  admin_ssh_key {
    username   = var.vm_user_vv
    public_key = ""
  }

  os_disk {
    name                 = "${local.vm_os_disk_name_vv}-${count.index}"
    caching              = var.vm_os_disk_caching_vv
    storage_account_type = var.vm_os_disk_storage_acc_type_vv
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = var.vm_source_image_reference_sku_vv
    version   = "latest"
  }

  identity {
    type = var.vm_identity_type_vv
  }
}
