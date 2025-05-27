output "public_ec2_instance_profile" {
  value = aws_iam_instance_profile.public_ec2_profile.name
}

output "public_ec2_role_name" {
  description = "IAM role name for the public EC2 instance"
  value       = aws_iam_role.public_ec2_role.name
}

output "public_ec2_role_arn" {
  description = "IAM role ARN for the public EC2 instance"
  value       = aws_iam_role.public_ec2_role.arn
}

output "private_ec2_instance_profile" {
  value = aws_iam_instance_profile.private_ec2_profile.name
}

output "private_ec2_role_name" {
  description = "IAM role name for the private EC2 instance"
  value       = aws_iam_role.private_ec2_role.name
}

output "private_ec2_role_arn" {
  description = "IAM role ARN for the private EC2 instance"
  value       = aws_iam_role.private_ec2_role.arn
}
