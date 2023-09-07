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

resource "aws_route_table_association" "aws_route_table_association" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.public_table.id
}