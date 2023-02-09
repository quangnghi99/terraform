variable "vpc_cidr" {
  type    = string
}

variable "private_subnets" {
  type    = list(string)
}

variable "public_subnets" {
  type    = list(string)
}

variable "database_subnets" {
  type    = list(string)
}

variable "availability_zone" {
  type    = list(string)
}

variable "instance_type" {
  type    = string
}