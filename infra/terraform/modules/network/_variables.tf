variable "vpc_cidr_block" {
  type = string
}

variable "any_ipv4" {
  type    = string
  default = "0.0.0.0/0"
}
  