# minhkhoa-aws-accelerator-p2

Cloud/DevOps portfolio repository for Phase 2 of the AWS Accelerator track.

The repository documents weekly learning, hands-on labs, infrastructure code, Kubernetes manifests, GitOps configuration, observability resources, and evidence collected during the track.

## Current Focus

The active Phase 2 work is organized around:

- Terraform foundations and AWS infrastructure automation
- Kubernetes fundamentals, application packaging, services, probes, configuration, and network policy
- AWS-hosted Kubernetes lab infrastructure built with Terraform
- GitOps delivery with Argo CD
- Observability with OpenTelemetry, Prometheus, Grafana, SLOs, and alert rules
- Progressive delivery with Argo Rollouts and canary analysis
- Weekly reflections and portfolio evidence

## Repository Structure

```text
cloud/
  docs/
    requirement/       Mentor briefs and weekly requirements
    w8/                Week 8 study notes and supporting docs
    w9/                Week 9 study notes and supporting docs
  w8/
    day-1/             Terraform foundations
    day-2/             Kubernetes container and orchestration basics
    day-3/             Kubernetes scaling and networking
    lab-terraform/     AWS Terraform lab
    k8s-project/       Kubernetes-on-AWS project with Terraform, EC2, minikube, and ALB
    reflection.md
  w9/
    day-a/             GitOps and CI/CD with Argo CD
    day-b/             Observability, SLOs, SLIs, and burn-rate alerts
    day-c/             Progressive delivery with Argo Rollouts
    lab/               End-to-end GitOps, observability, and canary lab
    scripts/           Helper scripts for the W9 lab workflow
    reflection.md
  w10/                 Week 10 placeholder
capstone/
  w11/
  w12/
```

## Main Deliverables

### Week 8

- Terraform foundation notes: `cloud/w8/day-1/README.md`
- Terraform basics sandbox: `cloud/w8/day-1/terraform-basics/`
- Kubernetes foundation notes: `cloud/w8/day-2/README.md`
- Kubernetes scaling and networking notes: `cloud/w8/day-3/README.md`
- AWS Terraform lab: `cloud/w8/lab-terraform/`
- Kubernetes-on-AWS project: `cloud/w8/k8s-project/`
- Week 8 reflection: `cloud/w8/reflection.md`

### Week 9

- W9 overview and workflow: `cloud/w9/README.md`
- GitOps and Argo CD manifests: `cloud/w9/day-a/`
- Observability resources: `cloud/w9/day-b/`
- Progressive delivery resources: `cloud/w9/day-c/`
- End-to-end lab: `cloud/w9/lab/`
- Evidence and completion matrix: `cloud/w9/lab/evidence/`
- Week 9 reflection: `cloud/w9/reflection.md`

## Useful Commands

Run the W9 GitOps lab helper:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1
```

Validate W9 lab manifests:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode validate
```

Bootstrap W9 lab dependencies and Argo CD apps:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode bootstrap
```

Run Terraform checks from a Terraform project directory:

```powershell
terraform fmt -recursive
terraform validate
```

## References

- Week 8 mentor brief: `cloud/docs/requirement/W8_phase2_announcement_cloud.md`
- Week 9 mentor brief: `cloud/docs/requirement/W9_phase2_announcement_cloud.md`
