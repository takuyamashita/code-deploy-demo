resource "aws_autoscaling_group" "asg" {

  for_each = var.server_spec

  name = each.key

  max_size         = each.value.max_size
  min_size         = each.value.min_size
  desired_capacity = each.value.desired_capacity

  vpc_zone_identifier = concat(var.next_server_subnet_ids, var.echo_server_subnet_ids)

  launch_template {
    id      = aws_launch_template.launch_template[each.key].id
    version = aws_launch_template.launch_template[each.key].latest_version
  }
}

resource "aws_autoscaling_attachment" "next" {
  autoscaling_group_name = aws_autoscaling_group.asg["next_server"].name
  lb_target_group_arn    = var.alb_next_target_group_arn
}

resource "aws_autoscaling_attachment" "echo_nlb" {
  autoscaling_group_name = aws_autoscaling_group.asg["echo_server"].name
  lb_target_group_arn    = var.nlb_echo_target_group_arn
}