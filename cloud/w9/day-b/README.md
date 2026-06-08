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

## Notes

The alert queries assume standard HTTP request metrics named `http_server_request_duration_seconds_bucket` and `http_server_requests_total`. If the app exposes different metric names, update the PromQL labels and metric names before using the rules.
