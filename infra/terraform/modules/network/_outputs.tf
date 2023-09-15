output "subnet_ids" {
  value = { for k, v in aws_subnet.subnet : k => v.id }
}

output "security_group_ids" {
  value = { for k, v in aws_security_group.sg : k => v.id }
}

output "availability_zones" {
  value = toset([for k, v in aws_subnet.subnet : v.availability_zone])
}
