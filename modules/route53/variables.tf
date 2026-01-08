variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for private hosted zone"
  type        = string
}

variable "domain_name" {
  description = "Domain name for hosted zone"
  type        = string
}

variable "cdn_subdomain" {
  description = "Subdomain for CDN record"
  type        = string
}

variable "alb_dns_name" {
  description = "Internal ALB DNS name"
  type        = string
}

variable "alb_zone_id" {
  description = "Internal ALB hosted zone ID"
  type        = string
}
