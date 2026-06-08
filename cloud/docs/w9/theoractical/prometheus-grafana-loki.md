# Prometheus, Grafana, and Loki

## Purpose

This note covers the monitoring stack mentioned in W9: Prometheus for metrics, Grafana for dashboards, and Loki for logs.

## Prometheus

Prometheus is a metrics database and alerting system.

Important concepts:

- target: endpoint Prometheus scrapes
- scrape interval: how often metrics are collected
- metric name: measurement name
- label: key-value metadata attached to a metric
- PromQL: query language for metrics
- alert rule: PromQL condition that triggers an alert

Example PromQL:

```promql
sum(rate(http_server_requests_total[5m]))
```

This calculates request rate over the last 5 minutes.

## Labels

Labels make metrics useful.

Good labels:

- `service_name`
- `route`
- `method`
- `status_code`

Risky labels:

- user ID
- request ID
- full URL with unbounded values

High-cardinality labels can make Prometheus expensive and slow.

## Grafana

Grafana visualizes data from datasources such as Prometheus and Loki.

Important concepts:

- datasource: Prometheus, Loki, CloudWatch, etc.
- dashboard: collection of panels
- panel: one chart/table/stat
- variable: reusable dashboard filter

W9 dashboard panels:

- request rate
- error rate
- latency p95
- availability SLI

## Loki

Loki stores and queries logs. It is commonly used with Grafana.

Important concepts:

- log stream: logs with the same label set
- labels: metadata for finding logs
- LogQL: query language for logs

Example LogQL:

```logql
{app="announcement-app"} |= "error"
```

## Metrics vs Logs

Use metrics when:

- you need alerts
- you need trends
- you need SLO calculation

Use logs when:

- you need exact error details
- you need request context
- you need debugging evidence

## How It Applies to W9

- Prometheus evaluates the canary success-rate query.
- PrometheusRule defines burn-rate alerts.
- Grafana dashboard shows service health.
- Loki is optional for the current repo but part of the W9 theory scope.

## Self-Check

- What does `rate()` do in PromQL?
- Why are labels important?
- What dashboard panels are required for this app?
- When would you use Loki instead of Prometheus?

## Official Sources

- https://prometheus.io/docs
- https://grafana.com/docs/grafana/latest
- https://grafana.com/docs/loki/latest
