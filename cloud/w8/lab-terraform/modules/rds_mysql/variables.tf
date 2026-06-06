variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for the DB subnet group."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to RDS."
}

variable "db_name" {
  type        = string
  description = "Initial MySQL database name."
}

variable "username" {
  type        = string
  description = "RDS master username."
}

variable "password" {
  type        = string
  description = "RDS master password."
  sensitive   = true
}

variable "instance_class" {
  type        = string
  description = "RDS instance class."
}

variable "allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB."
}

