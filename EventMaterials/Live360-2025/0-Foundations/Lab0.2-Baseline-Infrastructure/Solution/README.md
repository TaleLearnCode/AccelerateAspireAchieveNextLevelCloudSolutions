# Lab 0.2 Solution: Baseline Infrastructure

This folder contains the completed Terraform configuration for [**Lab 0.2: Baseline Infrastructure**](..\README.md).

---

## What's New in This Lab

Building on the Lab 0.1 solution, this lab introduces a new Terraform project in the `infra/serverless-solution` folder with the following files:

- **`terraform.tf`:** Defines the provider and backend configuration, pointing to the remote state created in Lab 0.1.
- **`main.tf`:** Provisions the baseline infrastructure resources (resource group, monitoring, security, and configuration services).
- **`outputs.tf`:** Exposes resource identifiers and endpoints for use in later labs.

---

## Changes in This Lab

This lab creates an entirely new Terraform project separate from the remote state configuration:

- **New folder**: `infra/serverless-solution` (distinct from the `infra/remote-state` folder).
- **Backend configuration**: Points to a new state file (`serverless-orders.tfstate`) in the same storage container.
- **Resources created**:
  - Resource Group (`rg-serverless-orders`)
  - Log Analytics Workspace (`log-serverless-orders`)
  - Application Insights (`appi-serverless-orders`)
  - Key Vault (`kv-serverless-orders-{random}`)
  - App Configuration (`appcs-serverless-orders-{random}`)
- **Role assignments**: Grants the service principal appropriate access to Key Vault and App Configuration.

---

## How to Use

1. Review the [lab instructions](..\README.md).
2. Compare your implementation with the files here to validate your work.
3. If you encounter issues, you can run this solution directly:

   ```shell
   terraform init
   terraform apply

> Note: Be sure to update your environment's `subscription_id` and `storage_account_name` values.

---

## Reminder

The solution is provided for reference. We recommend completing the lab steps yourself before relying on the solution files. Use this folder to validate your work or troubleshoot issues.