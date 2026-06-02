output "learning_checkpoint" {
  description = "Structured checkpoint information for the current learning sandbox."
  value       = local.learning_checkpoint
}

output "topic_catalog" {
  description = "Topic metadata derived from the list of weekly topics."
  value       = local.topic_catalog
}

output "study_recommendations" {
  description = "Recommended next actions for the learner."
  value       = local.study_recommendations
}
