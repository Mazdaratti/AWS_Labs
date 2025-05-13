variable "vpc_id" {
  description = <<-EOT
  The ID of the VPC where security groups will be created.
  This is required because security groups are VPC-specific resources.
  Example: "vpc-1234567890abcdef0"
  EOT
  type        = string
}

variable "my_ip" {
  description = <<-EOT
  Your public IP address in CIDR notation for SSH access.
  This restricts SSH access to only your IP address for security.
  Example: "123.45.67.89/32"
  EOT
  type        = string
}

variable "name_prefix" {
  description = <<-EOT
  Prefix for all security group names and tags.
  Helps identify resources and maintain naming consistency.
  Example: "prod-alb-tutorial"
  EOT
  type        = string
  default     = "alb-tutorial"
}

