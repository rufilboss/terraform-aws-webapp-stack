module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name = "rstudio-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a"]
  public_subnets  = [var.public_subnet_cidr]

  enable_nat_gateway = false
  tags = { Environment = "production" }
}