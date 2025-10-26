# =============================================================================
# Project:     Serverless Orders
# File:        infra/remote-state/serverless-orders/terraform.tf
# Description: Defines the Terraform provider and AzureRM configuration for
#              the Serverless Orders project.
# =============================================================================

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = "rg-terraform-state"
    storage_account_name  = "sttfstate71890"
    container_name        = "tfstate"
    key                   = "serverless-orders.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = "95410236-d7ed-4e09-a4e6-e72a42765ca5"
}