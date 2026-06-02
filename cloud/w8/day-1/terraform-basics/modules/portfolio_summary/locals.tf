locals {
  normalized_topics = distinct(var.weekly_topics)

  topic_catalog = {
    for topic in local.normalized_topics : topic => {
      category = contains(["iac-overview", "hcl-syntax"], topic) ? "foundation" : "workflow"
      priority = contains(["state-management", "modules-and-best-practices"], topic) ? "next" : "now"
    }
  }

  learning_checkpoint = {
    project_name     = var.project_name
    owner            = var.owner
    environment      = var.environment
    topic_count      = length(local.normalized_topics)
    repository_ready = length(var.w8_paths) >= 4
    first_path       = var.w8_paths[0]
  }

  study_recommendations = [
    "Run terraform fmt before every commit.",
    "Use terraform validate before moving to plan or apply.",
    var.environment == "prod" ? "Move state to a remote backend before team collaboration." : "Local state is acceptable only for this learning sandbox.",
  ]
}
