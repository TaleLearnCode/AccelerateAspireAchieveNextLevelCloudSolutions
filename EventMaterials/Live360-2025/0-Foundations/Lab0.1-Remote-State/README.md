# Lab 0.1: Configure Terraform Remote State

In this lab, you will create a dedicated Azure resource group and storage account to host the **Terraform remote state** for the workshop. Remote state ensures that your infrastructure deployments are consistent, collaborative, and production-ready. By the end of this lab, Terraform will be configured to use an Azure Storage Blob container as its backend.

---

## Objectives

In this lab, we will cover the following objectives:

- Create a dedicated resource group and storage account for the Terraform state.
- Configure a blob container to hold the state file(s).
- Update the Terraform configuration to use the Azure Storage backend and migrate state data.

By the end of this lab, you will know how to configure a Terraform deployment to use the `azurerm` backend and how to migrate existing state data.

---

## Prerequisites

- Azure subscription with contributor access.
- Visual Studio Code (or a similar code editor)
- Azure CLI installed and authenticated (`az login`).
- Terraform CLI installed.
- Git client installed.

---

## Background Information

### How It Works

- **Terraform State:** Terraform tracks the resources it manages in a state file.
- **Remote State:** Instead of storing this file locally, we store it in a shared backend (Azure Storage).
- **Azure Storage Backend:** Terraform supports using a blob container to store state, with built-in locking and consistency.

### Key Characteristics

- Centralized and shared across team members and pipelines.
- Supports state locking to prevent concurrent modifications.
- Secured with Azure RBAC and storage account access controls.

### Key Benefits

- **Consistency:** Everyone works from the same state.
- **Collaboration:** Pipelines and developers can share infrastructure safely.
- **Resilience:** The state is backed up and not tied to a single machine.

---

## Lab Steps

### Step 1: Log in to Azure

1. Log in to Azure using the Azure CLI:

   ```shell
   az login
   ```

2. Follow the interactive prompts to log in to your Azure account.

> [!TIP]
>
> Depending on your Azure account setup, you might also need to select the Azure subscription.

3. Get and make note of your Azure subscription identifier:

   ```shell
   az account show
   ```

> [!TIP]
>
> Are you having trouble logging in or running Terraform? Check the [troubleshooting guide (Azure CLI + Terraform Troubleshooting Guide)](../../Resources/terraform-auth-troubleshooting.md).

### Step 2: Create the Bootstrap Terraform Configuration

In the `infra/remote-state` folder, create a file named `terraform.tf` with the following:

```hcl
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
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
  subscription_id = "AZURE_SUBSCRIPTION_ID"
}
```

Replace `AZURE_SUBSCRIPTION_ID` with the subscription identifier you retrieved in the previous step.

In the same folder, create a file named `main.tf` with the following:

```hcl
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
```

Also, create an `output.tf` file with the following:

```hcl
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
```

This configuration provisions:

- A resource group for the state.
- A uniquely named storage account.
- A blob container named `tfstate`.

### Step 3: Apply the Bootstrap Configuration

In the terminal and from the `infra/remote-state` folder:

```shell
terraform init
terraform apply -auto-approve
```

Verify in the Azure Portal that the resource group, storage account, and container exist. Then, run `terraform output` to capture the resource group and storage account names.

### Step 4: Update the backend and migrate state data

1. Update the `infra/remote-state/terraform.tf` file to include the remote state backend information. Your file should look similar to the following:

   ```hcl
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
       storage_account_name  = "STORAGE-ACCOUNT-NAME"
       container_name        = "tfstate"
       key                   = "remote-state.tfstate"
       use_azuread_auth = true
     }
   }
   
   provider "azurerm" {
     features {}
     skip_provider_registration = true
     storage_use_azuread        = true
   }
   ```

   Replace `STORAGE-ACCOUNT-NAME` with the name of the storage account just created (will be listed in the Terraform apply output).

2. Run `terraform init` to initialize the configuration and migrate state data:

   ```shell
   terraform init -reconfigure
   ```

   You should receive a prompt that starts with "Do you want to copy existing state to the new backend?" Enter "yes" to accept.

### Step 5: Verify

1. In the Azure Portal, confirm that the blob container contains `terraform.tfstate`.

2. Check that the local `terraform.tfstate` file is empty by running the following in the terminal:

   ```shell
   cat terraform.tfstate
   ```

3. Verify that the state data is stored in the storage account container, by running:

   ```shell
   terraform state list
   ```

   You should see the resources Terraform manages, confirming that the state is now stored remotely.

### Step 6: Commit and Push Changes to the Central Repository

Now that you have configured Terraform remote state and verified it is working, commit your changes to your central repository (GitHub or Azure DevOps).

1. Stage all new and updated files:

   ```shell
   git add .
   ```

2. Commit the changes with a descriptive message:

   ```shell
   git commit -m "Add remote state configuration with Azure Storage backend"
   ```

3. Push the changes to your central repository:

   ```shell
   git push origin main
   ```

> [!TIP]
>
> If you use Azure DevOps and your default branch is `master` instead of `main`, adjust the push common accordingly.

---

## Solution

The Solution folder contains a completed version of this lab, including a working Terraform configuration with backend configuration.

---

## Conclusion and Next Steps

In this lab, you successfully provisioned a dedicated resource group, storage account, and blob container to host your Terraform remote state. You then configured Terraform to use the Azure Storage backend and migrated your state data. This ensures that your infrastructure deployments are now **centralized, secure, and ready for collaboration**; a critical foundation for real-world team-based cloud projects.

With the remote state configured, you can deploy the **baseline infrastructure** for the Serverless Order Processing & Tracking System in **Lab 0.2**. This will build on the foundation you have just created and begin shaping the core environment for the rest of the workshop.