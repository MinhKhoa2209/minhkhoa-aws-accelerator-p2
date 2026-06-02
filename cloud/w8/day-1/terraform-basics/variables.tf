variable "project_name" {
  type        = string
  description = "Portfolio repository name for Phase 2."
  default     = "minhkhoa-aws-accelerator-p2"

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name must not be empty."
  }
}

variable "environment" {
  type        = string
  description = "Purpose of the current configuration."
  default     = "learning"

  validation {
    condition     = contains(["learning", "dev", "staging", "prod"], var.environment)
    error_message = "environment must be learning, dev, staging, or prod."
  }
}

variable "owner" {
  type        = string
  description = "Owner of this repository."
  default     = "MinhKhoa2209"
}

variable "weekly_topics" {
  type        = list(string)
  description = "List of topics being studied this week."
  default = [
    "iac-overview",
    "hcl-syntax",
    "terraform-workflow",
    "state-management",
    "modules-and-best-practices",
  ]

  validation {
    condition = (
      length(var.weekly_topics) > 0 &&
      alltrue([for topic in var.weekly_topics : length(trimspace(topic)) > 0])
    )
    error_message = "weekly_topics must contain at least one non-empty topic."
  }
}
