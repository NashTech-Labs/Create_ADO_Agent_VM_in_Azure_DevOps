##############################
# AzureRm provider variables #
##############################
variable "azure_client_id_vv" {
  description = "Service Principal Client id details"
}

variable "azure_client_secret_vv" {
  description = "Service Principal Client Secrets details"
}

variable "azure_tenant_id_vv" {
  description = "Service Principal tenant id details"
}

variable "azure_subscription_id_vv" {
  description = "Service Principal subsription id details"
}


########################################
# Virtual Network and Subnet variables #
########################################
variable "vnet_name_vv" {
  description = "VNet name"
  type        = string
}

variable "vnet_rg_name_vv" {
  description = "Resource Group for Virtual Network"
  type        = string
}

variable "subnet_name_vv" {
  description = "Subnet name"
  type        = string
}


###############################################
# Name, Resource Group and Location variables #
###############################################
variable "name_vv" {
  type        = string
  description = "Name Substring for the resoures"
}

variable "location_vv" {
  type        = string
  description = "Location of the resources"
}


###############################
# Network Interface variables #
###############################
variable "nic_ip_config_private_ip_addr_allocation_vv" {
  description = "Network Interface IP Config Private IP Address Allocation"
  type        = string
  default     = "Dynamic"
}


#############################
# Virtual machine variables #
#############################
variable "no_of_vm_vv" {
  type        = string
  description = "Number of VMs"
}

variable "vm_size_vv" {
  description = "Virtual Machine Size"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_user_vv" {
  description = "Name of the user"
  type        = string
  default     = "azureuser"
}

variable "vm_os_disk_caching_vv" {
  description = "Virtual Machine OS Disk Caching"
  type        = string
  default     = "ReadWrite"
}

variable "vm_os_disk_storage_acc_type_vv" {
  description = "Virtual Machine storage account type"
  type        = string
  default     = "Premium_LRS"
}

variable "vm_source_image_reference_sku_vv" {
  description = "Virtual Machine Source Image Reference SKU"
  type        = string
  default     = "22_04-lts-gen2"
}

variable "vm_identity_type_vv" {
  description = "Virtual Machine identity type"
  type        = string
  default     = "SystemAssigned"
}

####################################
# ADO AGENT REGISTRATION VARIABLES #
####################################
variable "ado_organisation_url_vv" {
  description = "Azure DevOps server URL"
  type        = string
  default     = "https://dev.azure.com/DCTEng"
}

variable "adotoken_vv" {
  description = "Azure DevOps Token to register agent"
  type        = string
}

variable "ado_pool_name_vv" {
  description = "Agent Pool name where to register the agent"
  type        = string
  default     = "EMS"
}

variable "ado_agent_tag_vv" {
  description = "value of user capabilites tag for the agent"
  type        = string
}
