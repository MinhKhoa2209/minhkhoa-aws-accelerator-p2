# W9 Monitoring Lab: EC2 CPU Alarm to SNS Email

This lab implements page 20 of `AWS_Monitoring_Xbrain.pdf`.

## Architecture

```text
EC2 CPUUtilization > 80% for one 5-minute period
  -> CloudWatch alarm
  -> SNS topic
  -> Email subscription
```

## Deployed Settings

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| EC2 name | `xbrain-monitoring-lab` |
| EC2 type | `t3.micro` |
| SNS topic | `xbrain-cpu-alerts` |
| CloudWatch alarm | `xbrain-ec2-high-cpu` |
| Namespace | `AWS/EC2` |
| Metric | `CPUUtilization` |
| Statistic | `Average` |
| Threshold | Greater than `80%` |
| Period | `300` seconds |
| Evaluation | `1` out of `1` datapoint |
| Missing data | Not breaching |
| Notifications | `ALARM` and `OK` |

The instance has no lab-specific inbound rule or SSH key. Its user data waits
10 minutes and then generates CPU load for 7 minutes, which is longer than one
alarm evaluation period.

## Verification

Confirm the AWS SNS subscription email first. Then inspect:

```powershell
aws sns list-subscriptions-by-topic `
  --profile default `
  --region us-east-1 `
  --topic-arn arn:aws:sns:us-east-1:058114477594:xbrain-cpu-alerts

aws cloudwatch describe-alarms `
  --profile default `
  --region us-east-1 `
  --alarm-names xbrain-ec2-high-cpu
```

The alarm should move from `INSUFFICIENT_DATA` or `OK` to `ALARM` while the
load runs, send an email, and later return to `OK` with a recovery email.

## How the Alarm Works

The `user-data.sh` script waits 10 minutes so that the instance, CloudWatch
metric, alarm, and SNS subscription have time to initialize. It then starts one
`yes` process for each vCPU:

```bash
cpu_count="$(nproc)"
for _ in $(seq 1 "$cpu_count"); do
  timeout 420 yes > /dev/null &
done
```

Each `yes` process continuously performs CPU work. Running one worker per vCPU
keeps the instance close to 100% CPU utilization for 420 seconds (7 minutes).
This is longer than the alarm's 300-second evaluation period, so CloudWatch
receives a complete five-minute average above the 80% threshold. With
`DatapointsToAlarm = 1` and `EvaluationPeriods = 1`, that single breaching
datapoint changes the state from `OK` to `ALARM`.

After 420 seconds, `timeout` stops every `yes` process. CPU usage returns to its
normal idle level. When CloudWatch evaluates the next five-minute datapoint and
its average is no longer greater than 80%, the same `1 out of 1` rule changes
the alarm from `ALARM` back to `OK`. Because the SNS topic is configured for
both `AlarmActions` and `OKActions`, subscribers receive an alarm email and a
recovery email.

## Lab Evidence

Verified on June 12, 2026:

- EC2 instance: `i-0c0d93a9ad9003a31` (`t3.micro`, running)
- SNS email subscription: confirmed
- SNS test message ID: `c928d64d-7998-55bc-b64f-b4e8c0de9240`
- Five-minute CPU average observed by the alarm: approximately `99.99%`
- Maximum CPU in that period: `100%`
- Final alarm state after the test: `OK`

| Evidence | File |
| --- | --- |
| CPU graph crossing the 80% threshold | [`evidence/cloudwatch-cpu-threshold-graph.png`](evidence/cloudwatch-cpu-threshold-graph.png) |
| Alarm metric and evaluation configuration | [`evidence/cloudwatch-alarm-configuration.png`](evidence/cloudwatch-alarm-configuration.png) |
| Alarm state transitions and SNS actions | [`evidence/cloudwatch-alarm-history.png`](evidence/cloudwatch-alarm-history.png) |
| Confirmed SNS email subscription | [`evidence/sns-email-subscription-confirmed.png`](evidence/sns-email-subscription-confirmed.png) |
| SNS alarm notification email | [`evidence/sns-alarm-notification-email.png`](evidence/sns-alarm-notification-email.png) |
| SNS OK recovery email | [`evidence/sns-ok-recovery-email.png`](evidence/sns-ok-recovery-email.png) |

The graph and alarm history contain the automatic metric-driven transition:
`OK -> ALARM` at `07:26:26 UTC`, followed by `ALARM -> OK` at `07:31:26 UTC`.
The alarm email screenshot at `07:37:14 UTC` is from a later manual notification
validation and is supporting evidence for the SNS delivery path, not the
primary proof of automatic threshold evaluation.

## Cleanup

After collecting evidence, remove the billable lab resources:

```powershell
.\cloud\w9\monitoring-lab\cleanup.ps1
```
