resource "aws_codedeploy_app" "code_deploy" {
  for_each = aws_autoscaling_group.asg

  name = each.value.name
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  for_each = aws_autoscaling_group.asg

  app_name               = aws_codedeploy_app.code_deploy[each.key].name
  deployment_group_name  = "${each.key}_deployment_group"
  autoscaling_groups     = [aws_autoscaling_group.asg[each.key].name]
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  service_role_arn       = var.code_deploy_service_role_arn

  /*
  deployment_style {
    deployment_type = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  // @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group#blue_green_deployment_config-argument-reference
  blue_green_deployment_config {
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }

    deployment_ready_option {
      // @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codedeploy_deployment_group#action_on_timeout
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    green_fleet_provisioning_option {
      // @see https://docs.aws.amazon.com/codedeploy/latest/APIReference/API_GreenFleetProvisioningOption.html
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  load_balancer_info {
    target_group_info {
      name = var.target_group_names[each.key]
    }
  }
  */
}