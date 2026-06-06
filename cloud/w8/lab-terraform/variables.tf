variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "ap-southeast-1"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource names."
  default     = "lab-terraform"
}

variable "environment" {
  type        = string
  description = "Deployment environment."
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "owner" {
  type        = string
  description = "Owner tag value."
  default     = "Minh Khoa"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
  default     = ["10.30.1.0/24", "10.30.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
  default     = ["10.30.11.0/24", "10.30.12.0/24"]
}

variable "allowed_http_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access the EC2 web server on HTTP."
  default     = ["0.0.0.0/0"]
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Optional CIDR blocks allowed to SSH to the EC2 instance. Leave empty to disable SSH ingress."
  default     = []
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name for SSH access."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the web server."
  default     = "t3.micro"
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB."
  default     = 30
}

variable "db_name" {
  type        = string
  description = "Initial MySQL database name."
  default     = "appdb"
}

variable "db_username" {
  type        = string
  description = "RDS MySQL master username."
  default     = "appadmin"
}

variable "db_password" {
  type        = string
  description = "RDS MySQL master password."
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 8
    error_message = "db_password must be at least 8 characters."
  }

  validation {
    condition     = can(regex("^[ -~]+$", var.db_password)) && !strcontains(var.db_password, "/") && !strcontains(var.db_password, "@") && !strcontains(var.db_password, "\"") && !strcontains(var.db_password, " ")
    error_message = "db_password can use printable ASCII characters, but cannot include '/', '@', double quotes, or spaces."
  }
}

variable "db_instance_class" {
  type        = string
  description = "RDS instance class."
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  type        = number
  description = "RDS allocated storage in GB."
  default     = 20
}

variable "assets_bucket_name" {
  type        = string
  description = "Optional globally unique S3 bucket name. Leave empty to generate one."
  default     = ""
}
