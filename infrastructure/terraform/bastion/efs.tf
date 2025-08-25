# ============================================================
# EFS
# ============================================================
resource "aws_efs_file_system" "wordpress" {
  creation_token  = "wordpress-efs"
  throughput_mode = "bursting"
  encrypted       = "true"

  tags = {
    Name        = var.project_name
    Environment = var.env
  }
}

resource "aws_efs_mount_target" "efs_targets" {
  for_each = toset(var.subnet_ids_for_web)

  file_system_id  = aws_efs_file_system.wordpress.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}

resource "aws_efs_access_point" "wordpress_ap" {
  file_system_id = aws_efs_file_system.wordpress.id

  posix_user {
    gid = 48 # apache
    uid = 48 # apache
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
    Name        = var.project_name
    Environment = var.env
  }
}

# ============================================================
# EFS security group
# ============================================================
resource "aws_security_group" "efs_sg" {
  name   = "efs-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow access from bastion"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  tags = {
    Name        = var.project_name
    Environment = var.env
  }
}