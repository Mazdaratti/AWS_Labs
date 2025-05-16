resource "aws_vpc_endpoint" "gwlb_endpoint" {
  vpc_id            = var.consumer_vpc_id
  service_name      = var.endpoint_service_name
  vpc_endpoint_type = "GatewayLoadBalancer"

  subnet_ids = [
    var.gwlbe_subnet_id
  ]

  private_dns_enabled = false

  tags = {
    Name = "${var.vpc_name}-gwlbe-endpoint"
  }
}

resource "aws_vpc_endpoint_connection_accepter" "accept_connection" {
  vpc_endpoint_service_id = var.endpoint_service_id
  vpc_endpoint_id         = aws_vpc_endpoint.gwlb_endpoint.id
}
