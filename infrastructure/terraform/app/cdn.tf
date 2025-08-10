resource "aws_cloudfront_distribution" "cdn" {
  enabled = true
  comment = "CloudFront for ${var.dns_name}"

  # ORIGINS
  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
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
      origin_protocol_policy = "https-only"    # talk to ALB over HTTPS
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # DEFAULT BEHAVIOR => forward to ALB (dynamic)
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

  # ORDERED CACHE BEHAVIOR: static content → S3
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
    default_ttl = 86400   # cache static assets for 1 day (adjust as needed)
    max_ttl     = 31536000
  }

  # also cache wp-includes and uploads via S3
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
    default_ttl = 86400
    max_ttl     = 31536000
  }

  # LOGGING (optional — disabled by default)
  # logging_config {
  #   bucket = "my-cf-logs.s3.amazonaws.com"
  #   include_cookies = false
  # }

  price_class = "PriceClass_100"

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

  aliases = [var.dns_name]
}