resource "aws_security_group" "lb_sg" {
  name        = "lb_sec_grp"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-lb-secgrp"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = var.from_port
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = var.pb_rt_cidr_block
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lb_sg.id
  cidr_ipv4         = var.pb_rt_cidr_block
  ip_protocol       = "-1" # semantically equivalent to all ports
}



resource "aws_lb" "test" {
  name               = "${var.env}-${var.component}-${var.alb_type}-lb"
  internal           = var.internal
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.lb_sg.id]
  subnets = var.subnets
  tags = {
    Environment = "${var.env}-${var.lb_type}lb"
  }
}