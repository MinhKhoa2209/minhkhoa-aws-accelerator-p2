# GitOps and CI/CD

## Purpose

This note covers the W9 GitOps foundation: how Git, CI, and Argo CD work together to deploy Kubernetes changes safely.

## What To Remember

- GitOps treats Git as the source of truth for desired state.
- The cluster should be reconciled from Git, not manually edited as the normal workflow.
- CI validates a proposed change before it is merged.
- Argo CD watches Git and syncs the cluster after the desired state changes.
- Drift means live cluster state differs from Git.
- Self-heal means Argo CD can move live state back to Git state.
- Prune means Argo CD can remove resources that were deleted from Git.

## Core Argo CD Objects

- `Application`: connects a Git path to a Kubernetes destination.
- `Project`: groups Applications and can restrict allowed repos/clusters/namespaces.
- `Source`: repo URL, revision, and manifest path.
- `Destination`: target cluster and namespace.
- `SyncPolicy`: manual or automated sync behavior.

## App-of-Apps

App-of-apps means one root Argo CD Application manages other Argo CD Applications.

Use it when:

- one repo contains multiple apps or components
- you need one entry point for platform bootstrap
- you want Argo CD to manage its own child app definitions

In W9:

- root app: `w9-root`
- child app 1: `w8-platform`
- child app 2: `w9-observability`
- child app 3: `w9-rollout`

## Sync Waves

Sync waves are ordering hints. Lower wave numbers sync first.

In W9:

- wave `0`: platform resources
- wave `1`: observability resources
- wave `2`: rollout resources

This order matters because the rollout expects platform config and services to exist, while analysis expects Prometheus to exist.

## CI/CD Boundary

CI should answer: "Is this change valid enough to merge?"

Examples:

- render kustomize overlays
- validate YAML
- run tests
- check policy or lint rules

CD should answer: "How does the cluster converge to approved desired state?"

In W9, Argo CD handles CD by syncing from Git.

## Rollback

Preferred GitOps rollback:

```powershell
git revert <bad-commit>
git push
```

Emergency runtime rollback:

```powershell
kubectl rollout undo deployment/<name> -n <namespace>
```

The emergency option can create drift. If you use it, update Git afterward.

## How It Applies to W9

- Update `repoURL` in `cloud/w9/day-a/argocd`.
- Let Argo CD sync `cloud/w9/lab/platform`, `observability`, and `rollout`.
- Use Git commits to change desired state.
- Use Argo CD status as evidence that GitOps is working.

## Self-Check

- What is desired state?
- What is drift?
- What does Argo CD do when Git and cluster disagree?
- Why should rollback usually happen through Git?

## Official Sources

- https://opengitops.dev
- https://argo-cd.readthedocs.io
- https://docs.github.com/en/actions
- https://fluxcd.io/flux
