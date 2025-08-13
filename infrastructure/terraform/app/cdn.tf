locals {
  ttl_one_day = 86400
  ttl_one_year = 31536000
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  comment = "CloudFront for ${var.dns_name}"
  price_class = "PriceClass_100" // least expensive
  aliases = [var.dns_name]

# ============================================================
# Origins
# ============================================================
  origin {
    domain_name = data.aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = "S3-${var.bucket_name_static_content}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  origin {
    domain_name = aws_lb.main.dns_name
    origin_id   = "ALB-${aws_lb.main.dns_name}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

# ============================================================
# Behaviours
# ============================================================
  default_cache_behavior {
    target_origin_id       = "ALB-${aws_lb.main.dns_name}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = ["Host", "Authorization"]
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  ordered_cache_behavior {
    path_pattern           = "wp-content/*"
    target_origin_id       = "S3-${var.bucket_name_static_content}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }

    min_ttl     = 0
    default_ttl = local.ttl_one_day
    max_ttl     = local.ttl_one_year
  }

  ordered_cache_behavior {
    path_pattern           = "wp-includes/*"
    target_origin_id       = "S3-${var.bucket_name_static_content}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
      headers = ["Origin"]
    }
    min_ttl     = 0
    default_ttl = local.ttl_one_day
    max_ttl     = local.ttl_one_year
  }

# ============================================================
# Other settings
# ============================================================

  logging_config {
    bucket = data.aws_s3_bucket.logs.bucket_domain_name
    prefix = "cdn/"
    include_cookies = false
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.existing_cert.arn
    ssl_support_method  = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}