output "vpc_id" {
  value = aws_vpc.main.id
}
output "public_subnets" {
  value = values(aws_subnet.main)[*].id
}
output "private_subnets" {
  value = values(aws_subnet.private_subnets)[*].id
}