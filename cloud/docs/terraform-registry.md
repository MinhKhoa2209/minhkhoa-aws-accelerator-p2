# Terraform Registry

## Purpose

This note explains what the Terraform Registry is for and how to use it responsibly. The goal is to avoid copying modules blindly and losing control over what your configuration actually does.

## What To Remember

- A `provider` lets Terraform communicate with an external API.
- A `module` packages reusable Terraform logic.
- `terraform init` downloads the providers and modules your configuration needs.
- Providers have different trust levels such as `Official`, `Partner`, and `Community`.
- A popular module is not automatically the right module for your use case.

## How To Think About It

- A provider answers: which platform or API is Terraform managing?
- A module answers: how should this Terraform logic be packaged and reused?
- The Registry is helpful, but it does not replace understanding the resources underneath.

## How It Applies to W8

- In W8-D1, `portfolio_summary` is a local module used to teach the concept before you rely on external modules.
- In later AWS-focused work, module usage often looks like this:

```hcl
module "example" {
  source  = "<namespace>/<name>/<provider>"
  version = "..."
}
```

## How To Read the Registry Well

- read the README first
- check whether inputs and outputs are clearly documented
- confirm which resources the module manages
- review versioning discipline
- prefer clarity over convenience

## Common Beginner Mistakes

- using an external module without understanding what it creates
- not pinning versions
- confusing `provider` and `module`

## Self-Check

- What is the difference between a `provider` and a `module`?
- Why is version pinning important in production-style work?
- Why is a local module still valuable in W8, even before you use the public Registry heavily?

## Official Sources

- `https://registry.terraform.io`
