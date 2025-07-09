variable "branch" {
  type    = string
  default = "develop"
}

variable "project" {
  type    = string
  default = "test"
}

variable "name" {
  type    = string
  default = "prmr"
}

variable "cantidad_ec2" {
  type    = number
  default = 2
}

#######################################################################
variable "region" {
  type    = string
  default = "us-east-1"
}

variable "new_relic_account" {
  type    = string
  default = ""
}

variable "new_relic_api_key" {
  type    = string
  default = ""
}

variable "new_relic_region" {
  type    = string
  default = "US"
}

variable "new_relic_license_ec2" {
  type    = string
  default = ""
}
