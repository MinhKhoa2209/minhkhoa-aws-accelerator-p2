output "trail_name" {
  description = "CloudTrail trail monitoring account activity."
  value       = aws_cloudtrail.root_login.name
}

output "trail_bucket_name" {
  description = "S3 bucket storing CloudTrail log files."
  value       = aws_s3_bucket.cloudtrail.id
}

output "log_group_name" {
  description = "CloudWatch Logs group receiving CloudTrail events."
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "metric_filter_name" {
  description = "Metric filter detecting root identity events."
  value       = aws_cloudwatch_log_metric_filter.root_login.name
}

output "alarm_name" {
  description = "CloudWatch alarm for root identity events."
  value       = aws_cloudwatch_metric_alarm.root_login.alarm_name
}

output "sns_topic_arn" {
  description = "SNS topic used for security notifications."
  value       = aws_sns_topic.security_alerts.arn
}

output "subscription_confirmation_required" {
  description = "Reminder that email subscriptions must be confirmed manually."
  value       = "Confirm the AWS SNS subscription email before running the test."
}
