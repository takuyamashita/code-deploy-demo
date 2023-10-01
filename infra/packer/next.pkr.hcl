source "amazon-ebs" "next-server" {

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
  ami_name      = "next-server-{{timestamp}}"

  tags = {
    Role = "next-server"
  }
}

build {

  name = "next"

  sources = [
    "source.amazon-ebs.next-server"
  ]

  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/packer/cloudwatch",
      "mkdir -p /tmp/packer/codedeploy",
    ]
  }

  provisioner "file" {
    source      = "cloudwatch/config.next.json"
    destination = "/tmp/packer/cloudwatch/config.json"
  }

  provisioner "file" {
    source     = "codedeploy/codedeployagent.next.yml"
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
      "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash",
      ". ~/.nvm/nvm.sh",
      "nvm install 16",
      "npm install -g yarn",
    ]
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
