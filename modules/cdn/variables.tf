variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alb_dns_name" {
  description = "Internal ALB DNS name to use as origin"
  type        = string
}

variable "alb_arn" {
  description = "Internal ALB ARN for VPC Origin"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for VPC Origin"
  type        = string
}

variable "private_subnets" {
  description = "Private subnet IDs for VPC Origin"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Security group ID for ALB"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the distribution"
  type        = string
}
