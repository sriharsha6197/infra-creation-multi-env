data "aws_ami" "image_id" {
  most_recent = true
  name_regex = "Centos-8-DevOps-Practice"
  owners = ["973714476881"]
}

output "tg_arn" {
  value = aws_lb_target_group.tg.arn
}