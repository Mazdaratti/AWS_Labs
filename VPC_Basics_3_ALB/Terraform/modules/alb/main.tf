# Create the Application Load Balancer
resource "aws_lb" "alb" {
  name               = var.name               # Name of the ALB
  internal           = false                  # Internet-facing ALB
  load_balancer_type = "application"          # Layer 7 load balancer
  security_groups    = [var.security_group_id] # Attach security group
  subnets            = var.subnet_ids         # Launch in public subnets

  # Enable deletion protection in production
  enable_deletion_protection = false

  tags = {
    Name = var.name  # Resource tag
  }
}

# Create target group for the ALB
resource "aws_lb_target_group" "web" {
  name     = "${var.name}-tg"  # Target group name
  port     = 80                # Instance port
  protocol = "HTTP"            # HTTP protocol
  vpc_id   = var.vpc_id        # VPC where targets are located

  # Health check configuration
  health_check {
    path                = "/"         # Health check endpoint
    protocol            = "HTTP"      # HTTP health checks
    healthy_threshold   = 2           # 2 consecutive successes = healthy
    unhealthy_threshold = 2           # 2 consecutive failures = unhealthy
    timeout             = 3           # 3 second timeout
    interval            = 30          # Check every 30 seconds
    matcher             = "200-299"   # Success HTTP status codes
  }
}

# Attach EC2 instances to the target group
resource "aws_lb_target_group_attachment" "web" {
  count            = length(var.target_instance_ids)  # Attach all instances
  target_group_arn = aws_lb_target_group.web.arn     # Reference target group
  target_id        = var.target_instance_ids[count.index]  # Instance ID
  port             = 80                              # Instance port
}

# Create ALB listener on port 80
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn  # Attach to our ALB
  port              = "80"            # Listen on port 80
  protocol          = "HTTP"          # HTTP protocol

  # Default action - forward to target group
  default_action {
    type             = "forward"      # Forward traffic
    target_group_arn = aws_lb_target_group.web.arn  # To our target group
  }
}