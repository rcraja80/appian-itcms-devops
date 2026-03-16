# ============================================================
# ITCMS - Root Terraform Configuration
# Author: Raja - Cloud & DevOps Engineer
# AWS Account: 476889837691 | Region: ap-south-1 (Mumbai)
# ============================================================

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "itcms-terraform-state-476889837691"
    key          = "dev/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Project     = "ITCMS"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Owner       = "Raja"
      Repository  = "github.com/rcraja80/appian-itcms-devops"
    }
  }
}

module "vpc" {
  source       = "./modules/vpc"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
}

module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  environment  = var.environment
}

module "s3" {
  source         = "./modules/s3"
  project_name   = var.project_name
  environment    = var.environment
  aws_account_id = var.aws_account_id
}

module "ec2" {
  source               = "./modules/ec2"
  project_name         = var.project_name
  environment          = var.environment
  instance_type        = var.ec2_instance_type
  public_subnet_id     = module.vpc.public_subnet_1_id
  appian_sg_id         = module.vpc.appian_sg_id
  ec2_instance_profile = module.iam.ec2_instance_profile
}

module "rds" {
  source              = "./modules/rds"
  project_name        = var.project_name
  environment         = var.environment
  private_subnet_1_id = module.vpc.private_subnet_1_id
  private_subnet_2_id = module.vpc.private_subnet_2_id
  rds_sg_id           = module.vpc.rds_sg_id
  db_instance_class   = var.db_instance_class
  db_password         = var.db_password
}

# ============================================================
# MONITORING MODULE — CloudWatch + SNS Alerts
# ============================================================
module "monitoring" {
  source = "./modules/monitoring"

  environment    = var.environment
  project        = var.project_name
  aws_region     = var.aws_region
  ec2_instance_id = module.ec2.instance_id
  rds_instance_id = var.rds_instance_id
  alert_email    = "dgp.pon.gov.in@gmail.com"
}
