terraform {

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.52.0"
    }
  }
}

provider "azurerm" {
  features {}
  tenant_id       = var.azure_tenant_id_vv
  subscription_id = var.azure_subscription_id_vv
  client_id       = var.azure_client_id_vv
  client_secret   = var.azure_client_secret_vv
}
