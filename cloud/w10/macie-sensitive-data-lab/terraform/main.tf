# Data sources
data "aws_caller_identity" "current" {}

# ============================================================
# S3 Bucket for Sample Sensitive Data
# ============================================================

resource "aws_s3_bucket" "macie_test" {
  bucket = local.bucket_name

  tags = merge(
    local.common_tags,
    {
      Name = local.bucket_name
    }
  )
}

resource "aws_s3_bucket_public_access_block" "macie_test" {
  bucket = aws_s3_bucket.macie_test.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "macie_test" {
  bucket = aws_s3_bucket.macie_test.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Upload sample sensitive data file
resource "aws_s3_object" "sample_data" {
  bucket  = aws_s3_bucket.macie_test.id
  key     = "sample-data/customer-records-fake.txt"
  source  = "../sample-data/customer-records-fake.txt"
  etag    = filemd5("../sample-data/customer-records-fake.txt")

  server_side_encryption = "AES256"

  tags = merge(
    local.common_tags,
    {
      Name = "customer-records-sample"
    }
  )
}

# ============================================================
# SNS Topic for Notifications
# ============================================================

resource "aws_sns_topic" "macie_alerts" {
  name = local.topic_name

  tags = merge(
    local.common_tags,
    {
      Name = local.topic_name
    }
  )
}

resource "aws_sns_topic_policy" "macie_alerts" {
  arn = aws_sns_topic.macie_alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEventBridgePublish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.macie_alerts.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "macie_alerts_email" {
  count = var.notification_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.macie_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# ============================================================
# EventBridge Rule to Catch Macie Findings
# ============================================================

resource "aws_cloudwatch_event_rule" "macie_findings" {
  name        = local.rule_name
  description = "Capture Macie Finding events and send to SNS"

  event_pattern = jsonencode({
    source      = ["aws.macie"]
    detail-type = ["Macie Finding"]
  })

  tags = merge(
    local.common_tags,
    {
      Name = local.rule_name
    }
  )
}

resource "aws_cloudwatch_event_target" "macie_findings_to_sns" {
  rule      = aws_cloudwatch_event_rule.macie_findings.name
  target_id = "sns-macie-sensitive-data-alerts"
  arn       = aws_sns_topic.macie_alerts.arn
}

# ============================================================
# Amazon Macie - Enable and Create Job
# ============================================================

# Enable Macie
resource "aws_macie2_account" "main" {}

# Create classification job
resource "aws_macie2_classification_job" "sample_data" {
  job_type = "ONE_TIME"
  name     = "xbrain-macie-sensitive-data-job-${formatdate("YYYYMMDDhhmmss", timestamp())}"

  s3_job_definition {
    bucket_definitions {
      account_id = local.account_id
      buckets    = [aws_s3_bucket.macie_test.id]
    }
  }

  depends_on = [
    aws_macie2_account.main,
    aws_s3_object.sample_data
  ]

  tags = merge(
    local.common_tags,
    {
      Name = "xbrain-macie-job"
    }
  )

  lifecycle {
    # Cannot delete completed Macie jobs - AWS limitation
    # Remove from state on destroy instead
    create_before_destroy = true
  }
}
