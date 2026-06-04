# Cloud Docs for W8

## Purpose

This folder contains study notes based on the official resources listed in `W8_phase2_announcement_cloud.md`.

These notes are not copies of the original documentation. They are meant to help you:
- know what to read first
- focus on the concepts that matter most
- connect each topic to the W8 work in this repository

## Recommended Reading Order

Follow this order if you want the smoothest learning path for W8:

1. `terraform-tutorials.md`
2. `terraform-reference.md`
3. `terraform-registry.md`
4. `docker-install.md`
5. `docker-and-oci.md`
6. `kubernetes-overview.md`
7. `kubernetes-basics.md`
8. `kubectl-and-minikube.md`
9. `aws-overview.md`
10. `aws-learning-platforms.md`
11. `aws-well-architected.md`
12. `cncf-curriculum.md`

## Core Ideas to Remember for W8

- Terraform describes `desired state`; it is not an imperative shell script.
- `terraform init -> plan -> apply` is the core workflow. Syntax alone is not enough.
- Terraform `state` is the mapping between code and real infrastructure.
- A `module` packages reusable Terraform logic. A `provider` connects Terraform to an external API.
- A Docker image is the packaged artifact. A container is a running instance of that image.
- A Kubernetes `Deployment` manages rollout and replica count for stateless workloads.
- A Kubernetes `Service` provides a stable endpoint. Do not design around direct pod IP usage.
- A `readiness probe` determines whether a pod should receive traffic.
- A `NetworkPolicy` controls traffic flow. It does not replace a `Service`.
- minikube is a local learning cluster. The goal is to understand behavior, not just memorize commands.

## Mapping to W8

- `cloud/w8/day-1`
  - `terraform-tutorials.md`
  - `terraform-reference.md`
  - `terraform-registry.md`
- `cloud/w8/day-2`
  - `docker-install.md`
  - `docker-and-oci.md`
  - `kubernetes-overview.md`
  - `kubernetes-basics.md`
- `cloud/w8/day-3`
  - `kubernetes-overview.md`
  - `kubernetes-basics.md`
  - `kubectl-and-minikube.md`
- `cloud/w8/lab`
  - `aws-overview.md`
  - `aws-well-architected.md`
  - `cncf-curriculum.md`

## Document Index

- `online-training.md`
  - End-to-end W8 online self-study plan for the first three days
- `terraform-tutorials.md`
  - Learning path through the Terraform tutorial portal
- `terraform-reference.md`
  - Key Terraform language and CLI reference points
- `terraform-registry.md`
  - Providers, modules, and versioning discipline
- `docker-install.md`
  - Docker installation and local verification
- `docker-and-oci.md`
  - Image, container, Docker, and OCI fundamentals
- `kubernetes-overview.md`
  - Core Kubernetes objects and traffic model
- `kubernetes-basics.md`
  - Deploy, explore, expose, scale, and debug flow
- `kubectl-and-minikube.md`
  - Essential local setup and commands for W8
- `aws-overview.md`
  - AWS account, IAM, CLI, and docs navigation basics
- `aws-learning-platforms.md`
  - When to use Skill Builder versus Workshops
- `aws-well-architected.md`
  - Quality framework for secure and reliable systems
- `cncf-curriculum.md`
  - Suggested learning direction after W8

## Format Used in Each File

Each document follows the same structure:
- `Purpose`
- `What To Remember`
- `How It Applies to W8`
- `Self-Check`
- `Official Sources`

## Source Note

All notes were paraphrased from official sources reviewed on `2026-06-03`.
The original sources may change after that date.
