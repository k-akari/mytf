variable "prefix" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "ecs_cluster_arn" {
  type    = string
  default = null
}

variable "task_definition_arn" {
  type    = string
  default = null
}

variable "event_rules" {
  type = list(object({
    name = string
    cron = string
  }))
  default = null
}

variable "ecs_task_execution_role_arn" {
  type    = string
  default = null
}

variable "ecs_task_role_arn" {
  type    = string
  default = null
}
