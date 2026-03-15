variable "aws_region"       { default = "ap-south-1" }
variable "environment"      { default = "dev" }
variable "project_name"     { default = "itcms" }
variable "aws_account_id"   {}
variable "ec2_instance_type"{ default = "t3.large" }
variable "db_instance_class"{ default = "db.t3.medium" }
variable "db_password"      { sensitive = true }
