###############################################
# S3 Bucket with Restricted Access
# - Private bucket
# - Access only via IAM roles + VPC Endpoint
###############################################

resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name
  force_destroy = true

  tags = {
    Name = var.bucket_name
  }
}

# =====================
# S3 Bucket Policy
# =====================
resource "aws_s3_bucket_policy" "ec2_access" {
  bucket = aws_s3_bucket.test_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAccessFromVpcEndpoint",
        Effect    = "Allow",
        Principal = "*",  # Allow any principal, but restrict by VPC endpoint
        Action    = "s3:*",
        Resource  = [
          "${aws_s3_bucket.test_bucket.arn}",
          "${aws_s3_bucket.test_bucket.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceVpce" = var.vpc_endpoint_id
          }
        }
      },
      {
        Sid       = "AllowAccessFromPublicEC2"
        Effect    = "Allow",
        Principal = {
          "AWS"   = [var.public_ec2_role_arn]
        },
        Action    = "s3:*",
        Resource  = [
          aws_s3_bucket.test_bucket.arn,
          "${aws_s3_bucket.test_bucket.arn}/*"
        ]
      }
    ]
  })
}


