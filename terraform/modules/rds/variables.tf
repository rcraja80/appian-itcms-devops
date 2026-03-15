variable "project_name"       { default = "itcms" }
variable "environment"        { default = "dev" }
variable "private_subnet_1_id"{}
variable "private_subnet_2_id"{}
variable "rds_sg_id"          {}
variable "db_instance_class"  { default = "db.t3.medium" }
variable "db_storage_gb"      { default = 20 }
variable "db_username"        { default = "itcms_admin" }
variable "db_password"        { sensitive = true }
