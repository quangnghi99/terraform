provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr          = ["10.0.0.0/16","10.1.0.0/16","10.2.0.0/16"]
  availability_zone = ["us-east-1a","us-east-1b"]
  vpc_1_subnet_cidr = ["10.0.0.0/24", "10.0.1.0/24"]
  vpc_2_subnet_cidr = ["10.1.0.0/24", "10.1.1.0/24"]
  vpc_3_subnet_cidr = ["10.2.0.0/24", "10.2.1.0/24"]
}