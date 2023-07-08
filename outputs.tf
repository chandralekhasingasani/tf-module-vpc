output "VPC_ID" {
  value = aws_vpc.main.id
}

output "VPC_CIDR" {
  value = var.CIDR_BLOCK
}

output "SUBNET_IDS" {
  value = aws_subnet.main.*.id
}

output "PRIVATE_HOSTED_ZONE_ID" {
  value = data.aws_route53_zone.selected.id
}

data "aws_route53_zone" "selected" {
  name         = "roboshop.internal"
  private_zone = true
}

resource "aws_route53_zone_association" "secondary" {
  zone_id = data.aws_route53_zone.selected.id
  vpc_id  = aws_vpc.main.id
}