# =============================================================================
# Project:     Serverless Orders Infrastructure
# File:        infra/serverless-orders/outputs.tf
# Description: Terraform outputs for the Serverless Orders infrastructure.
# =============================================================================

output "resource_group_name" {
  value = azurerm_resource_group.orders.name
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.orders.id
}

output "application_insights_instrumentation_key" {
  value     = azurerm_application_insights.orders.instrumentation_key
  sensitive = true
}

output "key_vault_uri" {
  value = azurerm_key_vault.orders.vault_uri
}

output "app_configuration_endpoint" {
  value = azurerm_app_configuration.orders.endpoint
}