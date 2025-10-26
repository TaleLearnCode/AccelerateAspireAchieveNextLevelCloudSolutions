# Lab 0.0 Solution: Environment Setup

This folder contains the completed setup for [**Lab 0.0: Environment Setup**](../README.md) 

---

## What’s New in This Lab

This is the starting point for the workshop. You created the initial repository and folder structure in this lab that all subsequent labs will build upon. The following files and folders were introduced:

- `.gitignore` – Preconfigured to exclude Terraform state files, sensitive variables, and standard IDE/build artifacts (VS Code, Visual Studio).
- `README.md` – A simple repository overview at the root.
- `infra/` – Base folder for all infrastructure labs.  
  - Empty subfolders are scaffolded for upcoming labs (e.g., `remote-state`, `serverless-orders`, etc.).

---

## Changes in This Lab

Compared to an empty repository, this solution includes:

- A new `infra/` directory to hold all Terraform configurations.  
- A `.gitignore` file tailored for Terraform, VS Code, and Visual Studio environments.  
- A root `README.md` describing the purpose of the repository.  

These changes establish the foundation for version‑controlled infrastructure as code.

---

## How to Use

1. Clone the repository (if you haven’t already):

   ```shell
   git clone https://github.com/<your-username>/serverless-orders-workshop.git
   cd serverless-orders-workshop
   ```
   
1. Review the `.gitignore` file to understand which files are excluded from version control.

1. Explore the `infra/` folder to see the scaffolded structure for upcoming labs.

4. Use this solution as a reference if your initial setup differs from the expected structure.

---

## Reminder

The solution is provided for reference. We recommend completing the lab steps yourself before relying on the solution files. Use this folder to validate your work or troubleshoot issues.