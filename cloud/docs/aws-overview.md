# AWS Overview

## Purpose

This note explains how to approach AWS documentation efficiently. AWS is broad, so the main skill is not reading everything, but reading the right service documentation at the right time.

## What To Remember

- Do not use the `root user` for routine work.
- Create the correct `IAM user` or role and enable `MFA`.
- Install `AWS CLI v2` and verify identity early.
- Read AWS docs by `service` and `use case`, not by wandering through the portal.
- In later weeks, real AWS work will likely involve IAM, CLI, VPC, ECR, EKS, and EC2.

## Basic Checklist

- AWS account available
- MFA enabled
- correct admin user or role available
- AWS CLI installed
- identity verified with:

```powershell
aws sts get-caller-identity
```

## How It Applies to W8 and Beyond

- W8 is still focused on local Terraform and Kubernetes foundations.
- Even so, AWS basics should already be in place so that W9 and W10 do not start with account setup friction.

## How To Read AWS Docs Well

- start with the service you actually need
- read `Getting Started`
- read `Concepts`
- read `Best Practices`
- read `CLI` documentation if you will work from the terminal

## Self-Check

- Why should you avoid using the root user for daily CLI work?
- Which command confirms which AWS identity you are currently using?
- Why is service-focused reading better than randomly browsing the AWS docs portal?

## Official Sources

- `https://docs.aws.amazon.com`
- `https://docs.aws.amazon.com/accounts/latest/reference/getting-started.html`
- `https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html`
