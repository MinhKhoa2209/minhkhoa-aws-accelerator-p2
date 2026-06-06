variable "name_prefix" {
  type        = string
  description = "Prefix for resource names."
}

variable "subnet_id" {
  type        = string
  description = "Public subnet ID for the web server."
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs attached to the web server."
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type."
}

variable "key_name" {
  type        = string
  description = "Optional EC2 key pair name."
}

variable "root_volume_size" {
  type        = number
  description = "Root EBS volume size in GB."
}

variable "database_endpoint" {
  type        = string
  description = "RDS endpoint displayed by the web server."
}

variable "static_assets_bucket" {
  type        = string
  description = "S3 assets bucket name displayed by the web server."
}

variable "static_assets_website" {
  type        = string
  description = "S3 assets bucket ARN displayed by the web server."
}

variable "app_html_base64" {
  type        = string
  description = "Base64 encoded web app HTML."
}

variable "app_css_base64" {
  type        = string
  description = "Base64 encoded web app CSS."
}

variable "app_js_base64" {
  type        = string
  description = "Base64 encoded web app JavaScript."
}
