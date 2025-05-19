# =====================
# S3 Bucket
# =====================
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

# =====================
# S3 Bucket Policy
# =====================
resource "aws_s3_bucket_policy" "endpoint_restricted" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowVPCOnlyAccess"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          "${aws_s3_bucket.this.arn}",
          "${aws_s3_bucket.this.arn}/*"
        ]
        Condition = {
          StringNotEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      }
    ]
  })
}
