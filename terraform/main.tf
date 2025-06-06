provider "aws" {
  
  region = var.region
}

resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  tags = {
    Name = "StaticWebsiteBucket"
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

data "aws_iam_policy_document" "public_read" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.static_site.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.static_site.id
  policy = data.aws_iam_policy_document.public_read.json
}

resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "index.html"
  source       = "${path.module}/../website/index.html"
  content_type = "text/html"
}

resource "aws_s3_bucket_object" "css" {
  bucket       = aws_s3_bucket.static_site.bucket
  key          = "style.css"
  source       = "${path.module}/../website/style.css"
  content_type = "text/css"
}
