resource "aws_launch_template" "my-app" {
  name_prefix = "web"
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.public_key_name

  user_data = base64encode(templatefile("${path.module}/userdata.sh.tftpl", { 
    fsap = var.efs_ap_id,
    fs = var.efs_id
  }))

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

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web"
    }
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
    security_groups = [var.bastion_sg_id]
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
  description = "Allow access to RDS from Web"
}

resource "aws_security_group_rule" "rule_for_efs_sg" {
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  source_security_group_id = aws_security_group.allow_http_and_ssh.id
  security_group_id = var.efs_sg_id
  description = "Allow access to EFS from Web"
}

resource "aws_iam_role" "ec2_role" {
  name = "ec2-role"

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

resource "aws_iam_role_policy_attachment" "ssm_attach" { # TODO DELETE
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_agent_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ssm_profile" {
  name = "ssm-instance-profile"
  role = aws_iam_role.ec2_role.name
}
