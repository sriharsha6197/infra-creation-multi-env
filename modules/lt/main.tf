resource "aws_security_group" "lt_sg" {
  name        = "${var.env}-lt-sec-grp-${var.component}"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env}-lt-secgrp-${var.component}"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.lt_sg.id
  cidr_ipv4         = "192.168.0.0/16"
  from_port         = var.app_port
  ip_protocol       = "tcp"
  to_port           = var.app_port
}
resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.lt_sg.id
  cidr_ipv4 = var.terraform_instance
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.lt_sg.id
  cidr_ipv4         = var.pb_rt_cidr_block
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_iam_role" "test_role" {
  name = "${var.env}-${var.component}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${var.env}-${var.component}-role"
  }
}
resource "aws_iam_role_policy" "test_policy" {
  name = "${var.env}-${var.component}-role-policy"
  role = aws_iam_role.test_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ssm:PutParameter",
		  "ssm:LabelParameterVersion",
          "ssm:DeleteParameter",
          "ssm:UnlabelParameterVersion",
          "ssm:DescribeParameters",
          "ssm:GetParameterHistory",
          "ssm:DescribeDocumentParameters",
          "ssm:GetParametersByPath",
          "ssm:GetParameters",
          "ssm:GetParameter",
          "ssm:DeleteParameters"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
resource "aws_iam_instance_profile" "test_profile" {
  name = "${var.env}-${var.component}-iam_instance_profile"
  role = aws_iam_role.test_role.name
}
resource "aws_launch_template" "foo" {
  name = "${var.env}-lt-${var.component}"
  iam_instance_profile {
    name = aws_iam_instance_profile.test_profile.name
  }
  image_id = data.aws_ami.image_id.image_id
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.lt_sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.env}-lt-${var.component}"
    }
  }

  user_data = base64encode(templatefile("${path.module}/userdata.sh",{
   env = var.env,
   role_name = var.component
}))
}

resource "aws_autoscaling_group" "bar" {
  name = "${var.env}-${var.component}-asg"
  desired_capacity   = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnets 
  target_group_arns = [aws_lb_target_group.tg.arn]
  launch_template {
    id      = aws_launch_template.foo.id
    version = "$Latest"
  }
}

resource "aws_lb_target_group" "tg" {
  name        = "${var.env}-${var.component}-tg"
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  deregistration_delay = 30
  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 5
    path = "/health"
    port = var.app_port
    timeout = 3
    unhealthy_threshold = 2
  }
}