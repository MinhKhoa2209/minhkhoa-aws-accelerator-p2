variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security groups."
}

variable "allowed_http_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access HTTP."
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access SSH."
}

