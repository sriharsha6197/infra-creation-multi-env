resource "aws_security_group" "lb_sg" {
  name        = "${var.env}-lb-sec-grp-${var.alb_type}"
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

resource "aws_lb_listener" "http" {
  count = var.alb_type == "private" ? 1 :0
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}

resource "aws_lb_listener" "https" {
  count = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:us-east-1:624631298287:certificate/99c71f7a-cd4b-4463-8280-178136b40094"

  default_action {
    type             = "forward"
    target_group_arn = var.tg_arn
  }
}


resource "aws_lb_listener" "redirect_https" {
  count = var.alb_type == "public" ? 1 : 0
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}