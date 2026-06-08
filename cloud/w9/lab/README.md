# W9 Lab - GitOps-ify W8 Platform

## Outcome

This lab turns the W8 app into a delivery platform:
- Argo CD owns the manifests.
- Observability resources define the basic telemetry contract.
- Argo Rollouts performs canary delivery with Prometheus analysis.
- Bad releases are aborted instead of promoted.

## Prerequisites

- Docker and minikube are running.
- `kubectl` can access the minikube cluster.
- The W8 image exists in minikube: `w8-announcement-app:0.1.0`.
- Argo CD and Argo Rollouts are installed.
- Prometheus is installed if you want live analysis instead of manifest validation only.

## Steps

1. Build and load the W8 app image.

```powershell
docker build -t w8-announcement-app:0.1.0 cloud/w8/day-2/app
minikube image load w8-announcement-app:0.1.0
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

5. Confirm sync and health.

```powershell
kubectl get applications -n argocd
kubectl get all -n w8-day-2
```

6. Port-forward the app.

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

7. Run a short load test.

```powershell
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

8. Trigger a canary by changing the image tag in `lab/rollout/rollout.yaml`, committing it, and letting Argo CD sync.

## Evidence Checklist

- Screenshot or command output for Argo CD apps in `Synced` state.
- `kubectl get rollout announcement-app -n w8-day-2`.
- Prometheus query result for success rate or latency.
- Grafana dashboard screenshot or imported dashboard JSON.
- A short note explaining rollback behavior: Git revert for desired-state rollback, Argo Rollouts abort for failed canary.
