variable "availability_zone_names" {
  type    = list(string)
  default = null
}

variable "vpc_cidr_block" {
  type    = string
  default = null
}

variable "prefix" {
  type    = string
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
