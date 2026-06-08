# Observability, SLO, SLI, and OpenTelemetry

## Purpose

This note explains the observability concepts needed for W9: what to measure, why to measure it, and how OpenTelemetry fits into the telemetry pipeline.

## Observability Signals

Metrics:

- numeric measurements over time
- good for dashboards and alerts
- examples: request rate, error rate, latency p95, CPU usage

Logs:

- timestamped events
- good for debugging details
- examples: request log, error stack, deployment event

Traces:

- request path across services
- good for distributed debugging
- examples: frontend request -> API -> database

## SLI

SLI means Service Level Indicator. It is a measurement of service behavior.

W9 examples:

- availability SLI: successful requests / total requests
- latency SLI: requests under 500 ms / total successful requests

## SLO

SLO means Service Level Objective. It is the target for an SLI.

W9 examples:

- availability SLO: 99 percent over 30 days
- latency SLO: 95 percent of successful requests under 500 ms

## Error Budget

Error budget is the allowed failure amount.

If the SLO is 99 percent availability, then the error budget is 1 percent. You can spend that 1 percent through failed requests, timeouts, or incidents.

## Burn Rate

Burn rate measures how quickly the service consumes error budget.

Fast burn:

- catches severe incidents quickly
- W9 window: `5m` and `1h`

Slow burn:

- catches sustained degradation
- W9 window: `30m` and `6h`

## OpenTelemetry

OpenTelemetry standardizes telemetry collection.

Main parts:

- SDK: code-level instrumentation inside the application
- Collector: receives, processes, and exports telemetry
- Receiver: accepts telemetry input
- Processor: batches, filters, or enriches data
- Exporter: sends data to Prometheus, logging backend, tracing backend, or another system

## W9 Collector Flow

```text
App instrumentation
  -> OTLP receiver
  -> batch and memory processors
  -> Prometheus exporter
  -> Prometheus scrape
  -> Grafana dashboard and alert rules
```

## Common Mistakes

- Creating dashboards before deciding SLIs.
- Alerting on CPU only instead of user-impact metrics.
- Missing consistent labels like service name, route, status code.
- Treating logs as the only observability signal.
- Defining an SLO without knowing how to measure it.

## How It Applies to W9

- `cloud/w9/day-b/otel/collector-config.yaml` defines a Collector config.
- `cloud/w9/day-b/prometheus/slo-burn-rate-rules.yaml` defines SLO alerts.
- `cloud/w9/day-b/grafana/w8-service-dashboard.json` visualizes request rate, error rate, latency, and availability.

## Self-Check

- What is the difference between SLI and SLO?
- What is error budget?
- Why do we need both fast and slow burn alerts?
- What does the OpenTelemetry Collector do?

## Official Sources

- https://opentelemetry.io/docs
- https://sre.google/sre-book/service-level-objectives
- https://sre.google/workbook/implementing-slos
- https://sre.google/workbook/alerting-on-slos
