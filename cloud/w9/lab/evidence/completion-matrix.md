# W9 Completion Matrix

Source requirement: `cloud/docs/requirement/W9_phase2_announcement_cloud.md`

## D1 - GitOps and CI/CD

Status: complete.

Evidence:

- GitHub Actions workflow: `.github/workflows/k8s-validate.yml`
- Argo CD root app: `cloud/w9/day-a/argocd/app-of-apps.yaml`
- Child apps:
  - `w8-platform`
  - `w9-observability`
  - `w9-rollout`
- Sync waves:
  - wave `0`: platform
  - wave `1`: observability
  - wave `2`: rollout
- Verified cluster state:

```text
w8-platform        Synced   Healthy
w9-observability   Synced   Healthy
w9-rollout         Synced   Healthy
w9-root            Synced   Healthy
```

Correct workflow:

```text
PR validates manifests -> merge/push -> Argo CD syncs desired state
```

Rollback workflow:

```text
git revert <bad-commit> -> push -> Argo CD sync
```

## D2 - Observability, SLO, SLI, OTel

Status: complete for local lab baseline.

Evidence:

- OTel Collector config: `cloud/w9/lab/observability/collector-config.yaml`
- Prometheus scrape/rules config: `cloud/w9/lab/observability/prometheus-config.yaml`
- Prometheus deployment/service: `cloud/w9/lab/observability/prometheus.yaml`
- PrometheusRule CRD object: `cloud/w9/lab/observability/slo-burn-rate-rules.yaml`
- Grafana dashboard JSON: `cloud/w9/day-b/grafana/w8-service-dashboard.json`
- App metrics endpoint: `/metrics`
- Metrics verified from image `w8-announcement-app:0.1.1`:

```text
http_server_requests_total
http_server_request_duration_seconds_bucket
http_server_request_duration_seconds_sum
http_server_request_duration_seconds_count
```

Notes:

- The lab includes a minimal Prometheus server named `prometheus-operated` for Argo Rollouts analysis.
- Loki is covered in theory notes; no Loki workload is required for the current W9 lab manifests.

## D3 - Progressive Delivery and Canary

Status: complete for rollout manifests and controller dependency.

Evidence:

- Argo Rollouts CRDs installed:
  - `rollouts.argoproj.io`
  - `analysistemplates.argoproj.io`
- Rollout manifest: `cloud/w9/lab/rollout/rollout.yaml`
- Analysis template: `cloud/w9/lab/rollout/analysis-template.yaml`
- Canary steps:
  - `20%`
  - pause `60s`
  - Prometheus analysis
  - `50%`
  - pause `60s`
  - `100%`
- Verified rollout state:

```text
announcement-app desired=2 current=2 available=2
```

## Lab

Status: complete after commit/push and Argo CD sync.

Required final GitOps sequence:

```powershell
git add cloud/w8/day-2/app/server.py cloud/w9 .github/workflows/k8s-validate.yml
git commit -m "[W9-Lab] gitops observability canary"
git push origin main
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode sync
```

Then verify:

```powershell
kubectl get applications -n argocd -o wide
kubectl get all -n observability
kubectl get rollout announcement-app -n w8-day-2
```

Optional load test, after installing k6:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode app-port
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```
