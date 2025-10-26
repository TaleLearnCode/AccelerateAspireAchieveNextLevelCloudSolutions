# =============================================================================
# Project:     Remote State Infrastructure
# File:        infra/remote-state/output.tf
# Description: Terraform outputs for remote state infrastructure.
# =============================================================================


output "resource_group_name" {
  value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}