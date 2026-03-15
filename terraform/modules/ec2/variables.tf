variable "project_name"         { default = "itcms" }
variable "environment"          { default = "dev" }
variable "instance_type"        { default = "t3.large" }
variable "public_subnet_id"     {}
variable "appian_sg_id"         {}
variable "ec2_instance_profile" {}
variable "public_key_path"      { default = "~/.ssh/itcms-key.pub" }
