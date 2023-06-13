resource "aws_vpc" "main" {
  cidr_block       = var.CIDR_BLOCK

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app-vpc" {
  tags = {
    Name = "tgw-${var.COMPONENT}-vpc-${ENV}"
  }
  subnet_ids         = aws_subnet.main.id
  transit_gateway_id = var.TGW_ID
  vpc_id             = aws_vpc.main.id
}

resource "aws_ec2_transit_gateway_route_table" "app-vpc" {
  tags = {
    Name = "tgw-rt-${var.COMPONENT}-vpc-${ENV}"
  }
  transit_gateway_id = var.TGW_ID
}

resource "aws_ec2_transit_gateway_route_table_association" "app-vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app-vpc.id
}

resource "aws_ec2_transit_gateway_route" "app-tgw-route" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = var.TGW_DEFAULT_ATTACHMENT_ID
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app-vpc.id
}

resource "aws_ec2_transit_gateway_route" "default-vpc-tgw-route" {
  destination_cidr_block         = var.CIDR_BLOCK
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = var.TGW_DEFAULT_ROUTE_TABLE_ID
}

resource "aws_route_table" "app-vpc" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.TGW_ID
  }

  tags = {
    Name = "private-subnet-${var.COMPONENT}-${var.ENV}"
  }
}

resource "aws_route" "route-default-public-subnet" {
  route_table_id            = var.PUBLIC_ROUTE_TABLE_ID_DEFAULT_VPC
  destination_cidr_block    = aws_subnet.main.cidr_block
  transit_gateway_id        = var.TGW_ID
}