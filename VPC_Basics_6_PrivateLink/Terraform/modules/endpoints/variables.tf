variable "vpc_name" {
  description = "Prefix for naming"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Private subnet ID for interface endpoints"
  type        = string
}

variable "route_table_id" {
  description = "Route table ID for S3 Gateway endpoint"
  type        = string
}

variable "endpoint_sg_id" {
  description = "Security group for interface endpoints"
  type        = string
}

variable "region" {
  description = "AWS region (for building endpoint names)"
  type        = string
}
