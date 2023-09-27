resource "aws_eip" "nat_gateway_eip" {
  for_each = toset(["public_subnet_1a", "public_subnet_1c"])
}

resource "aws_nat_gateway" "nat_gateway" {

  for_each = toset(["public_subnet_1a", "public_subnet_1c",])

  allocation_id = aws_eip.nat_gateway_eip[each.value].id
  subnet_id = aws_subnet.subnet[each.value].id

  depends_on = [ aws_internet_gateway.igw ]
}