# ==============================
# Interface Endpoint for EC2 API
# ==============================
resource "aws_vpc_endpoint" "ec2_interface" {
  vpc_id              = var.vpc_id
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.endpoint_sg_id]
  service_name        = "com.amazonaws.${var.region}.ec2"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name = "ec2-api-endpoint"
  }
}

# =====================
# S3 Gateway Endpoint
# =====================
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  tags = {
    Name = "s3-gateway-endpoint"
  }
}


