# ============================================================
# ALB
# ============================================================
resource "aws_lb" "main" {
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http.id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false
  drop_invalid_header_fields = true

  tags = {
    Name = "Main ALB"
    Environment = var.env
  }
}

resource "aws_lb_target_group" "main" {
  name     = "demoapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  deregistration_delay = 30

  health_check {
    path                = "/wp-includes/images/blank.gif" // took from here https://serverfault.com/a/959734
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.existing_cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
