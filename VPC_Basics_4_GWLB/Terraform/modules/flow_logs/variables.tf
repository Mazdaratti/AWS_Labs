variable "vpc_name" {
  description = "Name of the VPC (for tagging and log group naming)"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to enable flow logs for"
  type        = list(string)
}
