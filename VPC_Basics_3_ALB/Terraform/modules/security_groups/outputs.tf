output "alb_sg_id" {
  description = <<-EOT
  The ID of the Application Load Balancer security group.
  This security group allows HTTP (port 80) traffic from anywhere
  and should be attached to the ALB.
  EOT
  value       = aws_security_group.alb.id
}

output "web_server_sg_id" {
  description = <<-EOT
  The ID of the web server security group.
  This security group:
  - Allows HTTP (port 80) traffic only from the ALB security group
  - Allows SSH (port 22) traffic only from your specified IP
  - Should be attached to all EC2 instances
  EOT
  value       = aws_security_group.web_server.id
}

output "alb_sg_arn" {
  description = "The ARN of the ALB security group"
  value       = aws_security_group.alb.arn
}

output "web_server_sg_arn" {
  description = "The ARN of the web server security group"
  value       = aws_security_group.web_server.arn
}

output "security_group_details" {
  description = <<-EOT
  A map containing all security group details including:
  - IDs
  - ARNs
  - Names
  - Descriptions
  Useful for debugging and integration with other modules.
  EOT
  value = {
    alb = {
      id          = aws_security_group.alb.id
      arn         = aws_security_group.alb.arn
      name        = aws_security_group.alb.name
      description = aws_security_group.alb.description
    }
    web_server = {
      id          = aws_security_group.web_server.id
      arn         = aws_security_group.web_server.arn
      name        = aws_security_group.web_server.name
      description = aws_security_group.web_server.description
    }
  }
}