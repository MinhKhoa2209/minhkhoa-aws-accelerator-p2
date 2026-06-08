# Terraform Tutorials

## Purpose

This note explains how to use the HashiCorp tutorial portal without getting lost. The portal is broad, so the main value is knowing what to study first and why.

## What To Remember

- Start with workflow, not just syntax.
- A strong W8 order is: `Get Started -> CLI -> Configuration Language -> Modules -> State`.
- `Get Started - AWS` shows a complete infrastructure lifecycle: create, change, and destroy.
- `Modules` and `State` are often under-studied by beginners, but they matter immediately in real work.
- `HCP Terraform` is not required for W8, but it becomes relevant when collaboration and governance matter.

## How To Think About It

- Terraform is not a scripting tool wrapped in `.tf` files.
- Terraform describes desired state and calculates how to move current infrastructure toward that state.
- The tutorial portal is a learning roadmap. It is not the same thing as the language reference.

## Recommended Reading Path

1. `Get Started - AWS`
2. `CLI`
3. `Configuration Language`
4. `Modules`
5. `State`
6. `Use Cases` if you want to connect Terraform to AWS or Kubernetes

## How It Applies to W8

- `cloud/w8/day-1/terraform-basics/` aligns well with the `Configuration Language` material.
- `cloud/w8/day-1/README.md` is a local summary, while the official tutorials provide the full learning path.
- When you move to real providers in later weeks, return to the AWS and production-focused sections.

## Useful Commands While Studying

```powershell
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform console
```

## Self-Check

- Why is it risky to learn Terraform without understanding `state`?
- What is the difference between reading a tutorial and reading a reference page?
- What problems appear if you know syntax but do not understand the workflow?

## Official Sources

- `https://developer.hashicorp.com/terraform/tutorials`
