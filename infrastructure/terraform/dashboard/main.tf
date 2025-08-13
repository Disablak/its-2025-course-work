# ============================================================
# Local variables
# ============================================================
data "aws_instances" "web" {
  filter {
    name   = "tag:Name"
    values = ["web"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

locals {
  met_cpu_usage_system = [
    for id in data.aws_instances.web.ids : [
      "CWAgent",
      "cpu_usage_system",
      "InstanceId",
      id,
      "cpu",
      "cpu-total",
      { region = var.region }
    ]
  ]

  met_cpu_usage_idle = [
    for id in data.aws_instances.web.ids : [
      "CWAgent",
      "cpu_usage_idle",
      "InstanceId",
      id,
      "cpu",
      "cpu-total",
      { region = var.region }
    ]
  ]

    met_cpu_usage_user = [
    for id in data.aws_instances.web.ids : [
      "CWAgent",
      "cpu_usage_user",
      "InstanceId",
      id,
      "cpu",
      "cpu-total",
      { region = var.region }
    ]
  ]
}

# ============================================================
# Dashboard
# ============================================================
resource "aws_cloudwatch_dashboard" "basic_dashboard" {
  dashboard_name = "disablak-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width  = 7
        height = 6
        properties = {
          metrics = local.met_cpu_usage_system
          view   = "timeSeries"
          stacked = false
          region  = var.region
          period  = 300
          stat    = "Average"
          title   = "CPU Usage (System)"
        }
      },
      {
        type = "metric"
        x    = 7
        y    = 0
        width  = 7
        height = 6
        properties = {
          metrics = local.met_cpu_usage_idle
          view   = "timeSeries"
          stacked = false
          region  = var.region
          period  = 300
          stat    = "Average"
          title   = "CPU Usage (Idle)"
        }
      },
      {
        type = "metric"
        x    = 14
        y    = 0
        width  = 7
        height = 6
        properties = {
          metrics = local.met_cpu_usage_user
          view   = "timeSeries"
          stacked = false
          region  = var.region
          period  = 300
          stat    = "Average"
          title   = "CPU Usage (User)"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          query       = "SOURCE '/aws/ec2/apache-error'\n| fields @timestamp, @message, @logStream, @log\n| sort @timestamp desc\n| limit 10000"
          region      = var.region
          title       = "Apache Error Logs"
          queryType   = "Logs"
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          query       = "SOURCE '/aws/ec2/apache-access'\n| fields @timestamp, @message, @logStream, @log\n| sort @timestamp desc\n| limit 10000"
          region      = var.region
          title       = "Apache Access Logs"
          queryType   = "Logs"
        }
      }
    ]
  })
}
