param(
    [string]$Profile = "default",
    [string]$Region = "us-east-1",
    [int]$MaxAttempts = 30
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$LabRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $LabRoot

try {
    $logGroupName = (terraform output -raw log_group_name).Trim()
    $alarmName = (terraform output -raw alarm_name).Trim()
    $topicArn = (terraform output -raw sns_topic_arn).Trim()
    $accountId = (aws sts get-caller-identity --profile $Profile --query Account --output text).Trim()

    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($accountId)) {
        throw "Unable to read Terraform outputs or the AWS account ID."
    }

    $subscriptionStatus = aws sns list-subscriptions-by-topic `
        --profile $Profile `
        --region $Region `
        --topic-arn $topicArn `
        --query "Subscriptions[0].SubscriptionArn" `
        --output text

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read the SNS subscription."
    }

    if ($subscriptionStatus -eq "PendingConfirmation" -or $subscriptionStatus -eq "None") {
        Write-Warning "SNS email is not confirmed. The metric and alarm test will continue, but no email will be delivered."
    }

    $streamName = "root-login-test-$((Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss'))"
    aws logs create-log-stream `
        --profile $Profile `
        --region $Region `
        --log-group-name $logGroupName `
        --log-stream-name $streamName
    if ($LASTEXITCODE -ne 0) { throw "Unable to create the test log stream." }

    $eventMessage = @{
        eventVersion       = "1.11"
        eventTime          = (Get-Date).ToUniversalTime().ToString("o")
        eventSource        = "signin.amazonaws.com"
        eventName          = "ConsoleLogin"
        awsRegion          = "us-east-1"
        sourceIPAddress    = "203.0.113.10"
        userAgent          = "xbrain-safe-lab-test"
        eventType          = "AwsConsoleSignIn"
        recipientAccountId = $accountId
        userIdentity       = @{
            type        = "Root"
            principalId = "ROOT_ACCOUNT"
            arn         = "arn:aws:iam::${accountId}:root"
            accountId   = $accountId
        }
        responseElements   = @{
            ConsoleLogin = "Success"
        }
    } | ConvertTo-Json -Depth 5 -Compress

    $logEvents = ConvertTo-Json -InputObject @(
        @{
            timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeMilliseconds()
            message   = $eventMessage
        }
    ) -Depth 5 -Compress

    $tempFile = Join-Path $env:TEMP "root-login-test-event.json"
    Set-Content -LiteralPath $tempFile -Value $logEvents -Encoding utf8NoBOM

    try {
        aws logs put-log-events `
            --profile $Profile `
            --region $Region `
            --log-group-name $logGroupName `
            --log-stream-name $streamName `
            --log-events "file://$tempFile"
        if ($LASTEXITCODE -ne 0) { throw "Unable to publish the simulated root event." }
    }
    finally {
        Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
    }

    Write-Host "Simulated root event published to $logGroupName/$streamName"
    Write-Host "Waiting for alarm $alarmName to enter ALARM..."

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $state = aws cloudwatch describe-alarms `
            --profile $Profile `
            --region $Region `
            --alarm-names $alarmName `
            --query "MetricAlarms[0].StateValue" `
            --output text

        if ($LASTEXITCODE -ne 0) { throw "Unable to read alarm state." }

        Write-Host "Attempt $attempt/${MaxAttempts}: $state"
        if ($state -eq "ALARM") {
            Write-Host "Root login alarm test passed. Check the SNS email notification."
            exit 0
        }

        Start-Sleep -Seconds 15
    }

    throw "The alarm did not enter ALARM within the expected time."
}
finally {
    Pop-Location
}
