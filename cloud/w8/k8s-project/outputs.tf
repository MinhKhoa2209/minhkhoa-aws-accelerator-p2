output "alb_url" {
  description = "Public URL for the Next.js app exposed through the ALB."
  value       = "http://${aws_lb.web.dns_name}"
}

output "alb_dns_name" {
  description = "DNS name of the public Application Load Balancer."
  value       = aws_lb.web.dns_name
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 minikube host."
  value       = module.ec2_web.public_ip
}

output "artifact_bucket" {
  description = "Private S3 bucket used to stage app and Kubernetes files for EC2 bootstrap."
  value       = aws_s3_bucket.artifacts.bucket
}

output "node_port" {
  description = "Kubernetes NodePort targeted by the ALB."
  value       = var.node_port
}
