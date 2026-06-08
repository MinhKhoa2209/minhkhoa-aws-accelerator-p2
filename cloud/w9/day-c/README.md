# W9-D3 - Progressive Delivery with Canary

## Goal

Day C replaces a plain Deployment rollout with an Argo Rollouts canary. The canary gradually shifts traffic and runs Prometheus checks before promotion.

## Concepts

- `Rollout` is a controller resource that manages ReplicaSets like a Deployment, but with advanced strategies.
- `AnalysisTemplate` defines checks, such as success rate or latency.
- Canary steps control traffic or replica weight over time.
- Auto-abort prevents a bad version from reaching full traffic.

## Files

```text
day-c/
  rollout/rollout.yaml
  rollout/analysis-template.yaml
  load-test/k6-smoke.js
```

## Install Argo Rollouts

```powershell
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
kubectl wait --for=condition=Established crd/rollouts.argoproj.io --timeout=180s
kubectl wait --for=condition=Established crd/analysistemplates.argoproj.io --timeout=180s
kubectl wait --for=condition=available deployment/argo-rollouts -n argo-rollouts --timeout=180s
```

The helper script runs this as part of dependency bootstrap:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode deps
```

## Apply Example

```powershell
kubectl apply -f cloud/w9/day-c/rollout/analysis-template.yaml
kubectl apply -f cloud/w9/day-c/rollout/rollout.yaml
kubectl argo rollouts get rollout announcement-app -n w8-day-2 --watch
```

## Trigger a Canary

Change the image tag in `rollout.yaml`, commit it, and let Argo CD sync. If the Prometheus analysis fails, Argo Rollouts should abort the rollout.
