resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.vpc_cidr_block
    gateway_id = "local"
  }
}

resource "aws_route_table_association" "aws_route_table_association" {
  for_each = local.subnets

  subnet_id      = aws_subnet.subnet[each.key].id
  route_table_id = each.value.public_ip ? aws_route_table.public_table.id : aws_route_table.private_table.id
}
