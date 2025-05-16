output "log_group_name" {
  description = "CloudWatch Log Group for VPC Flow Logs"
  value       = aws_cloudwatch_log_group.vpc_flow_logs.name
}
