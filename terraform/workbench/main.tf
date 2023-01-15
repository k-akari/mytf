provider "aws" {
  region = "ap-northeast-1"
}

locals {
  project                 = "workbench"
  env                     = "prod"
  availability_zone_names = ["ap-northeast-1a", "ap-northeast-1c"]

  prefix = "${local.project}-${local.env}"
  tags = {
    Terraform = "true"
    env       = local.env
    project   = local.project
  }
}

module "network" {
  source = "../modules/network"

  prefix                  = local.prefix
  tags                    = local.tags
  availability_zone_names = local.availability_zone_names

  vpc_cidr_block = "10.0.0.0/16"
}

module "ecs" {
  source = "../modules/ecs"

  prefix = local.prefix
  tags   = local.tags

  subnet_ids = module.network.public_subnet_ids

  task_definitions = [
    {
      family = "periodic-job"
      cpu    = 512
      memory = 512
      command = [
        "bundle",
        "exec",
        "bin/rails",
        "runner",
        "sleep(30)"
      ]
    },
    {
      family = "workbench"
      cpu    = 512
      memory = 512
      command = [
        "bin/sh"
      ]
    }
  ]
}
