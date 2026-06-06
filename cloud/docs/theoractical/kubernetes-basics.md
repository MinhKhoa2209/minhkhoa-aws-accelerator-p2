# Kubernetes Basics

## Purpose

This note captures the core learning flow behind W8-D2 and W8-D3. If you want to understand what to do in order when learning Kubernetes, start here.

## Core Flow

1. create a cluster
2. deploy the application
3. explore the running resources
4. expose the application
5. scale the application
6. update or debug the application

## What To Remember

- `deploy` means placing the workload into the cluster.
- `explore` means checking the state of pods, services, and deployments.
- `expose` means creating a stable access path to the application.
- `scale` means changing desired replica count, not cloning virtual machines.
- `debug` usually starts with `get`, `describe`, `logs`, and `exec`.

## How It Applies to W8

- deploy

```powershell
kubectl apply -k cloud/w8/day-2/manifests
```

- explore

```powershell
kubectl get pods,svc -n w8-day-2
```

- expose

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

- scale

```powershell
kubectl scale deployment/announcement-app -n w8-day-2 --replicas=3
```

## Important Distinctions

- scaling adds or removes pods; it does not create more services
- the service name remains stable even when replica count changes
- rollout and update behavior are related to deployments, but they are not the same as scaling

## Self-Check

- After `kubectl apply`, which command should you run to confirm that the app is up?
- Why does scaling not change the service name?
- If the app fails, why should `logs` and `describe` be among your first checks?

## Official Sources

- `https://kubernetes.io/docs/tutorials/kubernetes-basics`
