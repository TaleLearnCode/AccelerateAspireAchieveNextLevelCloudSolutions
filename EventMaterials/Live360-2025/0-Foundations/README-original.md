# Module 0: Foundations & Kickoff

Welcome to the **Accelerate, Aspire, Achieve: Next-Level Cloud Solutions** hands-on workshop at **Cloud & Containers Live!** In this module, we will set the stage for the day by provisioning the baseline infrastructure and scaffolding our CI/CD pipelines. This ensures that everyone starts with a consistent, production-style environment. You will also get a quick orientation to the workshop flow and what you will be building.

---

## Overview

In this module, you will:

- Learn how **Terraform remote state** works and why it is critical for real-world infrastructure.
- Provision a **dedicated resource group and storage account** for Terraform state.
- Deploy the **baseline resources** for the Serverless Order Processing & Tracking System.
- Set up a **CI/CD pipeline** (GitHub Actions or Azure DevOps) that we will expand throughout the day.

---

## Learning Objectives

By the end of this module, you will be able to:

- Configure Terraform to use an **Azure Storage backend** for remote state.
- Provision baseline Azure resources with Terraform.
- Run an initial CI/CD pipeline to automate infrastructure deployment.

---

## What We Will Cover

- **Terraform Remote State:** How it works, why it matters.
- **Baseline Infrastructure:** Resource groups, storage, Service Bus namespace.
- **CI/CD Scaffolding:** Setting up pipelines in GitHub Actions or Azure DevOps.

---

## Lab Instructions

1. **Clone the repository** and navigate to the `0-Foundations` folder.
2. **Create remote state resources** (separate resource group + storage account + blob containers).
3. **Configure Terraform backend** to use Azure Storage.
4. **Deploy baseline infrastructure** (resource group, storage, Service Bus).
5. **Set up CI/CD pipeline:**
   - Option A: GitHub Actions workflow.
   - Option B: Azure DevOps pipeline.
6. **Run the pipeline** and verify resources are provisioned.

---

## Solution

If you would like to compare your work, a completed version of this lab is in the Solution folder.

---

## Next Steps

With the foundations in place, we are ready to build our first event-driven component. In **Module 1: Event-Driven Processing**, you will create an Azure Function triggered by Service Bus messages and extend your pipeline to deploy it.