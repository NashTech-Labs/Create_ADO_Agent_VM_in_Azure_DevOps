locals {
  resource_group_name = "${var.name_vv}-rg"
  nic_name            = "${var.name_vv}-nic"
  nic_ip_config_name  = "${var.name_vv}-nic-ip-config"
  vm_computer_name    = replace(var.name_vv, "-", "")
  vm_os_disk_name     = "${var.name_vv}-os-disk"
  ado_agent_name      = var.name_vv
}