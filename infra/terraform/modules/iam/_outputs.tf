output "next_server_instance_profile_arn" {
  value = aws_iam_instance_profile.next_server_profile.arn
}

output "gin_server_instance_profile_arn" {
  value = aws_iam_instance_profile.gin_server_profile.arn
}

output "code_deploy_role_arn" {
  value = aws_iam_role.code_deploy_role.arn
}

  