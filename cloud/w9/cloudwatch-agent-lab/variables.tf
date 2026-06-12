variable "aws_region" {
  type        = string
  description = "AWS region used by the lab."
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
  default     = "xbrain-cloudwatch-agent"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type used by the lab."
  default     = "t3.micro"
}

variable "metric_collection_interval" {
  type        = number
  description = "CloudWatch Agent metric collection interval in seconds."
  default     = 60

  validation {
    condition     = contains([1, 5, 10, 30, 60], var.metric_collection_interval)
    error_message = "metric_collection_interval must be 1, 5, 10, 30, or 60 seconds."
  }
}
