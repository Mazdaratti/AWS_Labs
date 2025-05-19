# =====================
# S3 Gateway Endpoint
# =====================
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [var.route_table_id]

  tags = {
    Name = "${var.vpc_name}-s3-endpoint"
  }
}

# =====================
# SSM Interface Endpoint
# =====================
resource "aws_vpc_endpoint" "ssm_interface" {
  vpc_id              = var.vpc_id
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [var.endpoint_sg_id]
  service_name        = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ssm-endpoint"
  }
}

# =====================
# SSM Messages Interface Endpoint
# =====================
resource "aws_vpc_endpoint" "ssmmessages_interface" {
  vpc_id              = var.vpc_id
  subnet_ids          = [var.subnet_id]
  security_group_ids  = [var.endpoint_sg_id]
  service_name        = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  tags = {
    Name = "${var.vpc_name}-ssmmessages-endpoint"
  }
}
