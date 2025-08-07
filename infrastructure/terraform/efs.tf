resource "aws_efs_file_system" "wordpress" {
  creation_token = "wordpress-efs"
  throughput_mode = "bursting"

  tags = {
    Name = "wordpress-efs"
    Environment = var.env
  }
}

resource "aws_security_group" "efs_sg" {
  name   = "efs-sg"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_http_and_ssh.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  private_subnets_map = {
    az1 = module.vpc.private_subnets[0]
    az2 = module.vpc.private_subnets[1]
  }
}

resource "aws_efs_mount_target" "efs_targets" {
  for_each = local.private_subnets_map // i can't just use toset(module.vpc.private_subnets)

  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}