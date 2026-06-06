output "web_url" {
  description = "Public HTTP URL for the EC2 web server."
  value       = "http://${module.ec2_web.public_dns}"
}

output "web_instance_id" {
  description = "EC2 web server instance ID."
  value       = module.ec2_web.instance_id
}

output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "rds_endpoint" {
  description = "Private RDS MySQL endpoint."
  value       = module.rds_mysql.endpoint
}

output "assets_bucket_name" {
  description = "S3 bucket used for static assets."
  value       = module.assets.bucket_name
}

