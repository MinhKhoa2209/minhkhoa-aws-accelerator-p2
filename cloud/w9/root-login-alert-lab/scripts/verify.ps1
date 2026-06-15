param(
    [string]$Profile = "default",
    [string]$Region = "us-east-1"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$LabRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
Push-Location $LabRoot

try {
    $trailName = (terraform output -raw trail_name).Trim()
    $logGroupName = (terraform output -raw log_group_name).Trim()
    $metricFilterName = (terraform output -raw metric_filter_name).Trim()
    $alarmName = (terraform output -raw alarm_name).Trim()
    $topicArn = (terraform output -raw sns_topic_arn).Trim()

    if ($LASTEXITCODE -ne 0) {
        throw "Unable to read Terraform outputs."
    }

    Write-Host "CloudTrail status"
    aws cloudtrail get-trail-status `
        --profile $Profile `
        --region $Region `
        --name $trailName `
        --query "{IsLogging:IsLogging,LatestDeliveryTime:LatestDeliveryTime,LatestCloudWatchLogsDeliveryTime:LatestCloudWatchLogsDeliveryTime}" `
        --output table
    if ($LASTEXITCODE -ne 0) { throw "Unable to verify CloudTrail." }

    Write-Host "Metric filter"
    aws logs describe-metric-filters `
        --profile $Profile `
        --region $Region `
        --log-group-name $logGroupName `
        --filter-name-prefix $metricFilterName `
        --query "metricFilters[].{Name:filterName,Pattern:filterPattern,Metric:metricTransformations[0].metricName,Namespace:metricTransformations[0].metricNamespace}" `
        --output table
    if ($LASTEXITCODE -ne 0) { throw "Unable to verify the metric filter." }

    Write-Host "CloudWatch alarm"
    aws cloudwatch describe-alarms `
        --profile $Profile `
        --region $Region `
        --alarm-names $alarmName `
        --query "MetricAlarms[].{Name:AlarmName,State:StateValue,Metric:MetricName,Threshold:Threshold,Period:Period,ActionsEnabled:ActionsEnabled}" `
        --output table
    if ($LASTEXITCODE -ne 0) { throw "Unable to verify the alarm." }

    Write-Host "SNS subscription"
    aws sns list-subscriptions-by-topic `
        --profile $Profile `
        --region $Region `
        --topic-arn $topicArn `
        --query "Subscriptions[].{Protocol:Protocol,Endpoint:Endpoint,Status:SubscriptionArn}" `
        --output table
    if ($LASTEXITCODE -ne 0) { throw "Unable to verify the SNS subscription." }
}
finally {
    Pop-Location
}
