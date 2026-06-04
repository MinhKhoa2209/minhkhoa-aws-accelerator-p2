# kubectl and minikube

## Purpose

This note provides the minimum local setup and command set required to run W8-D2 and W8-D3 on your own machine.

## What To Remember

- `kubectl` is the primary tool for interacting with a Kubernetes cluster.
- `minikube` is a local Kubernetes environment for learning and development.
- Docker must be stable before minikube will be reliable.
- If you cannot use `get`, `describe`, `logs`, and `exec`, debugging will be slow and painful.
- Scaling, rollout checks, and port-forwarding are core operations in W8.

## Minimum Setup Checklist

```powershell
kubectl version --client
minikube version
minikube start --driver=docker
kubectl cluster-info
kubectl get nodes
```

If these commands are not working, do not move on to application deployment yet.

## Local W8 Flow

```powershell
docker build -t w8-announcement-app:0.1.0 cloud/w8/day-2/app
minikube image load w8-announcement-app:0.1.0
kubectl apply -k cloud/w8/day-2/manifests
kubectl get all -n w8-day-2
```

## Commands You Should Be Comfortable With

```powershell
kubectl get pods -n w8-day-2 -o wide
kubectl describe deployment announcement-app -n w8-day-2
kubectl logs -n w8-day-2 deployment/announcement-app
kubectl exec -n w8-day-2 smoke-test-client -- wget -qO- http://announcement-service
kubectl scale deployment/announcement-app -n w8-day-2 --replicas=3
kubectl rollout status deployment/announcement-app -n w8-day-2
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
kubectl delete -k cloud/w8/day-2/manifests
```

## How To Think About the Commands

- `get` gives a quick status view
- `describe` gives detailed state and recent events
- `logs` shows what the application is reporting
- `exec` lets you test networking from inside the cluster
- `scale` changes desired replica count
- `port-forward` lets you test the service from your local machine

## Self-Check

- What is the difference between `get` and `describe`?
- If the app does not respond, which command should you check first and why?
- Why is `exec` from `smoke-test-client` often more informative than only curling from your laptop?

## Official Sources

- `https://kubernetes.io/docs/reference/kubectl/cheatsheet`
- `https://kubernetes.io/docs/tasks/tools/`
- `https://minikube.sigs.k8s.io/docs/start`
