output "gwlbe_endpoint_id" {
  description = "ID of the Gateway Load Balancer Endpoint"
  value       = aws_vpc_endpoint.gwlb_endpoint.id
}



