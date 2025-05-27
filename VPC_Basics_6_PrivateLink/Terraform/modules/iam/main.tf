###############################################
# IAM Roles and Policies for EC2 Instances
# This module creates two IAM roles:
# - One for the public EC2 instance
# - One for the private EC2 instance
# Each role is granted:
# - AmazonEC2ReadOnlyAccess: allows describing EC2 instances
# - AmazonS3FullAccess: allows uploading files to S3
# Assumes EC2 service role using sts:AssumeRole
# It also creates instance profiles, which are required for attaching roles to EC2 instances.
###############################################

# Assume role policy used by both EC2 roles
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# =====================
# Public EC2 Resources
# =====================

# IAM Role for Public EC2 Instance
resource "aws_iam_role" "public_ec2_role" {
  name = var.public_ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# Instance Profile for Public EC2 Instance
resource "aws_iam_instance_profile" "public_ec2_profile" {
  name = "${var.public_ec2_role_name}-profile"
  role = aws_iam_role.public_ec2_role.name
}

# Attach Policies to Public EC2 Role
resource "aws_iam_role_policy_attachment" "public_ec2_s3" {
  role       = aws_iam_role.public_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "public_ec2_ec2" {
  role       = aws_iam_role.public_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# =================================
# Private EC2 Resources
# =================================

# IAM Role for Private EC2 Instance
resource "aws_iam_role" "private_ec2_role" {
  name = var.private_ec2_role_name
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# Instance Profile for Private EC2 Instance
resource "aws_iam_instance_profile" "private_ec2_profile" {
  name = "${var.private_ec2_role_name}-profile"
  role = aws_iam_role.private_ec2_role.name
}

# Attach Policies to Private EC2 Role
resource "aws_iam_role_policy_attachment" "private_ec2_s3" {
  role       = aws_iam_role.private_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "private_ec2_ec2" {
  role       = aws_iam_role.private_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

