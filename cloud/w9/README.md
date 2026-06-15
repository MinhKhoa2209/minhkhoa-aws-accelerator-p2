# W9 - Deliver Smartly

W9 upgrades the W8 Kubernetes work from manual `kubectl apply` to a delivery workflow managed through GitOps, observability, and progressive delivery.

## Goal

By the end of W9, the W8 platform should be:
- managed by Argo CD instead of ad hoc manifest application
- observable through OpenTelemetry, Prometheus, Grafana, and alert rules
- protected by canary deployment logic that aborts bad releases automatically

## Layout

```text
cloud/w9/
  day-a/      GitOps and CI/CD
  day-b/      Observability, SLOs, SLIs, and burn-rate alerts
  day-c/      Progressive delivery with Argo Rollouts
  lab/        End-to-end W9 lab over the W8 platform
  monitoring-lab/
              EC2 CPU alarm and SNS email notification lab
  cloudwatch-agent-lab/
              CloudWatch Agent metrics and logs on EC2
  root-login-alert-lab/
              CloudTrail root account activity alert through SNS
  reflection.md
```

## Suggested Order

1. Complete `day-a`: understand pull-based GitOps, Argo CD Applications, and CI checks.
2. Complete `day-b`: define service indicators, install telemetry plumbing, and add alert rules.
3. Complete `day-c`: replace a plain Deployment with an Argo Rollout and Prometheus analysis.
4. Complete `lab`: GitOps-ify the W8 app, bolt on observability, and prove canary abort behavior.
5. Complete `monitoring-lab`: monitor EC2 CPU with CloudWatch and send alarm/recovery emails through SNS.
6. Complete `cloudwatch-agent-lab`: install the CloudWatch Agent and publish EC2 memory, disk, swap, and log data.
7. Complete `root-login-alert-lab`: detect root account activity with CloudTrail, a metric filter, an alarm, and SNS.

## Lab Helper

Use the helper script to run the W9 lab workflow consistently:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1
```

Useful modes:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode validate
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode deps
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode sync
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode status
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode argo-ui
```

Evidence notes live in `cloud/w9/lab/evidence/`.

The standalone AWS monitoring lab is documented in
`cloud/w9/monitoring-lab/README.md`.

The CloudWatch Agent lab is documented in
`cloud/w9/cloudwatch-agent-lab/README.md`.

The root account login alert lab is documented in
`cloud/w9/root-login-alert-lab/README.md`.

## Study Docs

Use `cloud/docs/w9/` for the full W9 tasklist and theory notes:

- `cloud/docs/w9/tasklist.md`
- `cloud/docs/w9/online-training.md`
- `cloud/docs/w9/theoractical/`

## Daily Commit Pattern

Use short daily commits:

```text
[W9-D1] gitops argocd app
[W9-D2] observability slo alerts
[W9-D3] canary rollout analysis
[W9-Lab] gitops observability canary
```
