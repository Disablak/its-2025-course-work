data "aws_route53_zone" "selected" {
  name         = var.dns_name
  private_zone = false
}

data "aws_acm_certificate" "existing_cert" {
  domain   = var.dns_name
  statuses = ["ISSUED"]
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

