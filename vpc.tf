resource "aws_vpc" "main" {
  cidr_block       = var.CIDR_BLOCK

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}

