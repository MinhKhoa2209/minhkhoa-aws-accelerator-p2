variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC."
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets."
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets."
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability zones used by subnets."
}
