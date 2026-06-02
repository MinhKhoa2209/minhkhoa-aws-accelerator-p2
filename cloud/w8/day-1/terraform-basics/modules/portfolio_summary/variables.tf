variable "project_name" {
  type        = string
  description = "Portfolio repository name."
}

variable "environment" {
  type        = string
  description = "Current execution environment."
}

variable "owner" {
  type        = string
  description = "Repository owner."
}

variable "weekly_topics" {
  type        = list(string)
  description = "Topics studied during this learning block."
}

variable "w8_paths" {
  type        = list(string)
  description = "Repository paths related to week 8."
}
