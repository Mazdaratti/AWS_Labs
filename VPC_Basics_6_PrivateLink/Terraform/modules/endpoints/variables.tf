variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for interface endpoints"
  type        = list(string)
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
  description = "AWS region (for building service names)"
  type        = string
}
