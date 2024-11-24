data "aws_vpc" "default" {
  id = var.default
}
variable "default" {
  default = "vpc-0fcc12452e6fee993"
}