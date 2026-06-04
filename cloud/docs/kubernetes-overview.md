# Kubernetes Overview

## Purpose

This note gives you the minimum Kubernetes model you need for W8. You do not need to learn the entire platform at once; you need to understand the objects that directly affect the application in this repo.

## What To Remember

- A `Pod` is the unit that runs containers in Kubernetes.
- A `Deployment` manages rollout behavior and replica count for stateless applications.
- A `Service` provides a stable endpoint instead of forcing consumers to rely on pod IPs.
- An `EndpointSlice` shows which pods a service currently routes to.
- A `NetworkPolicy` controls traffic between workloads.
- `readiness`, `liveness`, and `startup` probes help Kubernetes understand pod health and availability.

## How To Think About It

- Pods can be recreated, so pod IPs are not stable design targets.
- Because pod IPs are unstable, consumers should usually talk to a `Service`.
- A `Deployment` does not route traffic. A `Service` does.
- A `NetworkPolicy` does not create endpoints. It only allows or denies traffic.

## How It Applies to W8

- `cloud/w8/day-2/manifests/deployment.yaml`
  - replicas, image, probes, and resources
- `cloud/w8/day-2/manifests/service.yaml`
  - selector and port mapping
- `cloud/w8/day-2/manifests/networkpolicy.yaml`
  - ingress control
- `cloud/w8/day-3/README.md`
  - scaling behavior and service-level observation

## If You Only Remember Three Things

- A pod is the workload instance.
- A service is the stable endpoint.
- A deployment is the object you scale and roll out.

## Self-Check

- Why should you avoid designing around direct pod IP access?
- What is the difference between a `Deployment` and a `Service`?
- How does a readiness probe affect traffic flow?

## Official Sources

- `https://kubernetes.io/docs`
