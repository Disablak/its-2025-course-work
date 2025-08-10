resource "aws_s3_bucket" "static" {
  bucket = var.bucket_name_static_content

  tags = {
    Name = "${var.bucket_name_static_content}"
  }
}

resource "aws_s3_bucket_ownership_controls" "static" {
  bucket = aws_s3_bucket.static.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "main" {
  depends_on = [aws_s3_bucket_ownership_controls.static]

  bucket = aws_s3_bucket.static.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.static.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.static.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


# 2) CloudFront Origin Access Identity (OAI) to restrict S3 access
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name_static_content}"
}

# 3) S3 bucket policy to allow only CloudFront OAI to read objects
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid = "AllowCloudFrontRead"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.static.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "static_policy" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.s3_policy.json
}