# =====================
# Target Group
# =====================
resource "aws_lb_target_group" "nlb_tg" {
  name        = "${var.vpc_name}-tg"
  port        = 80
  protocol    = "TCP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "TCP"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    timeout             = 10
  }

  tags = {
    Name = "${var.vpc_name}-tg"
  }
}

# =====================
# Target Group Attachment
# =====================
resource "aws_lb_target_group_attachment" "ec2_targets" {
  for_each = { for idx, id in var.instance_ids : idx => id }

  target_group_arn = aws_lb_target_group.nlb_tg.arn
  target_id        = each.value
  port             = 80
}

# =====================
# NLB
# =====================
resource "aws_lb" "nlb" {
  name               = "${var.vpc_name}-nlb"
  load_balancer_type = "network"
  internal           = false
  subnets            = var.public_subnet_ids
  security_groups    = [var.security_group_id]

  enable_cross_zone_load_balancing = true

  tags = {
    Name = "${var.vpc_name}-nlb"
  }
}

# =====================
# Listener
# =====================
resource "aws_lb_listener" "tcp_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}
