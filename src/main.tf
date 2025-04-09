provider "aws" {
  region     = "us-east-1"
}

terraform {
  backend "s3" {
    bucket          = "demo-20250508"
    key               = "statefiles/terraform.tfstate"
    region           = "us-east-1"
    dynamodb_table = "mytab"
    encrypt        = true
  }
}

module "vpc-infra" {
  source = "./modules/vpc"
}

module "ecrrepo" {
  source = "./modules/ecr"
}

module "ecs-cluster" {
  source = "./modules/ecs"
  subnets = module.vpc-infra.public_subnet_ids
  sg_ecs_tasks = [module.vpc-infra.ecs_tasks_security_group_id]
}
