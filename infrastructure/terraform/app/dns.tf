resource "aws_route53_record" "alb" {
  zone_id = "Z03826543LFMRGPO7JVFL"
  name    = var.dns_name
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}
