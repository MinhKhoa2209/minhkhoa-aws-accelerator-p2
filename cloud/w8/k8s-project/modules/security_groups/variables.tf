variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID."
}

variable "allowed_web_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to reach the public ALB."
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Optional CIDR blocks allowed to SSH to the EC2 instance."
}

variable "node_port" {
  type        = number
  description = "Kubernetes NodePort exposed on the EC2 host."
}
