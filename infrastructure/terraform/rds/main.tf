module "rds" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "wordpress-db"

  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t4g.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  multi_az            = true
  publicly_accessible = false

  db_name  = var.db_name
  username = var.db_user

  manage_master_user_password = false
  password                    = var.db_password

  create_db_subnet_group = true
  subnet_ids             = var.subnet_ids_for_rds

  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = 7
  skip_final_snapshot     = true

  family               = "mysql8.0"
  major_engine_version = "8.0"

  tags = {
    Environment = var.env
    Name        = var.project_name
  }
}

resource "aws_security_group" "rds" {
  name        = "rds-sg"
  description = "Allow DB access"
  vpc_id      = var.vpc_id
}
