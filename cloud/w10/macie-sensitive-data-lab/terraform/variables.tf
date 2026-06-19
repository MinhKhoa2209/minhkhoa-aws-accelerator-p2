variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email address to receive Macie finding notifications (optional)"
  type        = string
  default     = ""
}

variable "bucket_prefix" {
  description = "Prefix for S3 bucket name"
  type        = string
  default     = "xbrain-macie-sensitive-data"
}
