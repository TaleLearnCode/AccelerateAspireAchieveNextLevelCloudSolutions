# =============================================================================
# Project:     Serverless Orders Infrastructure
# File:        infra/serverless-orders/main.tf
# Description: Defines the Azure resources required for the Serverless Orders
#              project, including resource group, monitoring, key vault, and
#              app configuration.
# Resources:
# - data.azurerm_client_config.current: Retrieves the current Azure client
#   configuration for use in resource creation and role assignments
# - azurerm_resource_group.orders: Creates a resource group named
#   'rg-serverless-orders' in the East US 2 region
# - azurerm_log_analytics_workspace.orders: Creates a Log Analytics workspace
#   named 'log-serverless-orders' for monitoring and diagnostics
# - azurerm_application_insights.orders: Creates Application Insights named
#   'appi-serverless-orders' for application performance monitoring
# - azurerm_key_vault.orders: Creates a Key Vault named 'kv-serverless-orders'
#   for secure secret storage
# - azurerm_app_configuration.orders: Creates an App Configuration named
#   'appcs-serverless-orders' for managing application settings
#
# Role Assignments:
# - azurerm_role_assignment.orders_key_vault_access: Grants the current
#   service principal 'Key Vault Secrets Officer' role on the Key Vault
# - azurerm_role_assignment.orders_app_configuration_access: Grants the current
#   service principal 'App Configuration Data Owner' role on the App Configuration
# =============================================================================

# -----------------------------------------------------------------------------
# Generate a random integer suffix for unique resource names
# -----------------------------------------------------------------------------

resource "random_integer" "suffix" {
  min = 100
  max = 999
}

# -----------------------------------------------------------------------------
# Get the current Azure client configuration
# -----------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

# -----------------------------------------------------------------------------
# Create a resource group for the Serverless Orders project
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "orders" {
  name     = "rg-serverless-orders"
  location = "eastus2"
}

# -----------------------------------------------------------------------------
# Create a Log Analytics workspace for monitoring
# -----------------------------------------------------------------------------

resource "azurerm_log_analytics_workspace" "orders" {
  name                = "log-serverless-orders"
  location            = azurerm_resource_group.orders.location
  resource_group_name = azurerm_resource_group.orders.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# -----------------------------------------------------------------------------
# Create Application Insights for application monitoring
# -----------------------------------------------------------------------------

resource "azurerm_application_insights" "orders" {
  name                = "appi-serverless-orders"
  location            = azurerm_resource_group.orders.location
  resource_group_name = azurerm_resource_group.orders.name
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.orders.id
}

# -----------------------------------------------------------------------------
# Create a Key Vault for secure secret storage
# -----------------------------------------------------------------------------

resource "azurerm_key_vault" "orders" {
  name                        = "kv-serverless-orders-${random_integer.suffix.result}"
  location                    = azurerm_resource_group.orders.location
  resource_group_name         = azurerm_resource_group.orders.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
}

resource "azurerm_role_assignment" "orders_key_vault_access" {
  scope                = azurerm_key_vault.orders.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# -----------------------------------------------------------------------------
# Create an App Configuration for application settings management
# -----------------------------------------------------------------------------

resource "azurerm_app_configuration" "orders" {
  name                = "appcs-serverless-orders-${random_integer.suffix.result}"
  location            = azurerm_resource_group.orders.location
  resource_group_name = azurerm_resource_group.orders.name
  sku                 = "standard"
}

resource "azurerm_role_assignment" "orders_app_configuration_access" {
  scope                = azurerm_app_configuration.orders.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}