output "bucket_name" {
  description = "S3 bucket name containing sample sensitive data"
  value       = aws_s3_bucket.macie_test.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.macie_test.arn
}

output "sns_topic_arn" {
  description = "SNS topic ARN for Macie alerts"
  value       = aws_sns_topic.macie_alerts.arn
}

output "eventbridge_rule_name" {
  description = "EventBridge rule name"
  value       = aws_cloudwatch_event_rule.macie_findings.name
}

output "macie_job_id" {
  description = "Macie classification job ID"
  value       = aws_macie2_classification_job.sample_data.job_id
}

output "macie_status" {
  description = "Macie account status"
  value       = aws_macie2_account.main.status
}

output "instructions" {
  description = "Next steps"
  value = var.notification_email != "" ? "Check email ${var.notification_email} and confirm SNS subscription. Then wait 5-10 minutes for Macie job to complete." : "No email configured. Check Macie findings in AWS Console after 5-10 minutes."
}
