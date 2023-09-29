output "subnet_ids" {
  value = { for k, v in aws_subnet.subnet : k => v.id }
}

output "security_group_ids" {
  value = { for k, v in aws_security_group.sg : k => v.id }
}

output "availability_zones" {
  value = toset([for k, v in aws_subnet.subnet : v.availability_zone])
}

output "alb_next_target_group_arn" {
  value = aws_lb_target_group.next_server.arn
}

output "nlb_echo_target_group_arn" {
  value = aws_lb_target_group.echo_server.arn
}

output "next_server_target_group_name" {
  value = aws_lb_target_group.next_server.name
}

output "echo_server_target_group_name" {
  value = aws_lb_target_group.echo_server.name
}
