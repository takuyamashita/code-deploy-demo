output "next_server_instance_profile_arn" {
  value = aws_iam_instance_profile.next_server_profile.arn
}

output "echo_server_instance_profile_arn" {
  value = aws_iam_instance_profile.echo_server_profile.arn
}

output "code_deploy_role_arn" {
  value = aws_iam_role.code_deploy_role.arn
}

  