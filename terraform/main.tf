# Generate random suffix for unique resource names
resource "random_id" "suffix" {
  byte_length = 4
}

# Data source for Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
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

  vpc_cidr           = var.vpc_cidr
  aws_region         = var.aws_region
  public_subnet_cidr = var.public_subnet_cidrs[0]
}

# Security Groups Module
module "security_groups" {
  source = "./modules/sg"
}

# ACM Certificate Module
module "acm" {
  source = "./modules/acm"

  domain  = var.domain_name
  zone_id = var.route53_zone_id
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnet_ids
  acm_arn    = module.acm.certificate_arn
}

# Launch Template and Auto Scaling Group
module "compute" {
  source = "./modules/ec2"

  vpc_id        = module.vpc.vpc_id
  alb_sg_id     = module.alb.security_group_id
  ssh_cidr      = var.allowed_cidr_blocks[0]
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  subnet_id     = module.vpc.public_subnet_ids[0]
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

  project_name   = var.project_name
  environment    = var.environment
  alb_arn_suffix = module.alb.arn_suffix
  asg_name       = module.compute.auto_scaling_group_name
  aws_region     = var.aws_region
  enable_alarms  = true
  sns_topic_arn  = null

  tags = local.common_tags
}

# WAF Web Application Firewall (Optional)
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "./modules/waf"

  project_name = var.project_name
  environment  = var.environment
  alb_arn      = module.alb.arn

  tags = local.common_tags
}

# Backup and Disaster Recovery
module "backup" {
  count  = var.enable_backup ? 1 : 0
  source = "./modules/backup"

  project_name = var.project_name
  environment  = var.environment
  kms_key_arn  = null

  tags = local.common_tags
}