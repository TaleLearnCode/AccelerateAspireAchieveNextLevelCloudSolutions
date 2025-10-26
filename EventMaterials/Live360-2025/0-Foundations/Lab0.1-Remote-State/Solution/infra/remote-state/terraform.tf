# =============================================================================
# Project:     Remote State Infrastructure
# File:        infra/remote-state/terraform.tf
# Description: Defines the Terraform provider and AzureRM configuration for
#              managing remote state infrastructure.
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
    storage_account_name  = "STORAGE-ACCOUNT-NAME"  # Replace with actual storage account name
    container_name        = "tfstate"
    key                   = "remote-state.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = "SUBSCRIPTION-ID"  # Replace with actual subscription ID
}