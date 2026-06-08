# W9 Lab - GitOps-ify W8 Platform

## Outcome

This lab turns the W8 app into a delivery platform:
- Argo CD owns the manifests.
- The app exposes Prometheus-compatible request metrics at `/metrics`.
- Observability resources provide Prometheus scraping, SLO burn-rate rules, and a starter Grafana dashboard.
- Argo Rollouts performs canary delivery with Prometheus analysis.
- Bad releases are aborted instead of promoted.

## Prerequisites

- Docker and a local Kubernetes cluster are running, such as Docker Desktop Kubernetes or minikube.
- `kubectl` can access the target cluster.
- The W9 W8-app image exists in the local cluster runtime as `w8-announcement-app:0.1.1`.
- Argo CD and Argo Rollouts are installed.
- Prometheus Operator CRDs are installed so `PrometheusRule` can sync.
- Prometheus is installed if you want live rollout analysis instead of manifest sync only.

You can bootstrap the lab dependencies with:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode deps
```

## Steps

1. Build and load the W8 app image.

```powershell
docker build -t w8-announcement-app:0.1.1 cloud/w8/day-2/app
minikube image load w8-announcement-app:0.1.1
```

If the current context is Docker Desktop Kubernetes, the local Docker image is already visible to the cluster and `minikube image load` is not needed. The helper script handles this automatically:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1
```

2. Validate all W9 manifests.

```powershell
kubectl kustomize cloud/w9/lab/platform
kubectl kustomize cloud/w9/lab/observability
kubectl kustomize cloud/w9/lab/rollout
```

3. Confirm every Argo CD `repoURL` under `day-a/argocd` points to this repository:

```text
https://github.com/MinhKhoa2209/minhkhoa-aws-accelerator-p2.git
```

4. Apply the Argo CD root app.

```powershell
kubectl apply -f cloud/w9/day-a/argocd/app-of-apps.yaml
```

Or use the helper script to install dependencies, apply the root app, refresh Argo CD apps, and print status:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode bootstrap
```

5. Confirm sync and health.

```powershell
kubectl get applications -n argocd
kubectl get all -n w8-day-2
kubectl get all -n observability
kubectl get prometheusrule -n observability
```

If `w9-observability` or `w9-rollout` was created before the CRDs existed, refresh the apps:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode refresh
```

6. Port-forward the app.

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

Verify app and metrics endpoints:

```powershell
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/healthz
curl http://127.0.0.1:8080/readyz
curl http://127.0.0.1:8080/metrics
```

7. Run a short load test.

```powershell
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

8. Trigger a canary by changing the image tag in `lab/rollout/rollout.yaml`, committing it, and letting Argo CD sync.

Do not apply rollout manifest changes directly with `kubectl apply` as the normal path. Commit and push the desired-state change, then let Argo CD sync it.

## Evidence Checklist

- Screenshot or command output for Argo CD apps in `Synced` state.
- `kubectl get rollout announcement-app -n w8-day-2`.
- Prometheus query result for success rate or latency.
- Grafana dashboard screenshot or imported dashboard JSON.
- A short note explaining rollback behavior: Git revert for desired-state rollback, Argo Rollouts abort for failed canary.
