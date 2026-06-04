variable "aws_region" {
  type        = string
  description = "AWS region for all resources."
  default     = "ap-southeast-1"
}

variable "project_name" {
  type        = string
  description = "Project name used in resource names."
  default     = "k8s-project"
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
  default     = "10.20.0.0/16"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
  default     = ["10.20.1.0/24", "10.20.2.0/24"]
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
  default     = ["10.20.11.0/24", "10.20.12.0/24"]
}

variable "allowed_web_cidrs" {
  type        = list(string)
  description = "CIDR blocks allowed to access the public ALB."
  default     = ["0.0.0.0/0"]
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name for SSH access."
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the minikube host."
  default     = "t3.small"
}

variable "allowed_ssh_cidrs" {
  type        = list(string)
  description = "Optional CIDR blocks allowed to SSH to the EC2 instance. Leave empty to disable SSH ingress."
  default     = []
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB for Docker images and the minikube node."
  default     = 30
}

variable "node_port" {
  type        = number
  description = "Fixed Kubernetes NodePort exposed by minikube and targeted by the ALB."
  default     = 30080

  validation {
    condition     = var.node_port >= 30000 && var.node_port <= 32767
    error_message = "node_port must be in the Kubernetes NodePort range 30000-32767."
  }
}

variable "container_image_name" {
  type        = string
  description = "Container image name built on the EC2 host and loaded into minikube."
  default     = "k8s-project-next"
}

variable "container_image_tag" {
  type        = string
  description = "Container image tag built on the EC2 host and loaded into minikube."
  default     = "0.1.0"
}

variable "kubectl_version" {
  type        = string
  description = "kubectl version installed on the EC2 host."
  default     = "v1.31.0"
}

variable "minikube_version" {
  type        = string
  description = "minikube version installed on the EC2 host."
  default     = "v1.34.0"
}
