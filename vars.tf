variable "public_subnets" {
  type = list(string)
}
variable "env" {
  
}
variable "private_subnets" {
  type = list(string)
}
variable "pb_rt_cidr_block" {
  
}
variable "from_port" {
  type = set(string)
}
variable "internal" {
  
}
variable "lb_type" {
  
}
variable "alb_type" {
  
}
variable "component" {
  
}
variable "public_azs" {
  type = list(string)
}
variable "private_azs" {
  type = list(string) 
}
variable "instance_type" {
  
}
variable "app_port" {
  
}
variable "desired_capacity" {
  
}
variable "max_size" {
  
}
variable "min_size" {
  
}
variable "subnets" {
  
}
variable "terraform_instance" {
  
}