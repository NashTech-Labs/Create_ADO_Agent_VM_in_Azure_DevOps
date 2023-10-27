data "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name_vv
  resource_group_name = var.vnet_rg_name_vv
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name_vv
  resource_group_name  = data.azurerm_virtual_network.vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "template_file" "init" {
  template = file("./userdata.sh")
  count    = var.no_of_vm
  vars = {
    ADOORGANISATIONURL         = var.ado_organisation_url_vv
    ADOTOKEN                   = var.adotoken_vv
    POOLNAME                   = var.ado_pool_name_vv
    AGENTNAME                  = "${local.ado_agent_name_vv}-${count.index_vv}"
    AGENTUSERCAPABILITIESKEY   = "agent.tag"
    AGENTUSERCAPABILITIESVALUE = "${var.azure_subscription_id_vv}-${var.ado_agent_tag_vv}"
  }
}