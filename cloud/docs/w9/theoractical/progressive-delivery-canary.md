# Progressive Delivery and Canary

## Purpose

This note explains progressive delivery, canary rollout, Argo Rollouts, and auto-abort behavior.

## Progressive Delivery

Progressive delivery means releasing changes gradually while using signals to decide whether to continue.

Common patterns:

- canary release
- blue-green deployment
- feature flag rollout
- traffic shadowing

## Canary Release

A canary release sends a small portion of users or replicas to the new version first.

If metrics are healthy:

- increase exposure
- continue analysis
- promote to stable

If metrics are unhealthy:

- abort rollout
- keep stable version serving
- investigate the failed version

## Argo Rollouts

Argo Rollouts extends Kubernetes deployment behavior.

Important resources:

- `Rollout`: replacement for `Deployment` with advanced rollout strategy
- `AnalysisTemplate`: reusable metric check
- `AnalysisRun`: one execution of an analysis

Important canary fields:

- `steps`: sequence of release actions
- `setWeight`: percentage or replica weight for canary
- `pause`: wait before next step
- `analysis`: metric check before continuing

## AnalysisTemplate

An `AnalysisTemplate` defines the metric query and success criteria.

W9 example:

- provider: Prometheus
- metric: success rate
- success condition: result is at least `0.99`
- failure limit: abort after too many failed checks

## Auto-Abort

Auto-abort means the rollout stops when analysis fails.

The metric must represent user impact. Good candidates:

- success rate
- error ratio
- p95 or p99 latency
- SLO burn rate

Weak candidates:

- pod count only
- CPU only
- memory only

CPU and memory are useful symptoms, but they do not directly prove user impact.

## Traffic Routing Note

Argo Rollouts can integrate with ingress controllers and service meshes for real traffic splitting. The W9 repo starter uses a simpler canary step model so it can render locally without requiring Istio, NGINX, ALB, or another traffic router.

## How It Applies to W9

- `cloud/w9/day-c/rollout/rollout.yaml` defines the canary steps.
- `cloud/w9/day-c/rollout/analysis-template.yaml` defines the Prometheus success-rate check.
- `cloud/w9/lab/rollout` is the self-contained lab overlay.

## Self-Check

- How is `Rollout` different from `Deployment`?
- What does `setWeight` do?
- What does an `AnalysisTemplate` check?
- What should happen when the canary metric fails?

## Official Sources

- https://argoproj.github.io/argo-rollouts
- https://flagger.app
- https://www.cncf.io/blog/2024/01/26/progressive-delivery/
