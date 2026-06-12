output "instance_id" {
  description = "EC2 instance running the CloudWatch Agent."
  value       = aws_instance.agent.id
}

output "instance_name" {
  description = "Name tag of the lab EC2 instance."
  value       = aws_instance.agent.tags["Name"]
}

output "iam_role_name" {
  description = "IAM role attached to the EC2 instance."
  value       = aws_iam_role.cloudwatch_agent.name
}

output "cloudwatch_log_group" {
  description = "CloudWatch Logs group receiving cloud-init output."
  value       = aws_cloudwatch_log_group.cloud_init.name
}

output "metric_namespace" {
  description = "Namespace containing memory, disk, and swap metrics."
  value       = "CWAgent"
}

output "ssm_start_session_command" {
  description = "Command for opening a shell without SSH."
  value       = "aws ssm start-session --profile ${var.aws_profile} --region ${var.aws_region} --target ${aws_instance.agent.id}"
}
