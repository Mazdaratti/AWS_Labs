variable "vpc_name" {
  description = "Name for tagging resources"
  type        = string
  default     = "consumer-vpc"
}

variable "consumer_vpc_id" {
  description = "Consumer VPC ID"
  type        = string
}

variable "gwlbe_subnet_id" {
  description = "Subnet ID for Gateway Load Balancer Endpoint"
  type        = string
}

variable "endpoint_service_name" {
  description = "Name of the GWLB Endpoint Service to connect to"
  type        = string
}

variable "endpoint_service_id" {
  description = "ID of the Endpoint Service (for accepting connection)"
  type        = string
}
