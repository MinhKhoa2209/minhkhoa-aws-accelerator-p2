# DevOps Foundation Roadmap

## Terraform, Docker & Kubernetes

> Learning roadmap based on official documentation, CNCF references, HashiCorp Learn, Docker Docs, and mentor Nghĩa Huỳnh's production-oriented series.

---

# Table of Contents

1. IaC & Terraform Overview
2. HCL Syntax & Core Concepts
3. Terraform Workflow
4. State Management
5. Modules & Code Reuse
6. Best Practices & Teamwork
7. Real-World Project & Next Steps

---

# 1. IaC & Terraform Overview

## What is Infrastructure as Code (IaC)?

Infrastructure as Code (IaC) is the practice of provisioning and managing infrastructure through source code instead of manual operations.

Benefits:

* Automation
* Reproducibility
* Version Control
* Reduced Human Error
* Faster Deployment

---

## What is Terraform?

Terraform is an Infrastructure as Code (IaC) tool developed by HashiCorp.

Supported Platforms:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub
* Cloudflare

Terraform uses declarative configuration files written in HCL (HashiCorp Configuration Language).

---

## Terraform Architecture

```text
Terraform Configuration
        │
        ▼
     Provider
        │
        ▼
 Cloud Resources
```

Core Components:

* Provider
* Resource
* Variable
* Output
* Data Source
* Module
* State

---

# 2. HCL Syntax & Core Concepts

## Provider

```hcl
provider "aws" {
  region = "us-east-1"
}
```

---

## Resource

```hcl
resource "aws_s3_bucket" "frontend" {
  bucket = "my-frontend-bucket"
}
```

---

## Variable

```hcl
variable "instance_type" {
  default = "t2.micro"
}
```

Usage:

```hcl
instance_type = var.instance_type
```

---

## Output

```hcl
output "bucket_name" {
  value = aws_s3_bucket.frontend.bucket
}
```

---

## Local Values

```hcl
locals {
  project_name = "devops-lab"
}
```

---

## Data Sources

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
}
```

---

## Conditional Expression

```hcl
instance_type = var.env == "prod" ? "t3.medium" : "t2.micro"
```

---

## for_each

```hcl
resource "aws_s3_bucket" "bucket" {
  for_each = toset([
    "dev",
    "staging",
    "prod"
  ])

  bucket = "my-${each.key}"
}
```

---

# 3. Terraform Workflow

## Initialize

```bash
terraform init
```

Downloads required providers and modules.

---

## Format

```bash
terraform fmt
```

Formats Terraform code.

---

## Validate

```bash
terraform validate
```

Checks syntax and configuration validity.

---

## Plan

```bash
terraform plan
```

Shows proposed infrastructure changes.

---

## Apply

```bash
terraform apply
```

Creates or updates infrastructure.

---

## Destroy

```bash
terraform destroy
```

Removes managed infrastructure.

---

## Workflow Diagram

```text
Write Code
    │
    ▼
terraform init
    │
    ▼
terraform plan
    │
    ▼
terraform apply
    │
    ▼
Infrastructure Created
```

---

# 4. State Management

## Terraform State

Terraform stores infrastructure metadata in:

```text
terraform.tfstate
```

Purpose:

* Track resources
* Detect drift
* Manage dependencies

---

## Local Backend

```text
terraform.tfstate
```

Stored locally.

---

## Remote Backend

Production recommendation:

```text
Amazon S3
+
DynamoDB Locking
```

Example:

```hcl
terraform {
  backend "s3" {
    bucket = "terraform-state"
    key    = "prod/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

## Useful State Commands

```bash
terraform state list
terraform state show
terraform state mv
terraform state rm
```

---

# 5. Modules & Code Reuse

## What is a Module?

A module is a reusable collection of Terraform resources.

---

## Folder Structure

```text
terraform/
├── modules/
│   └── vpc/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── main.tf
```

---

## Module Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  cidr_block = "10.0.0.0/16"
}
```

---

## Terraform Registry

Useful modules:

* AWS VPC Module
* AWS EKS Module
* AWS RDS Module

Registry:

https://registry.terraform.io

---

# 6. Best Practices & Teamwork

## Git Workflow

Recommended:

```text
Feature Branch
    ↓
Pull Request
    ↓
Code Review
    ↓
Merge
```

---

## Remote State

Always use:

```text
S3 Backend
+
DynamoDB Locking
```

for team environments.

---

## Secrets Management

Never hardcode:

* AWS Access Keys
* Database Passwords
* API Keys

Use:

* AWS Secrets Manager
* AWS Systems Manager Parameter Store

---

## Naming Convention

Example:

```text
project-environment-resource
```

Examples:

```text
myapp-prod-vpc
myapp-dev-eks
```

---

## Security Principles

* Principle of Least Privilege
* IAM Roles
* Encryption at Rest
* Encryption in Transit

---

## CI/CD Integration

Popular tools:

* GitHub Actions
* GitLab CI/CD
* Jenkins
* AWS CodePipeline

---

# 7. Real-World Project & Next Steps

## Project 1 — Static Website

Infrastructure:

* S3
* CloudFront
* Route53
* ACM

---

## Project 2 — Containerized Application

Infrastructure:

* Docker
* ECS Fargate
* ALB
* RDS

---

## Project 3 — Kubernetes Platform

Infrastructure:

* VPC
* EKS
* Node Group
* IAM Roles
* Load Balancer Controller

---

# Docker Fundamentals

Key Concepts:

* Image
* Container
* Dockerfile
* Volume
* Network
* Registry

Useful Commands:

```bash
docker build -t app .
docker run -p 8080:8080 app
docker ps
docker logs <container>
```

---

# Kubernetes Fundamentals

Core Objects:

* Pod
* Deployment
* Service
* ConfigMap
* Secret
* Ingress

Useful Commands:

```bash
kubectl get pods
kubectl get svc
kubectl get deployments
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

---

# Required Tools

Terraform

```bash
terraform version
```

Docker

```bash
docker version
```

kubectl

```bash
kubectl version --client
```

Minikube

```bash
minikube version
```

AWS CLI

```bash
aws --version
```

---


