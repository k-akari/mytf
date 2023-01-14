provider "aws" {
  region  = "ap-northeast-1"
}

locals {
  project = "workbench"
  env     = "prod"

  prefix = "${local.project}-${local.env}"
  tags = {
    Terraform = "true"
    env       = local.env
    project   = local.project
  }
}

module "network" {
  source = "../modules/network"

  prefix = local.prefix
  tags   = local.tags

  vpc_cidr_block          = "10.0.0.0/16"
  availability_zone_names = ["ap-northeast-1a", "ap-northeast-1c"]
}
