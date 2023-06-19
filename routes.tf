resource "aws_route_table" "app-vpc" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-subnet-${var.COMPONENT}-${var.ENV}"
  }
}

resource "aws_route" "all-component-traffic-to-tgw" {
  route_table_id         = aws_route_table.app-vpc.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.tgw.outputs.TGW_ID
}

resource "aws_route_table_association" "private-rt" {
  count          = length(aws_subnet.main.*.id)
  subnet_id      = element(aws_subnet.main.*.id, count.index)
  route_table_id = aws_route_table.app-vpc.id
}

resource "aws_route" "route-default-public-subnet" {
  route_table_id            = data.terraform_remote_state.tgw.outputs.DEFAULT_VPC_RT
  destination_cidr_block    = aws_vpc.main.cidr_block
  transit_gateway_id        = data.terraform_remote_state.tgw.outputs.TGW_ID
}
