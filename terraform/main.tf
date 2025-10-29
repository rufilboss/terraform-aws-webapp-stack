# Generate random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Local values for consistent naming and tagging
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Owner       = var.owner
    CostCenter  = var.cost_center
  }
}

# VPC Module - Enhanced networking with multiple AZs
module "vpc" {
  source = "./modules/vpc"

  name_prefix          = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.common_tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/sg"

  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  allowed_cidr_blocks = var.allowed_cidr_blocks

  tags = local.common_tags
}

# ACM Certificate Module
module "acm" {
  source = "./modules/acm"

  domain_name = var.domain_name
  zone_id     = var.route53_zone_id

  tags = local.common_tags
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  name_prefix         = local.name_prefix
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  security_group_ids  = [module.security_groups.alb_security_group_id]
  certificate_arn     = module.acm.certificate_arn
  enable_access_logs  = var.enable_access_logs
  enable_ssl_redirect = var.enable_ssl_redirect

  tags = local.common_tags
}

# Launch Template and Auto Scaling Group
module "compute" {
  source = "./modules/ec2"

  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  private_subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids         = [module.security_groups.ec2_security_group_id]
  target_group_arn           = module.alb.target_group_arn
  instance_type              = var.instance_type
  ami_id                     = data.aws_ami.ubuntu.id
  min_size                   = var.min_size
  max_size                   = var.max_size
  desired_capacity           = var.desired_capacity
  enable_auto_scaling        = var.enable_auto_scaling
  enable_detailed_monitoring = var.enable_detailed_monitoring

  tags = local.common_tags
}

# Route53 DNS Module
module "route53" {
  source = "./modules/route53"

  domain              = var.domain_name
  zone_id             = var.route53_zone_id
  alb_dns             = module.alb.dns_name
  alb_zone_id         = module.alb.zone_id
  aws_region          = var.aws_region
  create_www_record   = true
  enable_health_check = true
  sns_topic_arn       = var.notification_email != "" ? module.monitoring[0].sns_topic_arn : null

  tags = local.common_tags
}

# CloudWatch Monitoring and Alerting
module "monitoring" {
  count  = var.notification_email != "" ? 1 : 0
  source = "./modules/monitoring"

  name_prefix             = local.name_prefix
  notification_email      = var.notification_email
  alb_arn                 = module.alb.arn
  target_group_arn        = module.alb.target_group_arn
  auto_scaling_group_name = module.compute.auto_scaling_group_name
  log_retention_days      = var.log_retention_days

  tags = local.common_tags
}

# WAF Web Application Firewall (Optional)
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "./modules/waf"

  name_prefix = local.name_prefix
  alb_arn     = module.alb.arn

  tags = local.common_tags
}

# Backup and Disaster Recovery
module "backup" {
  source = "./modules/backup"

  name_prefix                = local.name_prefix
  backup_retention_days      = var.backup_retention_days
  enable_cross_region_backup = var.enable_cross_region_backup

  tags = local.common_tags
}