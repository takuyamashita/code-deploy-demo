source "amazon-ebs" "gin-server" {

  assume_role {
    role_arn = var.assume_role_arn
  }

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  subnet_filter {
    filters = {
      "tag:ID" = "packer-subnet"
    }
  }

  instance_type = "t2.micro"
  ssh_username  = "ec2-user"
  ami_name      = "gin-server-{{timestamp}}"

  tags = {
    Role = "gin-server"
  }
}

build {

  name = "gin"

  sources = [
    "source.amazon-ebs.gin-server"
  ]

  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/packer/cloudwatch",
      "mkdir -p /tmp/packer/codedeploy",
    ]
  }

  provisioner "file" {
    source      = "cloudwatch/config.gin.json"
    destination = "/tmp/packer/cloudwatch/config.json"
  }

  provisioner "file" {
    source     = "codedeploy/codedeployagent.gin.yml"
    destination = "/tmp/packer/codedeploy/codedeployagent.yml"
  }

  provisioner "shell" {
    inline = concat(
      local.base_inlines,
      local.ssm_agent_inlines,
      local.cloudwatch_inlines,
      local.codedeploy_inlines,
    )
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/packer/cloudwatch/config.json /opt/aws/amazon-cloudwatch-agent/bin/config.json",
      "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json",
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo mv /tmp/packer/codedeploy/codedeployagent.yml /etc/codedeploy-agent/conf/codedeployagent.yml",
      "sudo systemctl restart codedeploy-agent",
    ]
  }
}