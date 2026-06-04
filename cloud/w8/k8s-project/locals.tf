locals {
  name_prefix            = "${var.project_name}-${var.environment}"
  artifact_bucket_prefix = substr("${replace(lower(local.name_prefix), "/[^a-z0-9-]/", "-")}-artifacts", 0, 37)

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
    Workload    = "w8-k8s-project"
  }
}
