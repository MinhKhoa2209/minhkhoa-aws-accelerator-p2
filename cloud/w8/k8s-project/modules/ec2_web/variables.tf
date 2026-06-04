variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the EC2 instance."
}

variable "ec2_security_group_id" {
  type        = string
  description = "Security group ID for the EC2 minikube host."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name."
}

variable "user_data" {
  type        = string
  description = "User data script for bootstrapping the web app."
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name attached to the EC2 host."
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB."
}
