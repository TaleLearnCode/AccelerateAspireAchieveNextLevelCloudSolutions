# Lab 0.2: Baseline Infrastructure

In this lab, you will create the **baseline infrastructure** for the Serverless Order Processing & Tracking System. This includes a dedicated resource group, Application Insights, a Log Analytics workspace, Azure Key Vault, and Azure App Configuration. These resources form the foundation for observability, secure secret management, and centralized configuration.

---

## Objectives

In this lab, you will:

- Create a dedicated resource group for the serverless solution.
- Provision Application Insights for monitoring.
- Provision a Log Analytics workspace for centralized observability.
- Provision an Azure Key Vault for secure secret storage.
- Provision Azure App Configuration for centralized configuration management.
- Output resource names for use in later labs.

By the end of this lab, you will have a complete baseline environment with observability, security, and configuration services ready to support the serverless components you will build in upcoming modules.

---

## Prerequisites

- Completion of [**Lab 0.1: Remote State**](../Lab0.1-Remote-State/README.md).
- Terraform CLI installed.
- Azure CLI installed and authenticated (`az login`)
- Git client installed.

---

## Background Information

In this lab, we are creating several foundational Azure resources that will support the Serverless Order Processing & Tracking System:

- **Resource Group**

  A logical container for Azure resources. For our solution, this provides an isolated workspace (`rg-serverless-orders`) to hold all solution components, making it easy to manage and clean up after the workshop.

- **Log Analytics Workspace**

  A centralized store for logs and metrics that can be queried with Kusto Query Language (KQL).  For our solution, it collects telemetry from Application Insights and other services, giving us a single place to analyze system behavior.

- **Application Insights**

  A monitoring service that tracks requests, dependencies, exceptions, and performance data. For our solution, it enables observability for the serverless Functions and Container Apps that we will build later, and is linked to the Log Analytics workspace for deeper analysis.

- **Azure Key Vault**

  A secure store for secrets, keys, and certificates. Our solution will use this as a safe place to store sensitive values (like connection strings and API keys) that the serverless application will need.

- **Azure App Configuration**

  A centralized service for managing application settings and feature flags. This service allows us to externalize configuration from code and pipelines, making it easier to manage environment-specific settings and toggle features without redeploying code.

---

## Lab Steps

### Step 1: Define the Terraform Configuration

In the `infra/serverless-orders` folder, create a file named `terraform.tf`

```hcl
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
    storage_account_name  = "STORAGE-ACCOUNT-NAME"   # Replace with your remote state storage account
    container_name        = "tfstate"
    key                   = "serverless-orders.tfstate"
    use_azuread_auth = true
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = "SUBSCRIPTION-ID"  # Replace with your subscription ID
}
```

### Step 2: Add Baseline Resources

Create a file named `main.tf`:

```hcl
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
```

### Step 3: Add Outputs

Create a file named `outputs.tf`:

```hcl
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
```

### Step 4: Apply the Configuration

From the `infra/serverless-orders` folder:

```shell
terraform init
terraform apply -auto-approve
```

Verify in the Azure Portal that the resource group, Application Insights, Log Analytics workspace, Key Vault, and App Configuration exist.

---

## Solution

The `Solution` folder contains a completed version of this lab, including the `terraform.tf`, `main.tf`, and `outputs.tf` files.

---

## Conclusion and Next Steps

In this lab, you provisioned the **baseline infrastructure** for the Serverless Order Processing & Tracking System. You created a dedicated resource group, Application Insights, a Log Analytics workspace, Key Vault, and App Configuration. This ensures your environment is **isolated, observable, and ready for serverless development**. With proper remote state management in place and foundational services deployed, you have a solid platform upon which to build.

With the baseline infrastructure complete, you can start building the serverless solution! In **Module 1: Event-Driven Processing**, you will create your first Azure Function triggered by Service Bus messages, beginning the journey into event-driven serverless patterns. All future deployments will build on the foundation you have established here.