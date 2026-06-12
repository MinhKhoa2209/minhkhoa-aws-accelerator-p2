data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_iam_role" "cloudwatch_agent" {
  name = "${var.project_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.cloudwatch_agent.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "cloudwatch_agent" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.cloudwatch_agent.name
}

resource "aws_security_group" "instance" {
  name        = "${var.project_name}-sg"
  description = "No inbound access; outbound access for SSM and CloudWatch"
  vpc_id      = data.aws_vpc.default.id

  egress {
    description      = "Allow outbound HTTPS and package installation"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_cloudwatch_log_group" "cloud_init" {
  name              = "/${var.project_name}/cloud-init"
  retention_in_days = 7
}

resource "aws_instance" "agent" {
  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = sort(data.aws_subnets.default.ids)[0]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.cloudwatch_agent.name
  vpc_security_group_ids      = [aws_security_group.instance.id]

  user_data = templatefile("${path.module}/user-data.sh.tftpl", {
    agent_config_base64 = base64encode(templatefile("${path.module}/cloudwatch-agent-config.json.tftpl", {
      log_group_name             = aws_cloudwatch_log_group.cloud_init.name
      metric_collection_interval = var.metric_collection_interval
    }))
  })

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.project_name}-ec2"
  }

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_agent,
    aws_iam_role_policy_attachment.ssm
  ]
}
