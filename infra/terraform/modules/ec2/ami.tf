data "aws_ami" "next-server" {
  most_recent = true

  filter {
    name   = "tag:Role"
    values = ["next-server"]
  }
}

data "aws_ami" "gin-server" {
  most_recent = true

  filter {
    name   = "tag:Role"
    values = ["gin-server"]
  }
}
