# W9-D1 - GitOps and CI/CD

## Goal

Day A introduces GitOps as the delivery model for the W8 Kubernetes app. The key shift is that Git becomes the desired state and Argo CD reconciles the cluster to match it.

## Concepts

- CI checks validate manifests before merge.
- CD is pull-based: Argo CD watches Git and applies approved desired state.
- Rollback usually starts with Git history, such as `git revert`.
- `kubectl rollout undo` is useful for emergency runtime recovery, but it creates drift if Git is not updated.
- App-of-apps lets a root Argo CD Application manage multiple child Applications.
- Sync waves control ordering when one resource must exist before another.

## Files

```text
day-a/
  .github/workflows/
    k8s-validate.yml
  argocd/
    app-of-apps.yaml
    w8-platform-app.yaml
    w9-observability-app.yaml
    w9-rollout-app.yaml
```

## Local Validation

Render the W8 app manifests:

```powershell
kubectl kustomize cloud/w8/day-2/manifests
```

Render the W9 lab platform overlay:

```powershell
kubectl kustomize cloud/w9/lab/platform
```

## Argo CD Bootstrap

Install Argo CD in a local cluster:

```powershell
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available deployment/argocd-server -n argocd --timeout=180s
```

Apply the root app after updating `repoURL` in `argocd/app-of-apps.yaml`:

```powershell
kubectl apply -f cloud/w9/day-a/argocd/app-of-apps.yaml
```

## Evidence to Capture

- Argo CD root app is `Synced` and `Healthy`.
- Child apps exist for platform, observability, and rollout.
- A manifest change merged to Git is reflected by Argo CD sync.
- Rollback is demonstrated through Git revert.
