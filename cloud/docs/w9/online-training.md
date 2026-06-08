# W9 Online Training Plan

## Monday - D1 GitOps and CI/CD

### Learning Goals

- Explain why GitOps uses Git as desired state.
- Explain how Argo CD reconciles cluster state.
- Explain what CI should validate before merge.
- Explain how rollback works when Git owns desired state.

### Study Flow

1. Read GitOps principles.
2. Read Argo CD getting started.
3. Read Argo CD app-of-apps pattern.
4. Read GitHub Actions workflow basics.
5. Review the W9 Argo CD manifests in `cloud/w9/day-a/argocd`.

### Practice

```powershell
kubectl kustomize cloud\w9\lab\platform
kubectl kustomize cloud\w9\lab\observability
kubectl kustomize cloud\w9\lab\rollout
```

### Self-Check

- What is the difference between CI and CD in this W9 repo?
- Why is `git revert` usually better than manually changing the cluster?
- What does Argo CD show when live state differs from Git?

## Tuesday - D2 Observability

### Learning Goals

- Distinguish metrics, logs, and traces.
- Explain OpenTelemetry SDK and Collector.
- Define availability and latency SLIs for the W8 service.
- Explain error budget and burn-rate alerting.

### Study Flow

1. Read OpenTelemetry concepts.
2. Read Prometheus basics and PromQL basics.
3. Read Grafana dashboard concepts.
4. Read Google SRE SLO chapter.
5. Read multi-window burn-rate alerting.
6. Review the W9 Prometheus rules and Grafana dashboard.

### Practice

```powershell
kubectl kustomize cloud\w9\lab\observability
```

If Prometheus is running, test the success-rate query from the `AnalysisTemplate`.

### Self-Check

- What is an SLI?
- What is an SLO?
- Why are burn-rate alerts better than a raw error-count alert?
- What metrics must the app expose before the dashboard is useful?

## Wednesday - D3 Progressive Delivery

### Learning Goals

- Explain canary release and why it reduces blast radius.
- Explain Argo Rollouts `Rollout` and `AnalysisTemplate`.
- Explain how Prometheus analysis can abort a bad deployment.
- Understand k6 checks and thresholds.

### Study Flow

1. Read Argo Rollouts concepts.
2. Read Argo Rollouts analysis docs.
3. Review `cloud/w9/day-c/rollout/rollout.yaml`.
4. Review `cloud/w9/day-c/rollout/analysis-template.yaml`.
5. Review `cloud/w9/day-c/load-test/k6-smoke.js`.

### Practice

```powershell
kubectl kustomize cloud\w9\lab\rollout
```

If Argo Rollouts is installed:

```powershell
kubectl argo rollouts get rollout announcement-app -n w8-day-2 --watch
```

### Self-Check

- What happens at each canary step?
- Which metric decides whether the canary is healthy?
- What should you capture as evidence for auto-abort?

## Thursday and Friday - Lab

### Learning Goals

- Combine GitOps, observability, and canary into one workflow.
- Show that the cluster is managed by Argo CD.
- Show that a deployment can be evaluated by metrics.
- Show that a bad release can be stopped before full promotion.

### Practice Flow

1. Build and load the W8 image.
2. Install Argo CD and Argo Rollouts.
3. Apply app-of-apps.
4. Validate app health.
5. Run load test.
6. Trigger canary.
7. Capture evidence.
8. Write reflection.
