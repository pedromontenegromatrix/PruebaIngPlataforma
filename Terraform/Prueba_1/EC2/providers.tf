terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws    = ">= 4.20.0"
    random = ">= 3.3.0"
  }

  #backend "remote" {}
}

provider "aws" {
  #access_key = var.access_key
  #secret_key = var.secret_key
  region = var.region
}
