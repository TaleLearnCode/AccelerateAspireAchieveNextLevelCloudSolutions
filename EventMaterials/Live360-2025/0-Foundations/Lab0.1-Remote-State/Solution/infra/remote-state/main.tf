# =============================================================================
# Project:     Remote State Infrastructure
# File:        infra/remote-state/main.tf
# Description: Provides secure, vesioned, and recoverable storage for Terraform
#              state files with audit capabilities and encryption at rest.
# Resources:
# - random_integer.suffix: Generates a random 5-digit suffix (10000-99999) for
#   unique resource naming
# - azurerm_resource_group.tfstate: Creates a resource group named 
#   'rg-terraform-state' in the East US 2 region to contain the state storage
# - azurerm_storage_account.tfstate: Creates a storage account with the following
#   characteristics:
#   * Name: sttfstate{random-suffix}
#   * Type: Standard tier, StorageV2 kind
#   * Replication: Locally redundant storage (LRS)
#   * Security: HTTPS-only traffic, TLS 1.2 minimum, OAuth authentication default,
#     shared access keys disabled
#   * Blob properties:
#     - Versioning enabled for state file history
#     - Change feed enabled with 90-day retention for audit trails
#     - Last access time tracking enabled
#     - 30-day soft delete retention policy for blob recovery
# =============================================================================

# -----------------------------------------------------------------------------
# Generate a random integer suffix for unique resource names
# -----------------------------------------------------------------------------

resource "random_integer" "suffix" {
  min = 10000
  max = 99999
}

# -----------------------------------------------------------------------------
# Create a resource group for Terraform state storage
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-terraform-state"
  location = "eastus2"
}

# -----------------------------------------------------------------------------
# Create a storage account for Terraform state files
# -----------------------------------------------------------------------------

resource "azurerm_storage_account" "tfstate" {
  name                = "sttfstate${random_integer.suffix.result}"
  location            = azurerm_resource_group.tfstate.location
  resource_group_name = azurerm_resource_group.tfstate.name

  account_tier                      = "Standard"
  account_kind                      = "StorageV2"
  account_replication_type          = "LRS"
  https_traffic_only_enabled        = true
  min_tls_version                   = "TLS1_2"
  shared_access_key_enabled         = false
  default_to_oauth_authentication   = true
  infrastructure_encryption_enabled = false

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 90
    last_access_time_enabled      = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }

  sas_policy {
    expiration_period = "00.02:00:00"
    expiration_action = "Log"
  }

  timeouts {
    create = "5m"
    read   = "5m"
  }

}

# -----------------------------------------------------------------------------
# Create a storage container for Terraform state files
# -----------------------------------------------------------------------------

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}


# -----------------------------------------------------------------------------
# Assign 'Storage Blob Data Contributor' role to the Terraform service principal
# -----------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "storage_blob_data_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}