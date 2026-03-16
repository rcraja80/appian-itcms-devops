# ============================================================
# ITCMS - Root Variables
# Author : Raja (Rajasegaran C) - Cloud & DevOps Engineer
# ============================================================

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name (lowercase)"
  type        = string
  default     = "itcms"
}

variable "project" {
  description = "Project name for tagging"
  type        = string
  default     = "ITCMS"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "ec2_instance_type" {
  description = "EC2 instance type for Appian server"
  type        = string
  default     = "t3.large"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}

variable "db_password" {
  description = "RDS MySQL master password"
  type        = string
  sensitive   = true
}

variable "rds_instance_id" {
  description = "RDS Instance Identifier"
  type        = string
  default     = "itcms-dev-mysql"
}
