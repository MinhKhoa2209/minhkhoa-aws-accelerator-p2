# W9 EC2 CPU Alarm to SNS Email Lab

This lab sends an email when EC2 CPU utilization exceeds the configured
threshold.

```text
EC2 CPUUtilization > 80% for five minutes
  -> CloudWatch alarm
  -> SNS topic
  -> email notification
```

## Configuration

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| EC2 | `xbrain-monitoring-lab` |
| Instance type | `t3.micro` |
| Alarm | `xbrain-ec2-high-cpu` |
| Metric | `AWS/EC2 CPUUtilization` |
| Statistic | `Average` |
| Threshold | Greater than `80%` |
| Period | `300` seconds |
| Evaluation | `1` out of `1` datapoint |
| SNS topic | `xbrain-cpu-alerts` |

The EC2 user data generates CPU load for seven minutes. When the five-minute
average exceeds 80%, the alarm enters `ALARM`. After the load stops and CPU
returns below the threshold, the alarm returns to `OK`.

## Verify

```powershell
aws cloudwatch describe-alarms `
  --profile default `
  --region us-east-1 `
  --alarm-names xbrain-ec2-high-cpu
```

Cleanup:

```powershell
.\cloud\w9\monitoring-lab\cleanup.ps1
```

## Verified Result

Verified on June 12, 2026:

- CPU average reached approximately `99.99%`
- alarm changed from `OK` to `ALARM`
- alarm returned from `ALARM` to `OK`
- SNS alarm and recovery notifications were delivered

## Evidence

| Requirement | Evidence |
| --- | --- |
| CPU exceeds threshold | [`evidence/cloudwatch-cpu-threshold-graph.png`](evidence/cloudwatch-cpu-threshold-graph.png) |
| Alarm configuration | [`evidence/cloudwatch-alarm-configuration.png`](evidence/cloudwatch-alarm-configuration.png) |
| Alarm state transitions | [`evidence/cloudwatch-alarm-history.png`](evidence/cloudwatch-alarm-history.png) |
| SNS subscription | [`evidence/sns-email-subscription-confirmed.png`](evidence/sns-email-subscription-confirmed.png) |
| Alarm email | [`evidence/sns-alarm-notification-email.png`](evidence/sns-alarm-notification-email.png) |
| Recovery email | [`evidence/sns-ok-recovery-email.png`](evidence/sns-ok-recovery-email.png) |
