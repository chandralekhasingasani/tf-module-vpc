data "terraform_remote_state" "tgw" {
  backend = "s3"
  config = {
    bucket = "terraform-b64"
    key    = "tgw/terraform.tfstate"
    region = "us-east-1"
  }
}

output "NAT_GW_IP" {
  value = data.terraform_remote_state.tgw.outputs.NAT_GW_IP
}

resource "aws_ec2_transit_gateway_vpc_attachment" "app-vpc" {

  tags = {
    Name = "tgw-${var.COMPONENT}-vpc-${var.ENV}"
  }
  subnet_ids         = aws_subnet.main.*.id
  transit_gateway_id = data.terraform_remote_state.tgw.outputs.TGW_ID
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  vpc_id             = aws_vpc.main.id
}

resource "aws_ec2_transit_gateway_route" "default-vpc-tgw-route" {
  destination_cidr_block         = var.CIDR_BLOCK
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = data.terraform_remote_state.tgw.outputs.TGW_DEFAULT_ROUTE_TABLE_ID
}


resource "aws_ec2_transit_gateway_route_table_association" "app-vpc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app-vpc.id
  transit_gateway_route_table_id = data.terraform_remote_state.tgw.outputs.ALL_COMPONENT_ROUTE_TABLE_ID
}

