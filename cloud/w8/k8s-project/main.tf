data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  app_artifact_files = [
    for file in fileset("${path.module}/web-app", "**") : "web-app/${file}"
    if !startswith(file, "__pycache__/")
    && !startswith(file, "node_modules/")
    && !startswith(file, "dist/")
    && !startswith(file, ".next/")
    && !startswith(file, "out/")
    && !endswith(file, ".pyc")
  ]

  k8s_artifact_files = [
    for file in fileset("${path.module}/k8s", "**") : "k8s/${file}"
    if !endswith(file, ".pyc")
  ]

  artifact_files = toset(concat(local.app_artifact_files, local.k8s_artifact_files))
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

  name_prefix       = local.name_prefix
  vpc_id            = module.vpc.vpc_id
  allowed_web_cidrs = var.allowed_web_cidrs
  allowed_ssh_cidrs = var.allowed_ssh_cidrs
  node_port         = var.node_port
}

resource "aws_s3_bucket" "artifacts" {
  bucket_prefix = "${local.artifact_bucket_prefix}-"
  force_destroy = true

  tags = {
    Name = "${local.name_prefix}-artifacts"
  }
}

resource "aws_s3_bucket_public_access_block" "artifacts" {
  bucket = aws_s3_bucket.artifacts.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "artifacts" {
  for_each = local.artifact_files

  bucket = aws_s3_bucket.artifacts.id
  key    = "source/${each.value}"
  source = "${path.module}/${each.value}"
  etag   = filemd5("${path.module}/${each.value}")
}

resource "aws_iam_role" "ec2" {
  name = "${local.name_prefix}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ec2_artifacts" {
  name = "${local.name_prefix}-artifact-read"
  role = aws_iam_role.ec2.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Effect   = "Allow"
        Resource = aws_s3_bucket.artifacts.arn
      },
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.artifacts.arn}/source/*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.ec2.name
}

data "cloudinit_config" "minikube" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/user_data.sh.tpl", {
      artifact_bucket  = aws_s3_bucket.artifacts.bucket
      artifact_prefix  = "source"
      aws_region       = var.aws_region
      image_name       = var.container_image_name
      image_tag        = var.container_image_tag
      kubectl_version  = var.kubectl_version
      minikube_version = var.minikube_version
      node_port        = var.node_port
    })
  }
}

module "ec2_web" {
  source = "./modules/ec2_web"

  name_prefix           = local.name_prefix
  subnet_id             = module.vpc.public_subnet_ids[0]
  ec2_security_group_id = module.security_groups.ec2_security_group_id
  instance_type         = var.instance_type
  key_name              = var.key_name
  iam_instance_profile  = aws_iam_instance_profile.ec2.name
  root_volume_size      = var.root_volume_size
  user_data             = data.cloudinit_config.minikube.rendered

  depends_on = [aws_s3_object.artifacts]
}

resource "aws_lb" "web" {
  name               = "${local.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_groups.alb_security_group_id]
  subnets            = module.vpc.public_subnet_ids

  tags = {
    Name = "${local.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "web" {
  name        = "${local.name_prefix}-tg"
  port        = var.node_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/healthz"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.name_prefix}-tg"
  }
}

resource "aws_lb_target_group_attachment" "web" {
  target_group_arn = aws_lb_target_group.web.arn
  target_id        = module.ec2_web.instance_id
  port             = var.node_port
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.web.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
