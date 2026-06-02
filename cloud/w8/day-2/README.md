# W8-D2 — Kubernetes Container / Orchestration Foundations

## Goal

Day 2 turns the Kubernetes theory into a small but complete local deployment for minikube. The deliverable includes:
- a tiny application container
- Kubernetes manifests for namespace, configuration, secret, deployment, service, and network policy
- health probes
- a smoke-test client

Everything in this folder is in English and ready to run locally.

## Reference Material

- Pods: https://kubernetes.io/docs/concepts/workloads/pods/
- Services: https://kubernetes.io/docs/concepts/services-networking/service/
- Probes: https://kubernetes.io/docs/concepts/workloads/pods/probes/
- ConfigMaps: https://kubernetes.io/docs/concepts/configuration/configmap/
- Secrets: https://kubernetes.io/docs/concepts/configuration/secret/
- NetworkPolicies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Kubernetes Basics: https://kubernetes.io/docs/tutorials/kubernetes-basics/
- Install kubectl: https://kubernetes.io/docs/tasks/tools/
- minikube start: https://minikube.sigs.k8s.io/docs/start/
- Docker install: https://docs.docker.com/get-docker/

## Directory Layout

```text
cloud/w8/day-2/
  app/
    Dockerfile
    server.py
  manifests/
    kustomization.yaml
    namespace.yaml
    configmap.yaml
    secret.yaml
    deployment.yaml
    service.yaml
    networkpolicy.yaml
    smoke-test-client.yaml
```

## What the Example Demonstrates

This example maps directly to the day-2 learning objectives:
- `Pod` and `Deployment`: the application runs as a replicated deployment
- `Service`: the deployment is exposed through a stable ClusterIP service
- `ConfigMap`: non-sensitive runtime configuration is injected through environment variables
- `Secret`: a sensitive token is injected separately and checked by the readiness probe
- `Probes`: startup, liveness, and readiness checks are configured
- `NetworkPolicy`: ingress is restricted to clients from the same namespace

## Application Behavior

The application is a minimal Python HTTP server that exposes:
- `/`: returns application metadata as JSON
- `/healthz`: always returns `200 OK`
- `/readyz`: returns `200 OK` only when the required config and secret are present

This gives the probes a meaningful target and makes it easy to inspect runtime configuration.

## Build the Image

Build the local container image:

```powershell
docker build -t w8-announcement-app:0.1.0 cloud/w8/day-2/app
```

If you are using minikube with the Docker driver, load the image into the cluster:

```powershell
minikube image load w8-announcement-app:0.1.0
```

## Deploy to minikube

Apply the manifests with kustomize support built into `kubectl`:

```powershell
kubectl apply -k cloud/w8/day-2/manifests
```

## Verify the Deployment

Check the namespace resources:

```powershell
kubectl get all -n w8-day-2
kubectl get configmap,secret,networkpolicy -n w8-day-2
```

Port-forward the service locally:

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

Then test the endpoints:

```powershell
curl http://127.0.0.1:8080/
curl http://127.0.0.1:8080/healthz
curl http://127.0.0.1:8080/readyz
```

## Smoke Test from Inside the Namespace

An optional debug pod is included for service-level testing:

```powershell
kubectl exec -n w8-day-2 smoke-test-client -- wget -qO- http://announcement-service
```

Because the `NetworkPolicy` only allows ingress from pods in the same namespace, this smoke client is a convenient way to confirm that the policy still allows intended traffic.

## Cleanup

```powershell
kubectl delete -k cloud/w8/day-2/manifests
```

## Notes

- The secret is intentionally used only as a runtime dependency and is not returned by the application.
- The image uses port `8080` internally so it can run cleanly as a non-root user.
- The service exposes port `80` for a more natural cluster-facing interface.
