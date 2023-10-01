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

variable "openid_connect_provider_github_actions_arn" {
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
  openid_connect_provider_github_actions_arn = var.openid_connect_provider_github_actions_arn
}

module "ec2" {
  source = "../modules/ec2"

  availability_zones = module.network.availability_zones

  server_spec = {
    gin_server = {
      desired_capacity = 1
      max_size         = 3
      min_size         = 1
    },
    next_server = {
      desired_capacity = 1
      max_size         = 3
      min_size         = 1
    },
  }

  gin_server_instance_profile_arn = module.iam.gin_server_instance_profile_arn
  next_server_instance_profile_arn = module.iam.next_server_instance_profile_arn

  gin_server_subnet_ids = [module.network.subnet_ids["private_subnet_1a"]]
  next_server_subnet_ids = [module.network.subnet_ids["private_subnet_1a"]]

  gin_server_sg_id = module.network.security_group_ids["gin_server_sg"]
  next_server_sg_id = module.network.security_group_ids["next_server_sg"]

  code_deploy_service_role_arn = module.iam.code_deploy_role_arn

  alb_next_target_group_arn = module.network.alb_next_target_group_arn
  nlb_gin_target_group_arn = module.network.nlb_gin_target_group_arn

  target_group_names = {
    gin_server = module.network.gin_server_target_group_name
    next_server = module.network.next_server_target_group_name
  }
}

module "s3" {
  source = "../modules/s3"
}

module "cloudwatch" {
  source = "../modules/cloudwatch"
}
