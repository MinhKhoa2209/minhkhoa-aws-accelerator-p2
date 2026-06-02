# Terraform Basics Sandbox

## Contents

- `versions.tf`: Terraform version constraint
- `main.tf`: child module wiring
- `variables.tf`: input variables and validation
- `locals.tf`: maps, lists, objects, and `for` expressions
- `outputs.tf`: root outputs for quick inspection
- `terraform.tfvars.example`: example variable overrides
- `modules/portfolio_summary/`: reusable child module example

## Purpose

This sandbox stays provider-free on purpose. The goal is to practice Terraform language features, module structure, validation, and output inspection before introducing real cloud resources and remote state.

## Suggested Commands

```powershell
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform console
```

After entering `terraform console`, try:

```hcl
local.standard_tags
local.w8_paths
local.learning_summary
module.portfolio_summary.learning_checkpoint
module.portfolio_summary.study_recommendations
```
