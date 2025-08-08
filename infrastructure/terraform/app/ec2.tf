resource "aws_launch_template" "my-app" {
  name_prefix = "web"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.public_key_name

  network_interfaces {
    security_groups = [aws_security_group.allow_http_and_ssh.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_profile.name
  }

  tags = {
    Name = "my-app"
    Environment = var.env
  }
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "my-app-sg"
  vpc_id      = var.vpc_id
  description = "Allow HTTP and SSH"

  ingress {
    description = "Allow SSH from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "rule_for_rds_sg" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  source_security_group_id = aws_security_group.allow_http_and_ssh.id
  security_group_id = var.rds_security_group_id
  description = "Allow access to RDS from EC2"
}

resource "aws_iam_role" "ssm_role" {
  name = "ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}


# BASTION
resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]
  key_name      = var.public_key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.ssm_profile.name

  tags = {
    Name = "bastion"
    Environment = var.env
  }
}

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
    Name = "bastion-sg"
    Environment = var.env
  }
}