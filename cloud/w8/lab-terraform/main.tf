data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  web_app_html = templatefile("${path.module}/web-app/index.html.tpl", {
    database_endpoint    = module.rds_mysql.endpoint
    static_assets_bucket = module.assets.bucket_name
    static_assets_arn    = module.assets.bucket_arn
  })
}

module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "security_groups" {
  source = "./modules/security_groups"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  allowed_http_cidrs = var.allowed_http_cidrs
  allowed_ssh_cidrs  = var.allowed_ssh_cidrs
}

module "assets" {
  source = "./modules/s3_assets"

  name_prefix = local.name_prefix
  bucket_name = var.assets_bucket_name
}

module "rds_mysql" {
  source = "./modules/rds_mysql"

  name_prefix        = local.name_prefix
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.security_groups.rds_security_group_id]
  db_name            = var.db_name
  username           = var.db_username
  password           = var.db_password
  instance_class     = var.db_instance_class
  allocated_storage  = var.db_allocated_storage
}

module "ec2_web" {
  source = "./modules/ec2_web"

  name_prefix           = local.name_prefix
  subnet_id             = module.vpc.public_subnet_ids[0]
  security_group_ids    = [module.security_groups.web_security_group_id]
  instance_type         = var.instance_type
  key_name              = var.key_name
  root_volume_size      = var.root_volume_size
  database_endpoint     = module.rds_mysql.endpoint
  static_assets_bucket  = module.assets.bucket_name
  static_assets_website = module.assets.bucket_arn
  app_html_base64       = base64encode(local.web_app_html)
  app_css_base64        = filebase64("${path.module}/web-app/styles.css")
  app_js_base64         = filebase64("${path.module}/web-app/app.js")
}
