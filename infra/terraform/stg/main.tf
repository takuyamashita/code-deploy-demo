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

module "packer" {
  source = "../modules/packer"
  vpc_cidr_block = "10.10.0.0/16"
  availability_zone = "ap-northeast-1a"
  subnet_tag_key = "ID"
  subnet_tag_value = "packer-subnet"
}

module "network" {
  source         = "../modules/network"
  vpc_cidr_block = "10.0.0.0/16"
}
