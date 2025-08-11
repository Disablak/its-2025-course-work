data "aws_s3_bucket" "static" {
  bucket = var.bucket_name_static_content
}

data "aws_s3_bucket" "logs" {
  bucket = var.bucket_name_log
}

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
      "${data.aws_s3_bucket.static.arn}/*"
    ]
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.bucket_name_static_content}"
}

resource "aws_s3_bucket_policy" "static_policy" {
  bucket = data.aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.s3_policy.json
}