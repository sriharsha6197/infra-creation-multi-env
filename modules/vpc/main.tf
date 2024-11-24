resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  cidr_block = var.public_subnets[each.key]
  availability_zone = var.public_azs
  tags = {
    Name = "${var.env}-Public-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.main.id
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  cidr_block = var.private_subnets[each.key]
  availability_zone = var.private_azs
  tags = {
    Name = "${var.env}-Private-subnet-${each.key + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
  }
}

resource "aws_route_table" "pb_route_table" {
  vpc_id = aws_vpc.main.id
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  route {
    cidr_block = var.pb_rt_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.env}-pb-route-table-${each.key + 1}"
  }
}

resource "aws_route_table_association" "a" {
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  subnet_id      = aws_subnet.main[each.key].id
  route_table_id = aws_route_table.pb_route_table[each.key].id
}

resource "aws_eip" "eip" {
  count =2
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat" {
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)
  allocation_id = aws_eip.eip[each.key].id
  subnet_id     = aws_subnet.main[each.key].id
  
  tags = {
    Name = "${var.env}-NATGW-${each.key +1 }"
  }
}

resource "aws_route_table" "pvt_route_table" {
  vpc_id = aws_vpc.main.id
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  route {
    cidr_block = var.pb_rt_cidr_block
    gateway_id = aws_nat_gateway.nat[each.key].id
  }
  tags = {
    Name = "${var.env}-pvt-route-table-${each.key + 1}"
  }
}

resource "aws_route_table_association" "b" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  subnet_id = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.pvt_route_table[each.key].id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.env}-secgrp"
  }
}
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  for_each = var.from_port
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.pb_rt_cidr_block
  from_port         = each.value
  ip_protocol       = "tcp"
  to_port           = each.value
}
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = var.pb_rt_cidr_block
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_peering_connection" "foo" {
  peer_owner_id = aws_vpc.main.owner_id
  peer_vpc_id   = data.aws_vpc.default.id
  vpc_id        = aws_vpc.main.id
  auto_accept   = true

  tags = {
    Name = "VPC Peering between ${aws_vpc.main.tags[Name]} and ${data.aws_vpc.default.tags[Name]} "
  }
}

resource "aws_route" "route_to_default_vpc" {
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  route_table_id            = aws_route_table.pvt_route_table[each.key].id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}

resource "aws_route" "route_from_default_vpc" {
  route_table_id = data.aws_vpc.default.main_route_table_id
  destination_cidr_block = aws_vpc.main.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.foo.id
}