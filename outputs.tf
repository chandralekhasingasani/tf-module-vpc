output "VPC_ID" {
  value = aws_vpc.main.id
}

output "VPC_CIDR" {
  value = var.CIDR_BLOCK
}

output "SUBNET_IDS" {
  value = aws_subnet.main.*.id
}
