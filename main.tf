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
  tags = {
    Name = "${var.env}-Public-subnet-${each.key + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.main.id
  for_each = zipmap(range(length(var.private_subnets)),var.private_subnets)
  cidr_block = var.private_subnets[each.key]
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