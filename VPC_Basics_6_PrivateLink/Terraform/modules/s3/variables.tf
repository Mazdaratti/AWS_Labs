variable "bucket_name" {
  description = "Globally unique name for the S3 bucket"
  type        = string
}

variable "vpc_endpoint_id" {
  description = "VPC Gateway Endpoint ID to restrict bucket access"
  type        = string
}
