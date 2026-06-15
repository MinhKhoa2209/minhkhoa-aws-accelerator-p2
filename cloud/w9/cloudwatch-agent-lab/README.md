# W9 CloudWatch Agent on EC2 Lab

This lab installs and runs the CloudWatch Agent on EC2.

```text
EC2 with IAM role
  -> install and configure CloudWatch Agent
  -> start and enable agent
  -> publish memory, disk, and swap metrics to CWAgent
```

## Configuration

| Setting | Value |
| --- | --- |
| Region | `us-east-1` |
| EC2 | `xbrain-cloudwatch-agent-ec2` |
| Instance type | `t3.micro` |
| IAM policy | `CloudWatchAgentServerPolicy` |
| Metric namespace | `CWAgent` |
| Metrics | Memory, disk, and swap |
| Collection interval | `60` seconds |
| Access | SSM Session Manager |

## Commands

Deploy:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\deploy.ps1
```

Verify:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\verify.ps1
```

Cleanup:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\cleanup.ps1
```

## Verified Result

Verified on June 12, 2026:

- EC2 instance running with the required IAM role
- SSM agent online and connected
- CloudWatch Agent `running`, `configured`, `enabled`, and `active`
- `mem_used_percent`, `disk_used_percent`, and `swap_used_percent` published

## Evidence

| Requirement | Evidence |
| --- | --- |
| EC2 and IAM role | [`evidence/ec2-instance-and-iam-role.png`](evidence/ec2-instance-and-iam-role.png) |
| Agent connectivity | [`evidence/ssm-session-manager-online.png`](evidence/ssm-session-manager-online.png) |
| `CWAgent` metrics | [`evidence/cloudwatch-cwagent-namespace.png`](evidence/cloudwatch-cwagent-namespace.png) |
| Disk metric collection | [`evidence/cloudwatch-disk-metrics.png`](evidence/cloudwatch-disk-metrics.png) |
