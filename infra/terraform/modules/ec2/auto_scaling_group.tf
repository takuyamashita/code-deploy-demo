resource "aws_autoscaling_group" "asg" {

  for_each = var.server_spec

  name = each.key

  max_size         = each.value.max_size
  min_size         = each.value.min_size
  desired_capacity = each.value.desired_capacity

  termination_policies = ["OldestInstance"]

  vpc_zone_identifier = concat(var.next_server_subnet_ids, var.gin_server_subnet_ids)

  launch_template {
    id      = aws_launch_template.launch_template[each.key].id
    version = aws_launch_template.launch_template[each.key].latest_version
  }
}

resource "aws_autoscaling_policy" "autoscaling_policy" {

  for_each = aws_autoscaling_group.asg

  name = "default"
  autoscaling_group_name = each.key
  policy_type = "TargetTrackingScaling"

  // @see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_policy#estimated_instance_warmup  
  estimated_instance_warmup = 100

  target_tracking_configuration {

    // dd if=/dev/zero of=test.test bs=1M count=500 oflag=direct
    // sudo df
    target_value = 80.0

    // @see https://docs.aws.amazon.com/ja_jp/autoscaling/ec2/userguide/as-scaling-target-tracking.html
    // @see https://docs.aws.amazon.com/ja_jp/autoscaling/ec2/userguide/ec2-auto-scaling-target-tracking-metric-math.html
    customized_metric_specification {
      metric_name = "disk_used_percent"
      namespace   = "CWAgent"
      statistic   = "Average"
      unit = "Percent"
    
      metric_dimension {
        name = "AutoScalingGroupName"
        value = each.key
      }

      metric_dimension {
        name = "path"
        value = "/"
      }
    }
  }

}

resource "aws_autoscaling_attachment" "next" {
  autoscaling_group_name = aws_autoscaling_group.asg["next_server"].name
  lb_target_group_arn    = var.alb_next_target_group_arn
}

resource "aws_autoscaling_attachment" "gin_nlb" {
  autoscaling_group_name = aws_autoscaling_group.asg["gin_server"].name
  lb_target_group_arn    = var.nlb_gin_target_group_arn
}