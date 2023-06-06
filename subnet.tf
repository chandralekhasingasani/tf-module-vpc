resource "aws_subnet" "main" {
  count      = length(var.AZ)
  vpc_id     = aws_vpc.main.id
  cidr_block = element(var.SUBNET_CIDR_BLOCK,count.index)

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}-${count.index + 1}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.COMPONENT}-${var.ENV}-public"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public.id
}