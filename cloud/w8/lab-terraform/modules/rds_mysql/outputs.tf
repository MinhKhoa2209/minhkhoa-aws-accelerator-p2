output "endpoint" {
  description = "RDS endpoint without port."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS MySQL port."
  value       = aws_db_instance.this.port
}

