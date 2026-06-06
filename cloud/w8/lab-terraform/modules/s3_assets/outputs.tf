output "bucket_name" {
  description = "S3 assets bucket name."
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "S3 assets bucket ARN."
  value       = aws_s3_bucket.this.arn
}

