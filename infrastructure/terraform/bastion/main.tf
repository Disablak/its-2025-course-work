# ============================================================
# EC2 Instance
# ============================================================
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]
  key_name      = var.public_key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "bastion"
    Environment = var.env
  }
}

# ============================================================
# EC2 security group
# ============================================================
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow ssh my ip"
  vpc_id      = var.vpc_id
  
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.project_name
    Environment = var.env
  }
}

resource "aws_security_group_rule" "access_from_bastion_to_rds" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id = var.rds_security_group_id
  description = "Allow access to RDS from Bastion"
}
