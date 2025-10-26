# Azure CLI + Terraform Troubleshooting Guide

Authentication issues can sometimes arise when working with Terraform and the Azure CLI. This page outlines common problems and the steps you can take to resolve them.

---

## 1. Standard Login

Most of the time, a simple login is all you need:

```shell
az login
```

This opens a browser where you can sign in with your Azure account.

If you have multiple Azure tenants, it could be helpful to include the tenant identifier:

```shell
az login --tenant "<your-tenant-id>"
```

---

## 2. If you See "Need user interaction to continue..."

This error usually looks like:

```shell
ERROR: Need user interaction to continue.. Status: Response_Status.Status_InteractionRequired
```

This means Azure AD requires extra steps (like MFA or conditional access) that the CLI cannot complete silently.

### ✅Fix: Use Device Code Login

```shell
az login --tenant "<your-tenant-id>" --use-device-code
```

This will give you a short code and a URL. Open the URL in your browser, enter the code, and complete the login.

---

## 3. If Terraform Still Fails with "could not acquire access token"

Terraform uses the Azure CLI's cached token. If that token was required with the wrong scope or has expired, you may see errors like:

```shell
Error: building account: could not acquire access token to parse claims
```

### ✅ Fix: Clear and Re-Login

```shel
az account clear
az logout
az login --tenant "<your-tenant-id>" --use-device-code
```

Then retry your Terraform CLI command.

---

## 4. Service Principal Option

> [!CAUTION]
>
> It is not recommended that you use the service principal option. If you do, then you should take further steps to protect your client_id and client_secret from being added to the centralized repository.

If you want to avoid interactive logins entirely, you can use a service principal:

1. Create the service principal:

   ```shell
   az ad sp create-for-rbac \
     --name "terraform-sp" \
     --role Contributor \
     --scopes /subscriptions/<subscription-id>
   ```

2. Configure Terraform:

   ```hcl
   provider "azurerm" {
     features {}
   
     client_id       = "<appId>"
     client_secret   = "<password>"
     tenant_id       = "<tenantId>"
     subscription_id = "<subscriptionId>"
   }
   ```

---

## 5. Quick Tips

- Always check which account is active:

  ```shell
  az account show
  ```

- If you have multiple subscriptions, set the right one:

  ```shell
  az account set --subscription "<subscription-id>"
  ```

- Avoid adding custom `--scope` arguments unless you know you need them. The CLI automatically requests the correct scopes for Terraform.