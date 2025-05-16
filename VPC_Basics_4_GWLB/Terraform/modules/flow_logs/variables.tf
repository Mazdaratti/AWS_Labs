variable "vpc_name" {
  description = "Name of the VPC (for tagging and log group naming)"
  type        = string
}

variable "subnets" {
  type = map(object({
    id = string
  }))
  description = "Map of subnets where keys are logical names and values contain subnet IDs"
}