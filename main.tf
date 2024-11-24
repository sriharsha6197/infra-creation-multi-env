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

module "frontend" {
  source = "./modules/lt"
  env = var.env
  instance_type = var.instance_type
  component = "frontend"
  vpc_id = module.vpc.vpc_id
  app_port = 80
  pb_rt_cidr_block = var.pb_rt_cidr_block
  subnets = module.vpc.public_subnets
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
  terraform_instance = var.terraform_instance
}

module "backend" {
  source = "./modules/lt"
  env = var.env
  instance_type = var.instance_type
  pb_rt_cidr_block = "192.168.0.0/16"
  component = "backend"
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id
  app_port = 8080
  terraform_instance = var.terraform_instance
  desired_capacity = var.desired_capacity
  max_size = var.max_size
  min_size = var.min_size
}