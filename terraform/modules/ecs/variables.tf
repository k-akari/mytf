variable "prefix" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnet_ids" {
  type    = list(string)
  default = null
}

variable "task_definitions" {
  type = list(object({
    family  = string
    cpu     = number
    memory  = number
    command = list(string)
  }))
  default = null
}
