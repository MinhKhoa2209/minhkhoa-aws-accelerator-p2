locals {
  repo_layout = {
    w8       = ["day-1", "day-2", "day-3", "lab"]
    backlog  = ["w9", "w10"]
    capstone = ["w11", "w12"]
  }

  standard_tags = {
    project     = var.project_name
    owner       = var.owner
    environment = var.environment
    phase       = "phase-2"
    week        = "w8"
  }

  w8_paths = [for folder in local.repo_layout.w8 : "cloud/w8/${folder}"]

  learning_summary = {
    current_day      = "W8-D1"
    topic_count      = length(var.weekly_topics)
    first_topic      = var.weekly_topics[0]
    repo_ready       = length(local.w8_paths) == 4
    recommended_mode = var.environment == "learning" ? "self-study" : "delivery"
  }
}
