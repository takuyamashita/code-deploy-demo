locals {
  templates = {
    next_server = {
      image_id             = data.aws_ami.next-server.id
      security_group_ids   = [var.next_server_sg_id]
      instance_profile_arn = var.next_server_instance_profile_arn
    },
    gin_server = {
      image_id             = data.aws_ami.gin-server.id
      security_group_ids   = [var.gin_server_sg_id]
      instance_profile_arn = var.gin_server_instance_profile_arn
    },
  }
}

resource "aws_launch_template" "launch_template" {

  for_each = local.templates

  name = each.key

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = each.key
    }
  }

  image_id = each.value.image_id

  iam_instance_profile {
    arn = each.value.instance_profile_arn
  }

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  /*
  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }
  */

  credit_specification {
    cpu_credits = "standard"
  }

  update_default_version = true

  disable_api_stop        = false
  disable_api_termination = false

  ebs_optimized = false

  instance_initiated_shutdown_behavior = "terminate"

  instance_market_options {
    market_type = "spot"
  }

  instance_type = "t2.micro"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = false
    delete_on_termination       = true
    security_groups             = each.value.security_group_ids
  }

  user_data = base64encode(local.userdata)
}
locals {
  userdata = <<USERDATA
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="

--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"

#!/bin/bash
#gin "" | sudo tee -a /etc/codedeploy-agent/conf/codedeployagent.yml
#gin ":enable_auth_policy: true" | sudo tee -a /etc/codedeploy-agent/conf/codedeployagent.yml
#sudo systemctl restart codedeploy-agent
--==MYBOUNDARY==--\
USERDATA
}
