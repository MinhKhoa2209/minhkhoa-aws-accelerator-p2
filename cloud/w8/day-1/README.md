# W8-D1 — Terraform Foundations

## Goal

Day 1 focuses on Terraform fundamentals:
- Infrastructure as Code and why it matters
- HCL syntax and core Terraform building blocks
- the standard Terraform workflow
- state management basics
- module composition
- foundational best practices

## Reference Material

- Terraform Language overview: https://developer.hashicorp.com/terraform/language
- Configuration syntax / HCL: https://developer.hashicorp.com/terraform/language/syntax/configuration
- `terraform init`: https://developer.hashicorp.com/terraform/tutorials/cli/init
- State: https://developer.hashicorp.com/terraform/language/state
- Remote state: https://developer.hashicorp.com/terraform/language/state/remote
- Module block reference: https://developer.hashicorp.com/terraform/language/block/module
- Style guide: https://developer.hashicorp.com/terraform/language/style

## What This Day Includes

This day contains a provider-free Terraform sandbox in `cloud/w8/day-1/terraform-basics/`. It is intentionally lightweight so the focus stays on the language, module structure, validation, and outputs before moving on to real cloud resources.

The sandbox demonstrates:
- input variables with validation
- local values and collection transforms
- outputs for inspection
- a reusable child module
- module-to-root data flow

## Terraform Concepts

Terraform configuration is built from two core syntax elements:
- `arguments`, which assign values such as `environment = "learning"`
- `blocks`, which group related configuration such as `module`, `resource`, or `variable`

The most important block types to understand early are:
- `terraform`: version constraints and backend or cloud settings
- `variable`: typed inputs for reusable configuration
- `locals`: named expressions for reuse and readability
- `output`: values exported to the CLI or other modules
- `module`: packaged and reusable Terraform logic
- `resource`: infrastructure objects Terraform creates or manages
- `data`: read-only lookups of existing infrastructure

Useful language features in this day:
- collection types such as `list`, `map`, and `object`
- string interpolation with `${...}`
- conditional expressions
- `for` expressions for transforming collections
- validation blocks for rejecting invalid input early

## Recommended Workflow

The standard working sequence for this learning sandbox is:

1. `terraform fmt`
2. `terraform init -backend=false`
3. `terraform validate`
4. `terraform console`

In a real environment, the workflow usually continues with:

1. `terraform plan`
2. `terraform apply`
3. `terraform destroy`

Why this order matters:
- `fmt` keeps files in canonical style
- `init` prepares the working directory and installs what Terraform needs
- `validate` checks syntax and internal consistency
- `plan` previews changes before anything is created
- `apply` executes reviewed changes

## State Management Basics

Terraform uses state to map configuration to real infrastructure objects. Without state, Terraform cannot reliably determine what already exists and what must change.

Key points:
- local state is stored in `terraform.tfstate`
- local state is fine for an isolated learning sandbox
- local state is not a good collaboration model for teams
- state can contain sensitive data and should not be committed to Git
- production environments should move to a remote backend or HCP Terraform

## Module Example in This Repo

The sandbox now includes a child module:

```text
terraform-basics/
  main.tf
  variables.tf
  locals.tf
  outputs.tf
  modules/
    portfolio_summary/
```

This module shows how to:
- pass typed inputs from a root module to a child module
- compute normalized learning metadata inside the child module
- export child module outputs back to the root module

## Best Practices Applied Here

- every variable has a `type` and `description`
- validation rules are used where input constraints are meaningful
- shared expressions are moved into `locals`
- module inputs are explicit rather than implicit
- outputs are documented for downstream consumers
- the example stays provider-free so validation remains fast and deterministic

## Suggested Commands

```powershell
cd cloud/w8/day-1/terraform-basics
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform console
```

Useful expressions to inspect in `terraform console`:

```hcl
local.standard_tags
local.w8_paths
local.learning_summary
module.portfolio_summary.learning_checkpoint
module.portfolio_summary.study_recommendations
```
