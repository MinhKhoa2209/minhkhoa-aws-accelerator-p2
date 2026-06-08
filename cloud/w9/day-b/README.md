# W9-D2 - Observability, SLOs, and Burn Rate

## Goal

Day B defines a small observability baseline for the W8 app:
- service-level indicators for availability and latency
- OpenTelemetry Collector plumbing
- Prometheus alert rules for SLO burn rate
- a starter Grafana dashboard

## SLI and SLO

For the W8 announcement service:

- Availability SLI: successful HTTP requests divided by total HTTP requests.
- Latency SLI: percentage of successful requests under 500 ms.
- Availability SLO: 99.0 percent over 30 days.
- Latency SLO: 95.0 percent of successful requests under 500 ms over 30 days.

The example alert rules use multi-window burn-rate logic:

- Fast page: high burn over `5m` and `1h`.
- Slow ticket: sustained burn over `30m` and `6h`.

## Files

```text
day-b/
  otel/collector-config.yaml
  prometheus/slo-burn-rate-rules.yaml
  grafana/w8-service-dashboard.json
```

## Install PrometheusRule CRD

The lab overlay uses `kind: PrometheusRule`, which is provided by the Prometheus Operator CRDs. Install the CRDs before expecting the Argo CD `w9-observability` app to sync successfully:

```powershell
kubectl apply -f https://github.com/prometheus-operator/prometheus-operator/releases/latest/download/stripped-down-crds.yaml
kubectl wait --for=condition=Established crd/prometheusrules.monitoring.coreos.com --timeout=180s
```

The helper script runs this as part of dependency bootstrap:

```powershell
.\cloud\w9\scripts\run-gitops-lab.ps1 -Mode deps
```

## Lab Prometheus

The lab overlay includes a minimal Prometheus deployment in `cloud/w9/lab/observability`:

- `prometheus-config.yaml` defines scrape config for `announcement-service.w8-day-2.svc.cluster.local:80/metrics`.
- `prometheus.yaml` creates a Prometheus deployment and `prometheus-operated` service on port `9090`.
- `slo-burn-rate-rules.yaml` keeps the Prometheus Operator `PrometheusRule` form for compatibility with operator-based stacks.

The W8 app exports Prometheus-compatible metrics at `/metrics`, including:

- `http_server_requests_total`
- `http_server_request_duration_seconds_bucket`
- `http_server_request_duration_seconds_sum`
- `http_server_request_duration_seconds_count`

## Notes

The alert queries assume standard HTTP request metrics named `http_server_request_duration_seconds_bucket` and `http_server_requests_total`. If the app exposes different metric names, update the PromQL labels and metric names before using the rules.
