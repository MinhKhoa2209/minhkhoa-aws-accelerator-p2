# W9 Lab Evidence

Evidence date: 2026-06-08

## Local Validation

Rendered successfully:

```powershell
kubectl kustomize cloud/w8/day-2/manifests
kubectl kustomize cloud/w9/lab/platform
kubectl kustomize cloud/w9/lab/observability
kubectl kustomize cloud/w9/lab/rollout
```

Script syntax check:

```text
PowerShell syntax OK
```

App image verification:

```text
docker build -t w8-announcement-app:0.1.1 cloud/w8/day-2/app
curl http://127.0.0.1:18081/readyz   -> ready
curl http://127.0.0.1:18081/metrics  -> http_server_requests_total and duration histogram exported
```

## Argo CD Applications

Current verified cluster output:

```text
NAME               SYNC STATUS   HEALTH STATUS
w8-platform        Synced        Healthy
w9-observability   Synced        Healthy
w9-rollout         Synced        Healthy
w9-root            Synced        Healthy
```

## Kubernetes Resources

W8 application namespace:

```text
pod/announcement-app-*   1/1   Running
pod/smoke-test-client    1/1   Running
service/announcement-service   ClusterIP   80/TCP
rollout/announcement-app       desired=2 current=2 available=2
```

Required CRDs:

```text
prometheusrules.monitoring.coreos.com
rollouts.argoproj.io
analysistemplates.argoproj.io
```

After the `0.1.1` manifest is committed and pushed, Argo CD should roll out the metrics-enabled app image and Prometheus should scrape:

```text
announcement-service.w8-day-2.svc.cluster.local:80/metrics
```

The lab overlay now includes a minimal Prometheus deployment and `prometheus-operated` service in `observability` for Argo Rollouts analysis queries.

## Load Test

`cloud/w9/day-c/load-test/k6-smoke.js` is present and validates `/readyz` with failure and latency thresholds. On this workstation, `k6` was not installed at verification time, so run it after installing k6:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode app-port
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

## GitOps Process

Normal delivery path:

```text
Edit manifest or app code
  -> commit and push to Git
  -> Argo CD detects repository change
  -> Argo CD syncs child apps by sync wave
  -> verify Synced/Healthy in Argo CD
```

Rollback path:

```text
git revert <bad-commit>
git push
Argo CD syncs the reverted desired state
```

Emergency `kubectl rollout undo` can recover runtime state quickly, but Git must be updated immediately afterward to avoid drift.
