variable "project_name" {
  description = "Portfolio repository name for Phase 2."
  type        = string
  default     = "minhkhoa-aws-accelerator-p2"

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  description = "Purpose of the current configuration."
  type        = string
  default     = "learning"

  validation {
    condition     = contains(["learning", "dev", "staging", "prod"], var.environment)
    error_message = "environment must be learning, dev, staging, or prod."
  }
}

variable "owner" {
  description = "Owner of this repository."
  type        = string
  default     = "MinhKhoa2209"
}

variable "weekly_topics" {
  description = "List of topics being studied this week."
  type        = list(string)
  default = [
    "iac-overview",
    "hcl-syntax",
    "terraform-workflow",
  ]
}
