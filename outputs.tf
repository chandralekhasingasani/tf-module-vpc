output "VPC_ID" {
  value = aws_vpc.main.id
}

output "SUBNET_IDS" {
  value = aws_subnet.main.*.id
}
