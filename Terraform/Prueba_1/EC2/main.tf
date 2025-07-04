resource "aws_vpc" "this" {
  count      = local.borrado ? 0 : 1
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-${var.env}-${var.project}-${var.name}-01"
  }
}

resource "aws_security_group" "this" {
  count       = local.borrado ? 0 : 1
  name        = "sgr-${var.env}-${var.project}-${var.name}-01"
  description = "Allow traffic"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.16.0.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgr-${var.env}-${var.project}-${var.name}-01"
  }
}

