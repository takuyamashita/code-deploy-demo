source "amazon-ebs" "basic-example" {

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
  ami_name      = "packer_AWS {{timestamp}}"
}
