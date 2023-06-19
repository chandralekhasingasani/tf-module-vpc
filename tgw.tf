data "terraform_remote_state" "tgw" {
  backend = "s3"
  config = {
    bucket = "terraform-b64"
    key    = "tgw/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app-vpc" {

  tags = {
    Name = "tgw-${var.COMPONENT}-vpcc-${var.ENV}"
  }
  subnet_ids         = aws_subnet.main.*.id
  transit_gateway_id = data.terraform_remote_state.tgw.outputs.TGW_ID
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id             = aws_vpc.main.id
}

resource "aws_ec2_transit_gateway_route_table" "app-vpc" {
  tags = {
    Name = "tgw-rt-${var.COMPONENT}-vpc-${var.ENV}"
  }
  transit_gateway_id = data.terraform_remote_state.tgw.outputs.TGW_ID
}

resource "aws_ec2_transit_gateway_route_table_association" "app-vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app-vpc.id
}

resource "aws_ec2_transit_gateway_route" "app-tgw-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = data.terraform_remote_state.tgw.outputs.TGW_DEFAULT_ATTACHMENT_ID
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app-vpc.id
}

resource "aws_ec2_transit_gateway_route" "default-vpc-tgw-route" {
  destination_cidr_block         = var.CIDR_BLOCK
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = data.terraform_remote_state.tgw.outputs.TGW_DEFAULT_ROUTE_TABLE_ID
}

resource "aws_route_table" "app-vpc" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block                = "0.0.0.0/0"
    transit_gateway_id        = data.terraform_remote_state.tgw.outputs.TGW_ID
  }

  tags = {
    Name = "private-subnet-${var.COMPONENT}-${var.ENV}"
  }
}

resource "aws_route_table_association" "private-rt" {
  count          = length(aws_subnet.main.*.id)
  subnet_id      = element(aws_subnet.main.*.id, count.index)
  route_table_id = aws_route_table.app-vpc.id
}

resource "aws_route" "route-default-public-subnet" {
  count                     = length(aws_subnet.main.*.id)
  route_table_id            = data.terraform_remote_state.tgw.outputs.PUBLIC_ROUTE_TABLE_ID_DEFAULT_VPC
  destination_cidr_block    = element(aws_subnet.main.*.cidr_block, count.index)
  transit_gateway_id        = data.terraform_remote_state.tgw.outputs.TGW_ID
}
