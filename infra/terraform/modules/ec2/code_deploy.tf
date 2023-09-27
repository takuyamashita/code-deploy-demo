resource "aws_codedeploy_app" "next_code_deploy" {
  name = "next_code_deploy"
}

resource "aws_codedeploy_deployment_group" "next_deployment_group" {
  app_name              = aws_codedeploy_app.next_code_deploy.name
  deployment_group_name = "next_deployment_group"
  autoscaling_groups     = [aws_autoscaling_group.asg["next_server"].name]
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn      = var.code_deploy_service_role_arn
}

resource "aws_codedeploy_app" "echo_code_deploy" {
  name = "echo_code_deploy"
}

resource "aws_codedeploy_deployment_group" "echo_deployment_group" {
  app_name               = aws_codedeploy_app.echo_code_deploy.name
  deployment_group_name  = "echo_deployment_group"
  autoscaling_groups     = [aws_autoscaling_group.asg["echo_server"].name]
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = var.code_deploy_service_role_arn
}
