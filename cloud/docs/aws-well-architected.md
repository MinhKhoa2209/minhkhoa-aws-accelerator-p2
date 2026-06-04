# AWS Well-Architected

## Purpose

This note is here to reinforce an important mindset: in cloud work, it is not enough for a system to run. It also needs to be secure, maintainable, efficient, and recoverable.

## The Six Pillars To Remember

- operational excellence
- security
- reliability
- performance efficiency
- cost optimization
- sustainability

## Quick Interpretation of Each Pillar

- `operational excellence`
  - the system should be easy to operate, standardize, and improve
- `security`
  - protect access, separate sensitive data, and minimize privilege
- `reliability`
  - the system should recover well and route traffic correctly
- `performance efficiency`
  - use resources appropriately
- `cost optimization`
  - avoid waste and clean up what you no longer need
- `sustainability`
  - design with intentional and efficient resource usage

## How It Applies to W8

- `configmap.yaml` and `secret.yaml`
  - security and operational separation
- `deployment.yaml`
  - probes, resources, and rollout behavior
- `cloud/w8/day-3/README.md`
  - scale, service stability, and operability

## If You Only Remember Three Things

- configuration and secrets should not be mixed casually
- a pod that is not `Ready` should not receive traffic
- after each lab, clean up and review what was learned

## Self-Check

- Which pillar do probes support most directly?
- Why is cleanup part of cost optimization?
- Why does separating `Secret` and `ConfigMap` improve system quality?

## Official Sources

- `https://aws.amazon.com/architecture/well-architected`
