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
}
