variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "ecs-private-alb"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ecs_task_cpu" {
  description = "CPU units for ECS task (1024 = 1 vCPU)"
  type        = string
  default     = "256"
}

variable "ecs_task_memory" {
  description = "Memory for ECS task in MiB"
  type        = string
  default     = "512"
}

variable "ecs_desired_count" {
  description = "Desired number of ECS tasks"
  type        = number
  default     = 2
}

variable "nginx_image" {
  description = "Docker image for nginx container"
  type        = string
  default     = "nginx:latest"
}

variable "domain_name" {
  description = "Domain name for private hosted zone"
  type        = string
  default     = "mytest.com"
}

variable "cdn_subdomain" {
  description = "Subdomain for CDN endpoint"
  type        = string
  default     = "cdn"
}

variable "enable_cloudfront" {
  description = "Enable CloudFront distribution (requires ALB to be public)"
  type        = bool
  default     = false
}
