locals {
  account_id  = data.aws_caller_identity.current.account_id
  bucket_name = "${var.bucket_prefix}-${local.account_id}"
  topic_name  = "xbrain-macie-sensitive-data-alerts"
  rule_name   = "xbrain-macie-sensitive-data-findings"

  common_tags = {
    Owner = "MinhKhoa"
  }
}
