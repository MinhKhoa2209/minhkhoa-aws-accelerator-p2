# W8-D3 - Kubernetes Scaling and Networking Prep

## Goal

Day 3 bridges the gap between the day-2 manifests and the onsite minikube lab. The focus is:
- understanding how a Deployment scales beyond a single pod
- following in-cluster traffic from `Service` to backing pods
- verifying local tooling before the onsite lab
- preparing evidence for the W8 minikube platform work

This day does not introduce a separate application. It reuses the artifacts in `cloud/w8/day-2/` so the attention stays on cluster behavior instead of YAML churn.

## Reference Material

- Deployments: https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- Horizontal scaling: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/
- Services: https://kubernetes.io/docs/concepts/services-networking/service/
- DNS for Services and Pods: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
- EndpointSlices: https://kubernetes.io/docs/concepts/services-networking/endpoint-slices/
- Network Policies: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- kubectl Cheat Sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- minikube start: https://minikube.sigs.k8s.io/docs/start/
- minikube addons: https://minikube.sigs.k8s.io/docs/commands/addons/

## Day-3 Context in This Repo

Day 3 builds on the deployment already prepared in `cloud/w8/day-2/`:
- `Deployment` with `2` replicas
- `Service` exposing the pods through a stable ClusterIP
- `NetworkPolicy` restricting ingress to same-namespace traffic
- `smoke-test-client` pod for in-cluster verification

That means day 3 is mainly about operating and inspecting a running workload.

## Scaling Concepts to Understand

Kubernetes scaling starts with the `Deployment` controller:
- `spec.replicas` declares the desired number of pods
- the controller creates or deletes pods until actual state matches desired state
- readiness probes protect the service from routing traffic to unready pods
- rolling updates let a deployment change image or config without dropping every replica at once

Important distinctions:
- manual scaling changes replica count directly with `kubectl scale`
- autoscaling with HPA reacts to metrics and requires the metrics pipeline
- scaling a broken pod template only creates more broken pods, so probes and logs still matter

## Networking Concepts to Understand

The traffic flow for this repo's sample app is:

```text
client pod -> ClusterIP Service -> label selector -> ready pods
```

Core networking points:
- pod IPs are ephemeral and should not be treated as stable entry points
- the `Service` gives consumers a stable DNS name: `announcement-service`
- the service routes only to pods matching its selector
- only ready pods are added to service endpoints
- the `NetworkPolicy` can allow or deny traffic independently of the `Service`

Useful resources to inspect:
- `kubectl get svc -n w8-day-2`
- `kubectl get endpointslice -n w8-day-2`
- `kubectl describe networkpolicy announcement-app-ingress -n w8-day-2`

## Local Setup Checklist

Before the onsite lab, confirm:
- Docker Desktop or Docker Engine is installed and running
- `kubectl version --client` succeeds
- `minikube version` succeeds
- `minikube start --driver=docker` can create a local cluster
- the day-2 image is built and loaded into minikube

Optional but useful for later:
- `minikube addons enable metrics-server`

`metrics-server` is not required for manual scaling, but it is required if you want to experiment with HPA.

## Expected Deliverables

By the end of day 3, the portfolio should clearly show:
- a completed note in `cloud/w8/day-3/README.md`
- evidence that you understand `Deployment`, `Service`, `EndpointSlice`, and `NetworkPolicy`
- a runnable command sequence for scaling and connectivity checks on minikube
- preparation for the W8 lab instead of a disconnected theory summary

## Suggested Hands-On Flow

Start the local cluster:

```powershell
minikube start --driver=docker
kubectl cluster-info
kubectl get nodes
```

Build and load the existing image:

```powershell
docker build -t w8-announcement-app:0.1.0 cloud/w8/day-2/app
minikube image load w8-announcement-app:0.1.0
```

Deploy the existing manifests:

```powershell
kubectl apply -k cloud/w8/day-2/manifests
kubectl get all -n w8-day-2
```

Scale the deployment up and watch reconciliation:

```powershell
kubectl scale deployment/announcement-app -n w8-day-2 --replicas=3
kubectl rollout status deployment/announcement-app -n w8-day-2
kubectl get pods -n w8-day-2 -o wide
```

Scale back down:

```powershell
kubectl scale deployment/announcement-app -n w8-day-2 --replicas=2
kubectl get pods -n w8-day-2
```

Inspect service discovery and endpoints:

```powershell
kubectl get svc,endpointslice -n w8-day-2
kubectl exec -n w8-day-2 smoke-test-client -- nslookup announcement-service
kubectl exec -n w8-day-2 smoke-test-client -- wget -qO- http://announcement-service
```

Test from outside the cluster:

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
curl http://127.0.0.1:8080/
```

## What to Observe

During the commands above, capture evidence for the portfolio:
- pod names change when replicas are added or removed, but the service name stays stable
- `READY` becomes important because only ready pods should receive traffic
- `EndpointSlice` contents change with replica count
- the smoke-test client succeeds because it is in the allowed namespace
- the service abstraction is cleaner than talking to pod IPs directly

Recommended evidence to keep:
- output of `kubectl get pods -n w8-day-2 -o wide`
- output of `kubectl get svc,endpointslice -n w8-day-2`
- one successful in-cluster request from `smoke-test-client`
- one short reflection on what changed when scaling from `2` to `3` replicas

## Common Failure Modes

- `ImagePullBackOff`: the local image was not loaded into minikube
- readiness probe failures: config or secret is missing, so `/readyz` stays unhealthy
- service has no endpoints: labels do not match or pods are not ready
- `nslookup` fails: cluster DNS is unhealthy or the target service name is wrong
- HPA experiments fail: `metrics-server` is not enabled

## Cleanup

```powershell
kubectl delete -k cloud/w8/day-2/manifests
minikube stop
```

## Next Step

This day is the preparation layer for the onsite lab:
- day 2 established the application and baseline manifests
- day 3 establishes operational understanding of scaling and networking
- the W8 lab extends the same ideas into a small local platform on minikube
