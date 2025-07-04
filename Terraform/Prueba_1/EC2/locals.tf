locals {
  borrado                = true
  array_nets             = ["10.0.0.0/24", "10.0.1.0/24"]
  aws_availability_zones = slice(data.aws_availability_zones.this.names, 0, length(local.array_nets))
  bh_ami                 = "ami-05ffe3c48a9991133"
}
