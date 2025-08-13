resource "aws_autoscaling_group" "main" {
  name = "my-autoscale"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 4
  vpc_zone_identifier = toset(var.subnet_ids_for_web)
  target_group_arns   = [aws_lb_target_group.main.arn]
  health_check_type = "EC2"
  force_delete = true
  protect_from_scale_in = false

  lifecycle {
    create_before_destroy = false
  }

  launch_template {
    id      = aws_launch_template.my-app.id
    version = "$Latest"
  }
}