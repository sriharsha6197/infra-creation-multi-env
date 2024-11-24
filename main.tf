module "vpc" {
  source = "./modules/vpc"
  env = var.env
  from_port = var.from_port
  pb_rt_cidr_block = var.pb_rt_cidr_block
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  private_azs = var.private_azs
  public_azs = var.public_azs
}

module "public" {
  source = "./modules/lb"
  vpc_id = module.vpc.vpc_id
  env = var.env
  internal = false
  alb_type = "public"
  lb_type = "application"
  subnets = module.vpc.public_subnets
  from_port = var.from_port
  pb_rt_cidr_block = var.pb_rt_cidr_block
  component = "frontend"
}

module "private" {
  source = "./modules/lb"
  env = var.env
  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.private_subnets
  from_port = var.from_port
  alb_type = "private"
  internal = true
  lb_type = "application"
  pb_rt_cidr_block = var.pb_rt_cidr_block
  component = "backend"
}