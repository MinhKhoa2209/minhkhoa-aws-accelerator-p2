# W9 Tasklist

Use this as the working checklist for W9. Mark each item when it is done and keep short evidence in `cloud/w9/lab/evidence/` or in your reflection.

## D1 - GitOps and CI/CD, Monday 2026-06-08

### Study

- [ ] Read GitOps principles: desired state, declarative config, reconciliation, versioned changes.
- [ ] Understand Argo CD basic model: `Application`, source repo, destination cluster, sync status, health status.
- [ ] Compare Argo CD and Flux at a high level.
- [ ] Understand app-of-apps pattern.
- [ ] Understand sync waves and why resource ordering matters.
- [ ] Understand rollback options: `git revert` versus `kubectl rollout undo`.
- [ ] Review GitHub Actions basics: workflow, event, job, step, runner, action.

### Build

- [ ] Update all Argo CD `repoURL` placeholders in `cloud/w9/day-a/argocd/`.
- [ ] Validate W9 kustomize overlays locally.
- [ ] Review `cloud/w9/day-a/.github/workflows/k8s-validate.yml`.
- [ ] Install Argo CD in minikube.
- [ ] Apply `cloud/w9/day-a/argocd/app-of-apps.yaml`.
- [ ] Confirm Argo CD creates child apps.

### Evidence

- [ ] Screenshot or command output: Argo CD apps are `Synced`.
- [ ] Screenshot or command output: W8 app resources exist in `w8-day-2`.
- [ ] Short note: how GitOps changes your W8 workflow.

## D2 - Observability, SLO, SLI, OTel, Tuesday 2026-06-09

### Study

- [ ] Understand telemetry signals: metrics, logs, traces.
- [ ] Understand OpenTelemetry SDK versus Collector.
- [ ] Understand Prometheus scrape model and PromQL basics.
- [ ] Understand Grafana dashboards and panels.
- [ ] Understand Loki log aggregation at a high level.
- [ ] Understand SLI, SLO, error budget, and burn rate.
- [ ] Understand multi-window burn-rate alerting: fast page and slow ticket.

### Build

- [ ] Review `cloud/w9/day-b/otel/collector-config.yaml`.
- [ ] Review `cloud/w9/day-b/prometheus/slo-burn-rate-rules.yaml`.
- [ ] Review `cloud/w9/day-b/grafana/w8-service-dashboard.json`.
- [ ] Render `cloud/w9/lab/observability` with `kubectl kustomize`.
- [ ] Install or connect to a Prometheus/Grafana stack if available.
- [ ] Import the Grafana dashboard JSON if Grafana is running.

### Evidence

- [ ] Screenshot or command output: observability namespace/resources.
- [ ] Screenshot: Grafana dashboard or Prometheus query.
- [ ] Short note: which SLI matters most for the W8 app and why.

## D3 - Progressive Delivery and Canary, Wednesday 2026-06-10

### Study

- [ ] Understand progressive delivery and canary release.
- [ ] Understand Argo Rollouts `Rollout` versus Kubernetes `Deployment`.
- [ ] Understand canary steps: weight, pause, analysis, promotion.
- [ ] Understand `AnalysisTemplate` and Prometheus query provider.
- [ ] Understand abort criteria and failed canary behavior.
- [ ] Understand how burn-rate or success-rate metrics can protect deployment.
- [ ] Review k6 basics: scenario, VUs, duration, thresholds, checks.

### Build

- [ ] Install Argo Rollouts controller.
- [ ] Review `cloud/w9/day-c/rollout/rollout.yaml`.
- [ ] Review `cloud/w9/day-c/rollout/analysis-template.yaml`.
- [ ] Render `cloud/w9/lab/rollout` with `kubectl kustomize`.
- [ ] Run or review `cloud/w9/day-c/load-test/k6-smoke.js`.
- [ ] Trigger a canary by changing an image tag or config.
- [ ] Observe promotion or abort behavior.

### Evidence

- [ ] Command output: `kubectl get rollout announcement-app -n w8-day-2`.
- [ ] Command output: rollout status or abort event.
- [ ] k6 output or screenshot.
- [ ] Short note: what metric caused the release to continue or abort.

## Lab - Thursday 2026-06-11 and Friday 2026-06-12

### Build

- [ ] Build and load W8 image into minikube.
- [ ] Install Argo CD.
- [ ] Install Argo Rollouts.
- [ ] Install or prepare Prometheus/Grafana.
- [ ] Apply Argo CD app-of-apps.
- [ ] Confirm platform app syncs first.
- [ ] Confirm observability app syncs second.
- [ ] Confirm rollout app syncs third.
- [ ] Port-forward the service and verify `/`, `/healthz`, `/readyz`.
- [ ] Run k6 smoke test.
- [ ] Demonstrate a canary rollout.
- [ ] Demonstrate rollback or abort.

### Final Evidence

- [ ] Architecture or workflow diagram.
- [ ] Argo CD synced apps.
- [ ] Kubernetes resources in `w8-day-2`.
- [ ] Prometheus/Grafana evidence.
- [ ] Argo Rollouts evidence.
- [ ] k6 test output.
- [ ] Final reflection in `cloud/w9/reflection.md`.

## Commit Checklist

- [ ] `[W9-D1] gitops argocd app`
- [ ] `[W9-D2] observability slo alerts`
- [ ] `[W9-D3] canary rollout analysis`
- [ ] `[W9-Lab] gitops observability canary`
