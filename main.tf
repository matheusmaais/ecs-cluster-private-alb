locals {

}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

module "vpc" {
  source = "./modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "security_groups" {
  source = "./modules/security_groups"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
}

module "alb" {
  source = "./modules/alb"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnets    = module.vpc.private_subnets
  alb_security_group = module.security_groups.alb_security_group_id
}

module "ecs" {
  source = "./modules/ecs"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnets
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  ecs_execution_role_arn = module.iam.ecs_task_execution_role_arn
  ecs_security_group     = module.security_groups.ecs_security_group_id
  target_group_arn       = module.alb.target_group_arn
  task_cpu               = var.ecs_task_cpu
  task_memory            = var.ecs_task_memory
  desired_count          = var.ecs_desired_count
  nginx_image            = var.nginx_image
}

module "ec2" {
  source = "./modules/ec2"

  project_name         = var.project_name
  environment          = var.environment
  vpc_id               = module.vpc.vpc_id
  subnet_id            = module.vpc.private_subnets[0]
  ec2_security_group   = module.security_groups.ec2_security_group_id
  iam_instance_profile = module.iam.ec2_instance_profile_name
  instance_type        = var.ec2_instance_type
  cdn_fqdn             = "${var.cdn_subdomain}.${var.domain_name}"
  alb_dns_name         = module.alb.alb_dns_name
}

module "cdn" {
  count  = var.enable_cloudfront ? 1 : 0
  source = "./modules/cdn"

  project_name           = var.project_name
  environment            = var.environment
  alb_dns_name           = module.alb.alb_dns_name
  alb_arn                = module.alb.alb_arn
  vpc_id                 = module.vpc.vpc_id
  private_subnets        = module.vpc.private_subnets
  alb_security_group_id  = module.security_groups.alb_security_group_id
  domain_name            = var.domain_name
}

module "route53" {
  source = "./modules/route53"

  project_name  = var.project_name
  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  domain_name   = var.domain_name
  cdn_subdomain = var.cdn_subdomain
  alb_dns_name  = module.alb.alb_dns_name
  alb_zone_id   = module.alb.alb_zone_id
}
