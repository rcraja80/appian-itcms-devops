# ITCMS - Main Terraform Configuration
# Author: Raja (Cloud & DevOps Engineer)
# Project: IT Change Management System - Appian on AWS

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket         = "itcms-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "itcms-terraform-lock"
    encrypt        = true
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
    }
  }
}

module "vpc"  { source = "./modules/vpc"  }
module "ec2"  { source = "./modules/ec2"  }
module "rds"  { source = "./modules/rds"  }
module "s3"   { source = "./modules/s3"   }
module "iam"  { source = "./modules/iam"  }
