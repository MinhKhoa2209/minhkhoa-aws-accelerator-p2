# W9 CloudWatch Agent on EC2 Lab

This lab implements the CloudWatch Agent installation workflow from
`AWS_Monitoring_Xbrain.pdf`:

1. Install the CloudWatch Agent package.
2. Configure the agent.
3. Enable and start the service.
4. Verify the agent status.

Terraform makes the lab reproducible and creates the IAM prerequisite that the
manual procedure assumes already exists.

## Architecture

```text
Terraform
  -> IAM role and instance profile
     -> CloudWatchAgentServerPolicy
     -> AmazonSSMManagedInstanceCore
  -> Amazon Linux 2023 EC2
     -> user data installs and starts CloudWatch Agent
     -> memory, disk, and swap metrics -> CWAgent namespace
     -> cloud-init output -> CloudWatch Logs
  -> SSM Run Command verifies the service without SSH
```

The security group has no inbound rules. Administration and verification use
AWS Systems Manager, so the lab does not require an SSH key.

## Slide-to-Lab Mapping

| Slide step | Lab implementation |
| --- | --- |
| Install package | `dnf install -y amazon-cloudwatch-agent` in `user-data.sh.tftpl` |
| Run configuration wizard | Version-controlled `cloudwatch-agent-config.json.tftpl` |
| Start agent | `amazon-cloudwatch-agent-ctl -a fetch-config -s` |
| Enable agent | `systemctl enable amazon-cloudwatch-agent` |
| Check status | `scripts/verify.ps1` invokes `amazon-cloudwatch-agent-ctl -a status` through SSM |
| IAM prerequisite | Terraform attaches `CloudWatchAgentServerPolicy` to the EC2 role |

The JSON config replaces the interactive wizard so the selected settings can be
reviewed, repeated, and changed through Git.

## Collected Data

The agent publishes every 60 seconds:

- `mem_used_percent`
- `disk_used_percent`
- `swap_used_percent`
- `/var/log/cloud-init-output.log`

Metrics use the `CWAgent` namespace. Logs use
`/xbrain-cloudwatch-agent/cloud-init` with seven-day retention.

## Deploy

From the repository root:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\deploy.ps1
```

The script runs `terraform init`, `terraform apply`, waits for SSM, checks the
agent service, and confirms that `CWAgent` metrics exist.

To run only verification:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\verify.ps1
```

## Verified Result

Verified in `us-east-1` on June 12, 2026:

| Check | Result |
| --- | --- |
| EC2 instance | `i-059488135b121ddcf`, `t3.micro`, running |
| EC2 status checks | System `ok`, instance `ok` |
| IAM role | `xbrain-cloudwatch-agent-role` |
| Required policy | `CloudWatchAgentServerPolicy` attached |
| Remote verification | SSM agent online |
| CloudWatch Agent | `running`, `configured`, `enabled`, `active` |
| Agent version | `1.300066.2` |
| Metric namespace | `CWAgent` |
| Metrics found | Memory, disk, and swap |
| Log stream | `/xbrain-cloudwatch-agent/cloud-init/i-059488135b121ddcf` |
| Terraform drift | `No changes` |

## Evidence Checklist

Evidence currently captured:

| Evidence | File | Assessment |
| --- | --- | --- |
| EC2 instance running with the expected IAM role | [`evidence/ec2-instance-and-iam-role.png`](evidence/ec2-instance-and-iam-role.png) | Complete |
| SSM Session Manager online and connected | [`evidence/ssm-session-manager-online.png`](evidence/ssm-session-manager-online.png) | Complete |
| CloudWatch `CWAgent` namespace containing seven metrics | [`evidence/cloudwatch-cwagent-namespace.png`](evidence/cloudwatch-cwagent-namespace.png) | Complete |
| `disk_used_percent` metrics for the lab instance | [`evidence/cloudwatch-disk-metrics.png`](evidence/cloudwatch-disk-metrics.png) | Complete |
| General CloudWatch ingestion page | [`evidence/cloudwatch-ingestion-overview.png`](evidence/cloudwatch-ingestion-overview.png) | Supplemental only; it does not prove agent ingestion |

Capture these additional screenshots before considering the evidence set
complete:

| Required evidence | Filename |
| --- | --- |
| IAM role Permissions tab showing `CloudWatchAgentServerPolicy` | `iam-cloudwatch-agent-policy.png` |
| `verify.ps1` output showing `running`, `configured`, `enabled`, and `active` | `cloudwatch-agent-status.png` |
| A rendered graph for `mem_used_percent` or `disk_used_percent` | `cloudwatch-agent-metric-graph.png` |
| CloudWatch Logs group with stream `i-059488135b121ddcf` | `cloudwatch-agent-log-stream.png` |

Optional stronger Infrastructure as Code evidence:

| Optional evidence | Filename |
| --- | --- |
| Terminal showing Terraform `No changes` | `terraform-plan-no-changes.png` |

## Useful Manual Commands

```powershell
terraform -chdir=cloud/w9/cloudwatch-agent-lab plan

aws cloudwatch list-metrics `
  --profile default `
  --region us-east-1 `
  --namespace CWAgent `
  --dimensions Name=InstanceId,Value=i-059488135b121ddcf

aws logs describe-log-streams `
  --profile default `
  --region us-east-1 `
  --log-group-name /xbrain-cloudwatch-agent/cloud-init
```

No additional command is required to finish the technical deployment. Run the
verification script only if fresh terminal output is needed for evidence.

## Cleanup

After capturing evidence:

```powershell
.\cloud\w9\cloudwatch-agent-lab\scripts\cleanup.ps1
```

This destroys the EC2 instance, IAM resources, security group, and CloudWatch
log group managed by this lab.
