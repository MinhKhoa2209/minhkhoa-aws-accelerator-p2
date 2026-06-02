module "portfolio_summary" {
  source = "./modules/portfolio_summary"

  project_name  = var.project_name
  environment   = var.environment
  owner         = var.owner
  weekly_topics = var.weekly_topics
  w8_paths      = local.w8_paths
}
