output "standard_tags" {
  description = "Map co the dung lai cho resource tags trong cac bai sau."
  value       = local.standard_tags
}

output "w8_paths" {
  description = "Danh sach thu muc cua W8 duoc tao trong repo."
  value       = local.w8_paths
}

output "learning_summary" {
  description = "Object tong hop de quan sat HCL evaluate collection va expression."
  value       = local.learning_summary
}

output "recommended_commit_message" {
  description = "Commit prefix theo announcement."
  value       = "[W8-D1] add terraform foundations"
}
