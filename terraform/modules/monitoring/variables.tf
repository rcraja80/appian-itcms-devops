# ============================================================
# ITCMS - CloudWatch Monitoring Module - Variables
# Author : Raja (Rajasegaran C) - Cloud & DevOps Engineer
# ============================================================

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "ITCMS"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

variable "ec2_instance_id" {
  description = "Appian EC2 Instance ID"
  type        = string
}

variable "rds_instance_id" {
  description = "RDS Instance identifier"
  type        = string
}

variable "alert_email" {
  description = "Email for CloudWatch alarm notifications"
  type        = string
  default     = "dgp.pon.gov.in@gmail.com"
}

variable "ec2_cpu_threshold" {
  description = "EC2 CPU utilization alarm threshold (%)"
  type        = number
  default     = 80
}

variable "rds_cpu_threshold" {
  description = "RDS CPU utilization alarm threshold (%)"
  type        = number
  default     = 75
}

variable "rds_storage_threshold" {
  description = "RDS free storage space alarm threshold (bytes)"
  type        = number
  default     = 10737418240   # 10 GB in bytes
}

variable "log_retention_days" {
  description = "CloudWatch log group retention in days"
  type        = number
  default     = 30
}
