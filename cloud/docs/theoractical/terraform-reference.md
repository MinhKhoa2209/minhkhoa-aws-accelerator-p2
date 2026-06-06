# Terraform Reference

## Purpose

This note is the practical companion to the tutorial portal. Use it when you need to look up exact Terraform concepts, syntax, or CLI behavior while working.

## What To Remember

- `Configuration Language` answers how to write `.tf` files.
- `Terraform CLI` answers how to operate Terraform in the correct workflow.
- `HCL` expresses desired state; it is not an imperative programming model.
- Terraform `state` is operational data, not a disposable side file.
- A `module` packages reusable Terraform logic.

## How To Think About It

- `variable`, `locals`, and `output` are core building blocks for W8-D1.
- `init`, `plan`, `apply`, and `destroy` are the workflow you should remember in sequence.
- A `provider` connects Terraform to a real API. A `module` organizes your Terraform logic.

## How It Applies to W8

- `cloud/w8/day-1/terraform-basics/variables.tf`
  - input types, descriptions, and validation
- `cloud/w8/day-1/terraform-basics/locals.tf`
  - expressions and data transformation
- `cloud/w8/day-1/terraform-basics/outputs.tf`
  - inspecting evaluated values
- `cloud/w8/day-1/terraform-basics/modules/portfolio_summary/`
  - understanding module boundaries

## When To Open This Note

- when you forget HCL syntax
- when you need exact CLI behavior or flags
- when `state`, `module`, and `provider` start to blur together
- when you move from a local sandbox to real providers

## Self-Check

- Why are `locals` different from `variables`?
- Why is `terraform plan` important before `apply`?
- Why is Terraform `state` often described as the map between code and real infrastructure?

## Official Sources

- `https://developer.hashicorp.com/terraform/docs`
