# Load Testing with k6 and Vegeta

## Purpose

This note covers the load-testing basics needed for the W9 lab. The goal is not maximum traffic. The goal is producing enough request data to validate health checks, dashboards, and canary analysis.

## Why Load Test in W9

Load testing helps you:

- generate traffic for Prometheus and Grafana
- verify readiness and health endpoints
- test error-rate and latency thresholds
- observe canary behavior under traffic

## k6 Concepts

- VU: virtual user
- duration: how long the test runs
- check: assertion on a response
- threshold: pass/fail rule for metrics
- scenario: execution model for a test

W9 smoke test:

```javascript
export const options = {
  vus: 5,
  duration: "2m",
  thresholds: {
    http_req_failed: ["rate<0.01"],
    http_req_duration: ["p(95)<500"]
  }
};
```

This means:

- run 5 virtual users
- run for 2 minutes
- fail if more than 1 percent of requests fail
- fail if p95 latency is 500 ms or higher

## Running the W9 Test

Port-forward the service:

```powershell
kubectl port-forward -n w8-day-2 svc/announcement-service 8080:80
```

Run k6:

```powershell
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

With a custom URL:

```powershell
$env:BASE_URL="http://127.0.0.1:8080"
k6 run cloud/w9/day-c/load-test/k6-smoke.js
```

## Vegeta

Vegeta is another CLI load-testing tool. It is useful for quick HTTP attack/rate tests.

Example shape:

```powershell
echo "GET http://127.0.0.1:8080/readyz" | vegeta attack -duration=60s -rate=5 | vegeta report
```

## What To Capture

- total requests
- failure rate
- p95 latency
- test duration
- target endpoint
- whether the rollout was stable, canarying, or aborted

## Common Mistakes

- Running load before port-forward is active.
- Testing `/` only and forgetting readiness.
- Using too much traffic for a local minikube cluster.
- Treating a smoke test as a production capacity test.
- Ignoring failed threshold output.

## Self-Check

- What is a VU?
- What does `http_req_failed` measure?
- Why does W9 use thresholds?
- What evidence should be included after a k6 run?

## Official Sources

- https://k6.io/docs
- https://github.com/tsenart/vegeta
