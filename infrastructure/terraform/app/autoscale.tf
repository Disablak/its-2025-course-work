# ============================================================
# Autoscale group
# ============================================================
resource "aws_autoscaling_group" "main" {
  name                  = var.project_name
  desired_capacity      = var.min_autoscale_size
  min_size              = var.min_autoscale_size
  max_size              = var.max_autoscale_size
  vpc_zone_identifier   = toset(var.subnet_ids_for_web)
  target_group_arns     = [aws_lb_target_group.main.arn]
  health_check_type     = "EC2"
  force_delete          = true
  protect_from_scale_in = false

  lifecycle {
    create_before_destroy = false
  }

  launch_template {
    id      = aws_launch_template.my-app.id
    version = "$Latest"
  }
}

# ============================================================
# Scale-out CPU > 70%
# ============================================================
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "cpu-scale-out"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
}

# ============================================================
# Scale-in CPU < 30%
# ============================================================
resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  alarm_name          = "cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.main.name
  }

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "cpu-scale-in"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = -1
  cooldown               = 300
}