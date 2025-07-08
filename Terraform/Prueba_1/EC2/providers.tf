terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws    = ">= 4.20.0"
    random = ">= 3.3.0"
    # Require the latest 2.x version of the New Relic provider
    newrelic = {
      source = "newrelic/newrelic"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }

  cloud {
    organization = "PruebaIngPlataforma"
    workspaces {
      name = "PruebaIngPlataforma"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "newrelic" {
  alias      = "newrelic"
  account_id = var.new_relic_account
  api_key    = var.new_relic_api_key
  region     = var.new_relic_region
}
