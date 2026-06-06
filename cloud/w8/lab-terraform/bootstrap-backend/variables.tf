variable "aws_region" {
  type        = string
  description = "AWS region for backend resources."
  default     = "ap-southeast-1"
}

variable "project_name" {
  type        = string
  description = "Project name used in backend resource names."
  default     = "lab-terraform"
}

