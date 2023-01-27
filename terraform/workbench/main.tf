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
      cpu    = 1024
      memory = 2048
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
      cpu    = 1024
      memory = 2048
      command = [
        "bin/sh"
      ]
    }
  ]
}

module "periodic_task" {
  source = "../modules/periodic_task"

  prefix = local.prefix
  tags   = local.tags

  vpc_id                      = module.network.vpc_id
  subnet_ids                  = module.network.public_subnet_ids
  ecs_cluster_arn             = module.ecs.ecs_cluster_arn
  task_definition_arn         = module.ecs.task_definition_arns[0]
  ecs_task_execution_role_arn = module.ecs.ecs_task_execution_role_arn
  ecs_task_role_arn           = module.ecs.ecs_task_role_arn

  event_rules = [
    {
      name = "sleep-job"
      cron = "cron(*/5 * * * ? *)"
    }
  ]
}
