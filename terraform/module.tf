provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//vpc"
  name   = "Practice VPC"
  cidr   = "10.10.0.0/16"
}

module "public_subnet_a" {
  source            = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//public_subnet"
  name              = "Public A"
  cidr              = "10.10.0.0/24"
  availability_zone = "us-west-2a"
  vpc_id            = module.vpc.id
  gateway_id        = module.vpc.gateway_id
}

module "sg" {
  source = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//sg"
  name   = "ecs_sg"
  vpc_id = module.vpc.id
  ingress_rules = {
    "http" = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress_rules = {
    "all" = {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

module "ecs" {
  source           = "github.com/Dudochnik/SoftServeDevOpsPetProjectModules//ecs"
  repository_name  = "terraform"
  vpc_id           = module.vpc.id
  cluster_name     = "terraform_cluster"
  container_name   = "terraform_container"
  launch_type      = "FARGATE"
  security_groups  = [module.sg.id]
  task_cpu         = "512"
  task_memory      = "1024"
  task_family_name = "terraform_task_family"
  service_name     = "terraform_service"
  subnets          = [module.public_subnet_a.id]
}
