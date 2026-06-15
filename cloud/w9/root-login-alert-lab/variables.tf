variable "aws_region" {
  type        = string
  description = "AWS region for CloudWatch Logs, alarm, SNS, and the trail home region."
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Local AWS CLI profile used by Terraform and helper scripts."
  default     = "default"
}

variable "project_name" {
  type        = string
  description = "Prefix used for lab resources."
  default     = "xbrain-root-login-alert"
}

variable "alert_email" {
  type        = string
  description = "Email address subscribed to root login notifications."

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period."
  default     = 30
}
