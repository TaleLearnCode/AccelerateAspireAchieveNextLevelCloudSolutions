# Lab 0.1 Solution: Configure Terraform Remote State

This folder contains the completed Terraform configuration for **Lab 0.1: Configure Terraform Remote State**.

---

## What’s New in This Lab

Building on the Lab 0.0 solution, this lab introduces the following files in the `infra/remote-state` folder:

- `terraform.tf` – Defines the provider and backend configuration for `AzureRM`, including the remote state backend.
- `main.tf` – Provisions the resource group, storage account, and blob container for remote state.
- `outputs.tf` – Exposes the resource group and storage account names as outputs.

---

## Changes in `terraform.tf`

Compared to the bootstrap configuration in Lab 0.0, this solution includes the following updates:

- Added a `backend "azurerm"` block inside the `terraform` configuration to enable remote state storage in Azure Storage.
- Specified:
  - `resource_group_name` = `"rg-terraform-state"`
  - `storage_account_name` = `"STORAGE-ACCOUNT-NAME"` (replace with your actual storage account name from Lab 0.1)
  - `container_name` = `"tfstate"`
  - `key` = `"remote-state.tfstate"`
  - `use_azuread_auth = true`
- Updated the `provider "azurerm"` block to include your `subscription_id`.

These changes configure Terraform to migrate state from local storage to the Azure Storage backend you provisioned in this lab.

---

## How to Use

1. Review the [lab instructions](../README.md).
2. Compare your implementation with the files here to validate your work.
3. If you encounter issues, you can run this solution directly:

   ```shell
   terraform init -reconfigure
   terraform apply

> **Note:** Update your environment's `subscription_id` and `storage_account_name` values.

---

## Reminder

The solution is provided for reference. We recommend completing the lab steps yourself before relying on the solution files. Use this folder to validate your work or troubleshoot issues.