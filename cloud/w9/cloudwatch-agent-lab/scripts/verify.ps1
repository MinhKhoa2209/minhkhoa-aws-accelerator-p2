param(
    [string]$Profile = "default",
    [string]$Region = "us-east-1",
    [int]$MaxAttempts = 40
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$LabRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $LabRoot

try {
    $instanceId = (terraform output -raw instance_id).Trim()
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($instanceId)) {
        throw "Unable to read the Terraform instance_id output."
    }

    Write-Host "Waiting for SSM registration: $instanceId"
    $ssmReady = $false

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $pingStatus = aws ssm describe-instance-information `
            --profile $Profile `
            --region $Region `
            --filters "Key=InstanceIds,Values=$instanceId" `
            --query "InstanceInformationList[0].PingStatus" `
            --output text

        if ($LASTEXITCODE -ne 0) {
            throw "AWS CLI could not query SSM. Check profile '$Profile' and AWS credentials."
        }

        if ($pingStatus -eq "Online") {
            $ssmReady = $true
            break
        }

        Write-Host "Attempt $attempt/${MaxAttempts}: SSM is not online yet."
        Start-Sleep -Seconds 15
    }

    if (-not $ssmReady) {
        throw "The instance did not register as Online in SSM."
    }

    $commandParameters = @{
        commands = @(
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status",
            "sudo systemctl is-enabled amazon-cloudwatch-agent",
            "sudo systemctl is-active amazon-cloudwatch-agent"
        )
    } | ConvertTo-Json -Compress

    $commandId = aws ssm send-command `
        --profile $Profile `
        --region $Region `
        --instance-ids $instanceId `
        --document-name "AWS-RunShellScript" `
        --parameters $commandParameters `
        --query "Command.CommandId" `
        --output text

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to send the agent verification command."
    }

    aws ssm wait command-executed `
        --profile $Profile `
        --region $Region `
        --command-id $commandId `
        --instance-id $instanceId

    if ($LASTEXITCODE -ne 0) {
        throw "The SSM verification command did not complete successfully."
    }

    aws ssm get-command-invocation `
        --profile $Profile `
        --region $Region `
        --command-id $commandId `
        --instance-id $instanceId `
        --query "{Status:Status,Output:StandardOutputContent,Errors:StandardErrorContent}" `
        --output json

    Write-Host "Waiting for CWAgent metrics..."
    $metricsReady = $false

    for ($attempt = 1; $attempt -le 12; $attempt++) {
        $metricCount = aws cloudwatch list-metrics `
            --profile $Profile `
            --region $Region `
            --namespace "CWAgent" `
            --dimensions "Name=InstanceId,Value=$instanceId" `
            --query "length(Metrics)" `
            --output text

        if ($LASTEXITCODE -ne 0) {
            throw "AWS CLI could not query CloudWatch. Check profile '$Profile' and AWS credentials."
        }

        if ([int]$metricCount -gt 0) {
            $metricsReady = $true
            Write-Host "Published CWAgent metrics: $metricCount"
            break
        }

        Write-Host "Metric attempt $attempt/12: no CWAgent metrics yet."
        Start-Sleep -Seconds 15
    }

    if (-not $metricsReady) {
        throw "The agent is running, but no CWAgent metrics were found."
    }

    aws cloudwatch list-metrics `
        --profile $Profile `
        --region $Region `
        --namespace "CWAgent" `
        --dimensions "Name=InstanceId,Value=$instanceId" `
        --query "Metrics[].{MetricName:MetricName,Dimensions:Dimensions}" `
        --output table
}
finally {
    Pop-Location
}
