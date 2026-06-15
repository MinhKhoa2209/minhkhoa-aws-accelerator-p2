# W9 AWS Root Account Login Alert Lab

This lab alerts when the AWS root user successfully signs in to the Console.

```text
Root ConsoleLogin
  -> CloudTrail
  -> CloudWatch Logs metric filter
  -> Security/RootAccountLoginCount
  -> CloudWatch alarm
  -> SNS email
```

## Configuration

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| CloudTrail | `xbrain-root-login-alert-trail` |
| Log group | `/aws/cloudtrail/xbrain-root-login-alert` |
| Metric namespace | `Security` |
| Metric | `RootAccountLoginCount` |
| Alarm | `xbrain-root-login-alert-alarm` |
| Threshold | `>= 1` in one five-minute period |
| SNS topic | `xbrain-root-login-alert-notifications` |

Metric filter:

```text
{ ($.userIdentity.type = "Root") && ($.eventType = "AwsConsoleSignIn") && ($.eventName = "ConsoleLogin") && ($.responseElements.ConsoleLogin = "Success") }
```

## Evidence

| Requirement | Evidence |
| --- | --- |
| Enable CloudTrail | [`evidence/cloudtrail-logging-enabled.png`](evidence/cloudtrail-logging-enabled.png) |
| Create metric filter | [`evidence/root-login-metric-filter.png`](evidence/root-login-metric-filter.png) |
| Create alarm | [`evidence/root-login-alarm-triggered.png`](evidence/root-login-alarm-triggered.png) |
| Notify through SNS | [`evidence/sns-root-login-alert-email.png`](evidence/sns-root-login-alert-email.png) |
