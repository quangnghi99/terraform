provider "aws" {
  region = "us-east-1"
}

locals {
  tags = "nghi"
  name = "nghi"
  bucket_name = "nghi-s3"
  key_name = "nghi_key"
  mime_types = {
    html = "text/html"
    css   = "text/css"
    ttf   = "font/ttf"
    woff  = "font/woff"
    woff2 = "font/woff2"
    js    = "application/javascript"
    map   = "application/javascript"
    json  = "application/json"
    jpg   = "image/jpeg"
    png   = "image/png"
    svg   = "image/svg+xml"
    eot   = "application/vnd.ms-fontobject"
  }
}
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr         = "12.0.0.0/16"
  private_subnets  = ["12.0.1.0/24", "12.0.2.0/24", "12.0.3.0/24"]
  public_subnets   = ["12.0.4.0/24", "12.0.5.0/24", "12.0.6.0/24"]
  database_subnets = ["12.0.7.0/24", "12.0.8.0/24", "12.0.9.0/24"]
  availability_zone = ["us-east-1a", "us-east-1b", "us-east-1c"]
  instance_type = "t2.micro"
  
}

module "database" {
  source = "./modules/database"

  vpc = module.vpc.vpc
  sg  = module.vpc.sg_id
  database_subnets = module.vpc.database_subnets
}

module "autoscaling" {
  source = "./modules/autoscaling"

  vpc = module.vpc.vpc
  ami_id = module.vpc.ami_id
  sg = module.vpc.sg_id
  private_subnets = module.vpc.private_subnets
  public_subnets = module.vpc.public_subnets
  db_config = module.database.config
}

module "s3" {
  source = "./modules/s3"

  ami_id = module.vpc.ami_id
  sg = module.vpc.sg_id
  private_subnets = module.vpc.private_subnets
}
