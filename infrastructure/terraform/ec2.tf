resource "aws_launch_template" "my-app" {
  image_id      = var.ami
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.allow_http_and_ssh.id]
  }

  # iam_instance_profile {
  #   name = aws_iam_instance_profile.ec2_profile.name
  # }

  tags = {
    Name = "my-app"
    Environment = var.env
  }
}

resource "aws_security_group" "allow_http_and_ssh" {
  name        = "my-app-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow HTTP and SSH"

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

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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