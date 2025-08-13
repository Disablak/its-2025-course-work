# ============================================================
# DNS Register record
# ============================================================
data "aws_route53_zone" "selected" {
  name         = var.dns_name
  private_zone = false
}

data "aws_acm_certificate" "existing_cert" {
  domain      = var.dns_name
  statuses    = ["ISSUED"]
  most_recent = true
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}

# ============================================================
# DNS logs
# ============================================================
resource "aws_cloudwatch_log_group" "route53_logs" {
  name              = "/aws/route53/querylogs"
  retention_in_days = 30
}

resource "aws_route53_query_log" "dns_logs" {
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_logs.arn
  zone_id                  = data.aws_route53_zone.selected.zone_id
}

resource "aws_cloudwatch_log_resource_policy" "route53_logging" {
  policy_name = "Route53QueryLoggingPolicy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/route53/querylogs:*"
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}