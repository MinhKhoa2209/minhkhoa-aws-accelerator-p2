# Cloud Docs for W9

## Purpose

W9 focuses on **Deliver Smartly**: GitOps, observability, and progressive delivery. These notes help you know what to study, what to build, and what evidence to collect for the W9 portfolio.

## Recommended Study Order

1. `tasklist.md`
2. `online-training.md`
3. `theoractical/day1.md`
4. `theoractical/gitops-cicd.md`
5. `theoractical/observability-slo-otel.md`
6. `theoractical/prometheus-grafana-loki.md`
7. `theoractical/progressive-delivery-canary.md`
8. `theoractical/load-testing.md`

## W9 Outcome

By the end of W9, your W8 Kubernetes app should be:

- GitOps-managed by Argo CD.
- Validated by CI before merge.
- Observable through metrics, logs, dashboards, and SLO thinking.
- Protected by canary rollout and metric-based auto-abort.
- Documented with commands, screenshots, and a short reflection.

## Mapping to Repo Work

- `cloud/w9/day-a`
  - GitHub Actions validation
  - Argo CD app-of-apps
  - Argo CD child Applications
- `cloud/w9/day-b`
  - OpenTelemetry Collector config
  - Prometheus burn-rate rules
  - Grafana dashboard JSON
- `cloud/w9/day-c`
  - Argo Rollouts `Rollout`
  - `AnalysisTemplate`
  - k6 smoke/load test
- `cloud/w9/lab`
  - End-to-end GitOps + observability + canary lab

## Core Ideas to Remember

- GitOps means Git is the desired state; the cluster should reconcile from Git.
- CI validates proposed state; Argo CD applies approved state.
- Rollback should normally start with `git revert`, not manual cluster edits.
- Observability is about understanding system behavior through metrics, logs, and traces.
- SLI is what you measure. SLO is the target you promise internally.
- Burn-rate alerts measure how quickly the service is consuming its error budget.
- Canary delivery reduces blast radius by exposing a new version gradually.
- Auto-abort only works if the analysis metric represents real user impact.

## Source Note

These notes are based on the W9 announcement and the official documentation links listed there. They are paraphrased study notes, not copies of the original docs.
