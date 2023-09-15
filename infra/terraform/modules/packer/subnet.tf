resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr_block, 8, 0)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name                    = "packer-subnet"
    "${var.subnet_tag_key}" = var.subnet_tag_value
  }
}