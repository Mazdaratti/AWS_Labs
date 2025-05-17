output "nlb_sg_id" {
  description = "Security Group ID for NLB"
  value       = aws_security_group.nlb_sg.id
}

output "ec2_sg_id" {
  description = "Security Group ID for EC2"
  value       = aws_security_group.ec2_sg.id
}
