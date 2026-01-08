output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnets" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnets" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

output "alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "Internal ALB ARN"
  value       = module.alb.alb_arn
}

output "ecs_cluster_id" {
  description = "ECS Cluster ID"
  value       = module.ecs.cluster_id
}

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = module.ecs.service_name
}

output "ec2_instance_id" {
  description = "EC2 Instance ID"
  value       = module.ec2.instance_id
}

output "ec2_private_ip" {
  description = "EC2 Instance private IP"
  value       = module.ec2.private_ip
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = var.enable_cloudfront ? module.cdn[0].distribution_id : null
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = var.enable_cloudfront ? module.cdn[0].domain_name : null
}

output "route53_zone_id" {
  description = "Route53 private hosted zone ID"
  value       = module.route53.zone_id
}

output "cdn_fqdn" {
  description = "Full CDN domain name (cdn.mytest.com)"
  value       = module.route53.cdn_fqdn
}

output "ssm_connect_command" {
  description = "Command to connect to EC2 instance via SSM"
  value       = "aws ssm start-session --target ${module.ec2.instance_id} --region ${var.aws_region}"
}
