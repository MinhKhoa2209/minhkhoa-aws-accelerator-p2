output "standard_tags" {
  description = "Map that can be reused for resource tags in later exercises."
  value       = local.standard_tags
}

output "w8_paths" {
  description = "List of W8 directories created in the repository."
  value       = local.w8_paths
}

output "learning_summary" {
  description = "Summary object for observing how HCL evaluates collections and expressions."
  value       = local.learning_summary
}

output "recommended_commit_message" {
  description = "Commit prefix theo announcement."
  value       = "[W8-D1] add terraform foundations"
}
