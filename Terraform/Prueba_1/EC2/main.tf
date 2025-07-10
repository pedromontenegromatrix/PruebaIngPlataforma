resource "aws_vpc" "this" {
  count                = local.borrado ? 0 : 1
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${local.env}-${var.project}-${var.name}-01"
  }
}

resource "aws_internet_gateway" "this" {
  count  = local.borrado ? 0 : 1
  vpc_id = aws_vpc.this[0].id

  tags = {
    Name = "ig-${local.env}-${var.project}-${var.name}-01"
  }

  depends_on = [aws_vpc.this]
}

resource "aws_default_route_table" "this" {
  count                  = local.borrado ? 0 : 1
  default_route_table_id = aws_vpc.this[0].default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Name = "rt-${local.env}-${var.project}-${var.name}-01"
  }
  depends_on = [aws_vpc.this]
}

resource "aws_subnet" "this" {
  count             = local.borrado ? 0 : 2
  vpc_id            = aws_vpc.this[0].id
  cidr_block        = element(local.array_nets, count.index)
  availability_zone = element(local.aws_availability_zones, count.index)

  tags = {
    Name = "sn-${local.env}-${var.project}-${var.name}-0${count.index + 1}"
  }

  depends_on = [aws_vpc.this]
}


resource "aws_security_group" "this" {
  count       = local.borrado ? 0 : 1
  name        = "sgr-${local.env}-${var.project}-${var.name}-01"
  description = "Allow traffic"
  vpc_id      = aws_vpc.this[0].id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["192.16.0.0/24"]
  }
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sgr-${local.env}-${var.project}-${var.name}-01"
  }

  depends_on = [aws_vpc.this]
}


resource "aws_iam_role" "this" {
  count = local.borrado ? 0 : 1

  name        = "role-${local.env}-${var.project}-${var.name}-01"
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
    Name = "role-${local.env}-${var.project}-${var.name}-01"
  }
}

resource "aws_iam_instance_profile" "this" {
  count = local.borrado ? 0 : 1
  name  = "role${local.env}-${var.project}-${var.name}-01"
  role  = aws_iam_role.this[0].name
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = local.borrado ? 0 : 1
  role       = aws_iam_role.this[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


data "template_file" "archivo_host" {
  template = file("scripts/bastion_host.sh")
  vars = {
    NEW_RELIC_LICENSE_KEY = var.new_relic_license_ec2
    NEW_RELIC_APP_NAME    = "NEW_RELIC_APPLICATION"
    NEW_RELIC_API_KEY     = var.new_relic_api_key
    NEW_RELIC_ACCOUNT_ID  = var.new_relic_account
  }
}

resource "aws_instance" "this" {
  count = local.borrado ? 0 : local.cantidad_ec2

  ami                         = local.bh_ami
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.this[0].id]
  subnet_id                   = aws_subnet.this[0].id
  associate_public_ip_address = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  iam_instance_profile = aws_iam_instance_profile.this[0].name
  #user_data            = filebase64("scripts/bastion_host.sh")
  user_data_base64 = base64encode(data.template_file.archivo_host.rendered)

  tags = {
    Name = "asgr-${local.env}-${var.project}-${var.name}-0${count.index + 1}"
  }

  depends_on = [
    aws_vpc.this,
    aws_subnet.this,
    aws_security_group.this,
    aws_iam_role.this,
    aws_iam_instance_profile.this
  ]
}
