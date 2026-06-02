# W8-D1 — Terraform Foundations


## IaC overview

Infrastructure as Code is the practice of describing infrastructure with code instead of clicking through a console. With Terraform, you write the desired state in `.tf` files, then use the `init -> fmt -> validate -> plan -> apply` workflow to create or update infrastructure in a repeatable, reviewable way.

Why IaC matters:
- reduce configuration drift across environments
- review changes through Git instead of manual operations
- reuse configuration through modules and variables
- make auditing, rollback, and CI/CD automation easier

## Terraform Concepts

- `terraform`: declares version constraints and backend/provider requirements
- `variable`: input for a module or root configuration
- `locals`: groups expressions for reuse and avoids repeated hard-coded values
- `output`: output value after apply, or a value for a parent module to consume
- `resource`: describes an infrastructure object Terraform should manage
- `data`: reads existing information instead of creating new resources
- `state`: the file that records what Terraform manages; do not edit it manually unless you fully understand the consequences

## HCL syntax 

- Block: `resource "aws_s3_bucket" "logs" { ... }`
- Argument: `bucket = "my-bucket"`
- Expression: `var.environment == "prod" ? 3 : 1`
- Collection types: `list`, `map`, `set`, `object`
- Interpolation and template strings: `"cloud/w8/${var.environment}"`
- Validation: use `validation` in `variable` blocks to reject invalid input early
- `for` expression: create new lists or maps from existing collections
