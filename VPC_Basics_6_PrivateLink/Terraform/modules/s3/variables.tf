variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "VPC Gateway Endpoint ID to restrict bucket access"
  type        = string
}

variable "public_ec2_role_arn" {
  description = "ARN of the IAM role used by the public EC2 instance"
  type        = string
}