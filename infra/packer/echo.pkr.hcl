source "amazon-ebs" "echo-server" {

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
  ami_name      = "echo-server-{{timestamp}}"

  tags = {
    Role = "echo-server"
  }
}

build {

  name = "echo"

  sources = [
    "source.amazon-ebs.echo-server"
  ]

  provisioner "shell" {
    inline = concat(
      local.base_inlines,
      local.ssm_agent_inlines,
      local.cloudwatch_inlines,
      local.codedeploy_inlines,
    )
  }
}