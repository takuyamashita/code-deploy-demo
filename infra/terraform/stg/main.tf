terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {}
}

variable "assume_role_arn" {
  type = string
}

provider "aws" {
  assume_role {
    role_arn = var.assume_role_arn
  }
  default_tags {
    tags = {
      "Terraform"   = "true"
      "Environment" = "staging"
    }
  }
}

module "network" {
  source         = "../modules/network"
  vpc_cidr_block = "10.0.0.0/16"
}
