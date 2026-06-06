resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  state_bucket_name = "${var.project_name}-tfstate-${random_id.suffix.hex}"
  lock_table_name   = "${var.project_name}-tf-locks"
}

resource "aws_s3_bucket" "state" {
  bucket = local.state_bucket_name

  tags = {
    Name      = local.state_bucket_name
    ManagedBy = "Terraform"
    Purpose   = "Remote state"
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "locks" {
  name         = local.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name      = local.lock_table_name
    ManagedBy = "Terraform"
    Purpose   = "Terraform state locking"
  }
}

