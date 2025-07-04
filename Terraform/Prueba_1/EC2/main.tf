resource "aws_vpc" "this" {
  count      = local.borrado ? 0 : 1
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-${var.env}-${var.project}-${var.name}-01"
  }
}

resource "aws_subnet" "this" {
  count             = local.borrado ? 0 : 2
  vpc_id            = aws_vpc.this.id
  cidr_block        = element(local.array_nets, count.index)
  availability_zone = element(local.aws_availability_zones, count.index)
  depends_on        = [aws_vpc.this]
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

  depends_on = [aws_vpc.this]
}


resource "aws_iam_role" "this" {
  count = local.borrado ? 0 : 1

  name        = "role-${var.env}-${var.project}-${var.name}-01"
  description = "Role for SSM Bastion Hosts"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
  })

  tags = {
    Name = "role-${var.env}-${var.project}-${var.name}-01"
  }
}

resource "aws_iam_instance_profile" "this" {
  count = local.borrado ? 0 : 1
  name  = "role${var.env}-${var.project}-${var.name}-01"
  role  = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = local.borrado ? 0 : 1
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


resource "aws_instance" "this" {
  count = local.borrado ? 0 : 1

  ami                    = local.bh_ami
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.this[0].id]
  subnet_id              = aws_subnet.this[0].id

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  iam_instance_profile = aws_iam_instance_profile.this[0].name
  user_data            = filebase64("scripts/bastion_host.sh")

  tags = {
    Name = "asgr-${var.env}-${var.project}-${var.name}-01"
  }

  depends_on = [
    aws_vpc.this,
    aws_subnet.this,
    aws_security_group.this,
    aws_iam_role.this,
    aws_iam_instance_profile.this
  ]
}
