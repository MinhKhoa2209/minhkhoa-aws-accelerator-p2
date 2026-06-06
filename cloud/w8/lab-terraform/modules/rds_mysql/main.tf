resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-mysql-subnets"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-mysql-subnets"
  }
}

resource "aws_db_instance" "this" {
  identifier             = "${var.name_prefix}-mysql"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  storage_type           = "gp3"
  storage_encrypted      = true
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false

  backup_retention_period = 1

  tags = {
    Name = "${var.name_prefix}-mysql"
  }
}

