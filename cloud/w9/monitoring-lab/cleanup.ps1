param(
    [string]$Region = "us-east-1",
    [string]$Profile = "default"
)

$ErrorActionPreference = "Stop"

$instanceId = aws ec2 describe-instances `
    --profile $Profile `
    --region $Region `
    --filters `
        "Name=tag:Name,Values=xbrain-monitoring-lab" `
        "Name=instance-state-name,Values=pending,running,stopping,stopped" `
    --query "Reservations[0].Instances[0].InstanceId" `
    --output text

if ($instanceId -and $instanceId -ne "None") {
    aws ec2 terminate-instances `
        --profile $Profile `
        --region $Region `
        --instance-ids $instanceId | Out-Null
    Write-Host "Terminating EC2 instance: $instanceId"
}

aws cloudwatch delete-alarms `
    --profile $Profile `
    --region $Region `
    --alarm-names "xbrain-ec2-high-cpu"

$topicArns = aws sns list-topics `
    --profile $Profile `
    --region $Region `
    --query "Topics[?contains(TopicArn, 'xbrain-cpu-alerts')].TopicArn" `
    --output text

foreach ($topicArn in ($topicArns -split "\s+")) {
    if ($topicArn -and $topicArn -ne "None") {
        aws sns delete-topic `
            --profile $Profile `
            --region $Region `
            --topic-arn $topicArn
        Write-Host "Deleted SNS topic: $topicArn"
    }
}
