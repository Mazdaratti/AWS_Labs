variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "VPC Gateway Endpoint ID to restrict bucket access"
  type        = string
}

variable "deployer_arn" {
  description = "ARN of the IAM user or role running Terraform (for exempting from S3 policy deny)"
  type        = string
}