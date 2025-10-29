module "vpc" {
  source          = "./modules/vpc"
  aws_region      = var.aws_region
  public_subnet_cidr = var.public_subnet_cidr
}

module "acm" {
  source    = "./modules/acm"
  domain    = var.domain
  zone_id   = var.route53_zone_id
}

module "alb" {
  source    = "./modules/alb"
  vpc_id    = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets
  acm_arn   = module.acm.cert_arn
}

module "ec2" {
  source     = "./modules/ec2"
  vpc_id     = module.vpc.vpc_id
  subnet_id  = module.vpc.public_subnets[0]
  alb_sg_id  = module.alb.alb_sg_id
}

module "route53" {
  source      = "./modules/route53"
  domain      = var.domain
  zone_id     = var.route53_zone_id
  alb_dns     = module.alb.alb_dns
  alb_zone_id = module.alb.alb_zone_id
}

resource "aws_lb_target_group_attachment" "attach" {
  target_group_arn = module.alb.tg_arn
  target_id        = module.ec2.instance_id
  port             = 80
}