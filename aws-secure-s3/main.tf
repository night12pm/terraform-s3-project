provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "my-secure-bucket-scorpion-${random_id.id.hex}"
  force_destroy = true

  tags = {
    Name        = "SecureS3Bucket"
    Environment = "Dev"
  }
}

resource "random_id" "id" {
  byte_length = 4
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.secure_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "home_ip_only" {
  bucket = aws_s3_bucket.secure_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowHomeIP"
        Effect    = "Allow"
        Principal = "*"
        Action    = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "${aws_s3_bucket.secure_bucket.arn}",
          "${aws_s3_bucket.secure_bucket.arn}/*"
        ]
        Condition = {
          IpAddress = {
            "aws:SourceIp" = "106.51.164.158/32"
          }
        }
      }
    ]
  })
}
