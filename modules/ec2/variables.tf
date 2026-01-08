variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instance"
  type        = string
}

variable "ec2_security_group" {
  description = "Security group ID for EC2 instance"
  type        = string
}

variable "iam_instance_profile" {
  description = "IAM instance profile name for EC2"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "cdn_fqdn" {
  description = "Full CDN domain name (e.g., cdn.mytest.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "Internal ALB DNS name"
  type        = string
}
