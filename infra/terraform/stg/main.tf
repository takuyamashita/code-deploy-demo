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

module "iam" {
  source = "../modules/iam"
}

module "ec2" {
  source = "../modules/ec2"

  availability_zones = module.network.availability_zones

  echo_server_instance_profile_arn = module.iam.echo_server_instance_profile_arn
  next_server_instance_profile_arn = module.iam.next_server_instance_profile_arn

  echo_server_subnet_ids = [module.network.subnet_ids["private_subnet_1a"]]
  next_server_subnet_ids = [module.network.subnet_ids["private_subnet_1a"]]

  echo_server_sg_id = module.network.security_group_ids["echo_server_sg"]
  next_server_sg_id = module.network.security_group_ids["next_server_sg"]
}
