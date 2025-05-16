# Target Group for Security Appliance (GENEVE protocol)
resource "aws_lb_target_group" "appliance_tg" {
  name        = "${var.vpc_name}-appliance-tg"
  port        = 6081
  protocol    = "GENEVE"
  vpc_id      = var.vpc_id
  target_type = "instance"

  tags = {
    Name = "${var.vpc_name}-appliance-tg"
  }
}

# Register the appliance instance as a target
resource "aws_lb_target_group_attachment" "appliance_attachment" {
  target_group_arn = aws_lb_target_group.appliance_tg.arn
  target_id        = var.appliance_instance_id
  port             = 6081
}

# Gateway Load Balancer
resource "aws_lb" "gwlb" {
  name               = "${var.vpc_name}-gwlb"
  load_balancer_type = "gateway"
  subnets            = [var.gwlb_subnet_id]

  tags = {
    Name = "${var.vpc_name}-gwlb"
  }
}

# Listener for GWLB on port 6081
resource "aws_lb_listener" "gwlb_listener" {
  load_balancer_arn = aws_lb.gwlb.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.appliance_tg.arn
  }
}

# Endpoint Service for PrivateLink
resource "aws_vpc_endpoint_service" "endpoint_service" {
  acceptance_required    = true
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]

  allowed_principals = var.allowed_principals

  tags = {
    Name = "${var.vpc_name}-endpoint-service"
  }
  depends_on = [aws_lb.gwlb]
}
