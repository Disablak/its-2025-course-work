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
  vpc_id = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_http_and_ssh.id, aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_efs_mount_target" "efs_targets" {
  for_each = toset(var.subnet_ids_for_web) // local.private_subnets_map // i can't just use toset(var.subnet_ids_for_web)

  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "wordpress_ap" {
  file_system_id = aws_efs_file_system.wordpress.id

  posix_user {
    gid = 48   # apache
    uid = 48   # apache
  }

  root_directory {
    path = "/var/www/html"
    creation_info {
      owner_gid   = 48
      owner_uid   = 48
      permissions = "755"
    }
  }

  tags = {
    Name = "wordpress-ap"
  }
}