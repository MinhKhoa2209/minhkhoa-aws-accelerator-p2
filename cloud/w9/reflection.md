# W9 Reflection

## What Changed from W8

- W8 proved that the app can run on Kubernetes.
- W9 moves operations into Git so the cluster converges from reviewed state.
- Observability adds a feedback loop before and during releases.
- Canary delivery reduces blast radius when a new version behaves badly.

## GitOps Notes

- Desired state lives in Git.
- Argo CD reconciles the cluster to match the repository.
- A rollback should normally be a Git revert so the desired state and live state stay aligned.

## Observability Notes

- Availability and latency are the first SLIs for this app.
- Burn-rate alerts are more useful than simple error thresholds because they connect symptoms to error budget.
- Metrics need consistent labels before dashboards and alerts become reliable.

## Canary Notes

- Canary rollout is useful only when the analysis metric reflects user impact.
- Auto-abort protects the stable version when the canary fails the metric threshold.
- The lab should show both a normal promotion path and a failed canary path.
