variable "project_name" {
  description = "Ten repo portfolio cho Phase 2."
  type        = string
  default     = "minhkhoa-aws-accelerator-p2"

  validation {
    condition     = length(trimspace(var.project_name)) > 0
    error_message = "project_name khong duoc rong."
  }
}

variable "environment" {
  description = "Muc dich cua configuration hien tai."
  type        = string
  default     = "learning"

  validation {
    condition     = contains(["learning", "dev", "staging", "prod"], var.environment)
    error_message = "environment phai la learning, dev, staging hoac prod."
  }
}

variable "owner" {
  description = "Nguoi quan ly repo nay."
  type        = string
  default     = "MinhKhoa2209"
}

variable "weekly_topics" {
  description = "Danh sach topic dang hoc trong tuan."
  type        = list(string)
  default = [
    "iac-overview",
    "hcl-syntax",
    "terraform-workflow",
  ]
}
