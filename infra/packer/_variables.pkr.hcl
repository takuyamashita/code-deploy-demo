variable "assume_role_arn" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

locals {

  base_inlines = [
    "sudo yum update -y",
  ]

  ssm_agent_inlines = [
    "sudo yum install -y https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/linux_amd64/amazon-ssm-agent.rpm",
  ]

  //https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/install-CloudWatch-Agent-commandline-fleet.html
  cloudwatch_inlines = [
    "sudo yum install -y amazon-cloudwatch-agent",
  ]

  // https://docs.aws.amazon.com/ja_jp/codedeploy/latest/userguide/codedeploy-agent-operations-install-linux.html
  codedeploy_inlines = [
    "sudo yum install -y ruby wget",
    "cd /home/ec2-user",
    "wget https://aws-codedeploy-${var.region}.s3.${var.region}.amazonaws.com/latest/install",
    "chmod +x ./install",
    "sudo ./install auto",
  ]
}


