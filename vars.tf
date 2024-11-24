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
variable "component" {
  
}
variable "public_azs" {
  type = list(string)
}
variable "private_azs" {
  type = list(string) 
}