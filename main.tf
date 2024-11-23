resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnets
  for_each = zipmap(range(length(var.public_subnets)),var.public_subnets)

  tags = {
    Name = "${var.env}-Public-subnet-${each.key + 1}"
  }
}