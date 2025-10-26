# Setting Up Remote State Storage

## Lab Overview

Welcome to the Setting Up Remote State Storage lab. In this lab, we will cover three objectives:

1. Create an Azure Storage Account.
2. Deploy a virtual network with the local backend.
3. Update the backend and migrate state data.

By the end of this lab, you will know how to configure a Terraform deployment to use the `azurerm` backend and how to migrate existing state data.

## What to Expect

- **Environment:** You will work directly in the Azure Portal to complete the objectives in your tab.
- **Access:** We will provide you with secure, temporary credentials to a cloud account to log in and use during your lab
- **Modes:** This lab is available to take in in Guided Mode with step-by-step instructions.
- **Progress:** Your progress is not saved if you quit the lab or the lab times out.

---

# Setting Up Remote State Storage

## Introduction

Welcome to the Setting Up Remote State Storage lab. In this lab, we will cover three objectives:

1. Create an Azure Storage account.
2. Deploy a virtual network with the local backend.
3. Update the backend and migrate state data.

By the end of this lab you will know how to configure a Terraform deployment to use the `azurerm` backend and how to migrate existing state data.

## Additional Information and Resources

Globomantrics has started using Terraform for production workloads and is moving existing state data off local workstations and onto a remote backend. Since they are already using Azure for everything else, they have decided to use the Azure backend for state data storage. You have been tasked with creating a storage account to hold state data and migrating the state data of an existing network deployment. Let's get started.

To complete this lab, you will need the following prerequisites installed locally:

- VS Code (or a similar code editor)
- Terraform CLI
- Azure CLI

## Solution

### Create an Azure Storage account

1. Log into Azure using the Azure CLI:

   ```shell
   az login
   ```

2. Enter the lab credentials in the browser window that appears.

3. Create a new folder to hold a Terraform Configuration to deploy a storage account:

   ```shell
   mkdir create_storage
   cd create_storage
   ```

4. Create the following files in the new directory

   ```shell
   touch {terraform,main,variables,outputs}.tf
   touch terraform.tfvars
   ```

5. Add the following contents to the created files: `terraform.tf`

   ```hcl
   terraform {
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~>3.0"
       }
     }
   }
   ```

   `main.tf`:

   ```hcl
   provider "azurerm" {
     features {}
     skip_provider_registration = true
     storage_use_azuread        = true
   }
   
   data "azurerm_resource_group" "main" {
     name = var.resource_group_name
   }
   
   resource "random_integer" "main" {
     min = 10000
     max = 99999
   }
   
   resource "azurerm_storage_account" "main" {
     name                = "${lower(var.prefix)}taco${random_integer.main.result}"
     location            = data.azurerm_resource_group.main.location
     resource_group_name = data.azurerm_resource_group.main.name
   
     account_tier                      = "Standard"
     account_kind                      = "StorageV2"
     account_replication_type          = "GRS"
     enable_https_traffic_only         = true
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
   
   # Create a container in storage account
   resource "azurerm_storage_container" "main" {
     name                  = "tfstate"
     storage_account_name  = azurerm_storage_account.main.name
     container_access_type = "private"
   }
   ```

   `variables.tf`:

   ```hcl
   variable "resource_group_name" {
     type        = string
     description = "Name of the resource group provided by the lab."
   }
   
   variable "prefix" {
     type        = string
     description = "Prefix to be used for all resources in this lab."
   }
   ```

   `outputs.tf`:

   ```hcl
   output "storage_account_name" {
     value = azurerm_storage_account.main.name
   }
   ```

   `terraform.tfvars`

   ```hcl
   prefix              = "dev"
   resource_group_name = "RESOURCE_GROUP_NAME"
   ```

6. Update the `terraform.tfvars` file with the provided resource group name from the lab:

   ```hcl
   az group list --query [].Name
   ```

7. Initialize and deploy the Terraform configuration:

   ```shell
   terraform init
   terraform appply -auto-approve
   ```

8. Make note of the storage account name for the next objective:

   ```shell
   terraform output
   ```

### Deploy a virtual network with the local backend

1. Create a new folder to hold a Terraform Configuration to deploy a virtual network:

   ```shell
   cd ..
   mkdir vnet_config
   cd vnet_config
   ```

2. Create files for the configuration:

   ```shell
   touch {terraform,main}.tf
   touch terraform.tfvars
   ```

3. Populate the files with the following content: `terraform.tf`

   ```hcl
   terraform {
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~>3.0"
       }
     }
   }
   ```

   `main.tf`

   ```hcl
   provider "azurerm" {
     features {}
     skip_provider_registration = true
     storage_use_azuread        = true
   }
   
   variable "resource_group_name" {
     type        = string
     description = "Name of the resource group provided by the lab."
   }
   
   data "azurerm_resource_group" "main" {
     name = var.resource_group_name
   }
   
   resource "azurerm_virtual_network" "main" {
     name                = "taco-wagon-app"
     resource_group_name = data.azurerm_resource_group.main.name
     location            = data.azurerm_resource_group.main.location
   
     address_space = ["10.42.0.0/24"]
   }
   ```

   `terraform.tfvars`

   ```hcl
   resource_group_name = "RESOURCE_GROUP_NAME"
   ```

4. Update the `RESOURCE_GROUP_NAME` placeholder with the resource group name from the lab.

5. Initialize and deploy the Terraform configuration.

   ```shell
   terraform init
   terraform apply -auto-approve
   ```

### Update the backend and migrate state data

1. Update the `terraform.tf` file in the `vnet_config` directory as follows:

   ```hcl
   terraform {
     required_providers {
       azurerm = {
         source  = "hashicorp/azurerm"
         version = "~>3.0"
       }
     }
   
     backend "azurerm" {
       
     }
   }
   ```

2. Create a new `backend-config.tfbackend` file:

   ```shell
   touch backend-config.tfbackend
   ```

3. Add the following content to the `backend-config.tfbackend` file:

   ```hcl
   resource_group_name  = "RESOURCE_GROUP_NAME"
   storage_account_name = "STORAGE_ACCOUNT_NAME"
   container_name       = "tfstate"
   key                  = "terraform.tfstate"
   use_azuread_auth     = true
   ```

4. Update the `RESOURCE_GROUP_NAME` and `STORAGE_ACCOUNT_NAME` placeholder values, using the storage account name output from the `create_storage` configuration.

5. Run `terraform init` to initialize the configuration and migrate state data:

   ```shell
   terraform init -backend-config="backend-config.tfbackend"
   ```

6. Accept the migration prompt to copy the state data to the storage account.

7. Check the contents of the local state file to verify it is empty:

   ```shell
   cat terraform.tfstate
   ```

8. Run `terraform state list` to verify the state data is stored in the storage account container.

   ```shell
   terraform state list
   ```

## Conclusion

In this lab you created an Azure Storage account to hold Terraform state data using some of the recommended practices for security and resiliency. Then you deployed a Terraform configuration using the local backend and migrated the state data to the storage account.