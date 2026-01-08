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

variable "private_subnets" {
  description = "List of private subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_group" {
  description = "Security group ID for ALB"
  type        = string
}
