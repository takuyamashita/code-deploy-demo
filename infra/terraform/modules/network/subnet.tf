locals {
  subnets = {
    "public_subnet_1a" = {
      az         = "ap-northeast-1a"
      public_ip  = true
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 0)
    },
    "private_subnet_1a" = {
      az         = "ap-northeast-1a"
      public_ip  = false
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 1)
    },
    "public_subnet_1c" = {
      az         = "ap-northeast-1c"
      public_ip  = true
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 2)
    },
    "private_subnet_1c" = {
      az         = "ap-northeast-1c"
      public_ip  = false
      cidr_block = cidrsubnet(var.vpc_cidr_block, 8, 3)
    },
  }
}

resource "aws_subnet" "subnet" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public_ip

  tags = {
    Name = "${each.key}"
  }
}
