variable "vpc" {
  type = any
}

variable "sg" {
  type = any
}

variable "db_config" {
  type = object(
    {
      user     = string
      password = string
      database = string
      hostname = string
      port     = string
    }
  )
}

variable "private_subnets" {
  type = any
}

variable "public_subnets" {
  type = any
}

variable "ami_id" {
  type = any
}