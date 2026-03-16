# ============================================================
# ITCMS - Root Outputs
# Author: Raja - Cloud & DevOps Engineer
# All names verified against module outputs.tf files
# ============================================================

# --- VPC ---
output "vpc_id" {
  description = "ITCMS VPC ID"
  value       = module.vpc.vpc_id
}

# --- EC2 ---
output "appian_server_instance_id" {
  description = "Appian EC2 Instance ID"
  value       = module.ec2.instance_id
}

output "appian_server_public_ip" {
  description = "Appian EC2 Public IP (EIP)"
  value       = module.ec2.public_ip
}

output "appian_server_private_ip" {
  description = "Appian EC2 Private IP"
  value       = module.ec2.private_ip
}

output "access_appian_url" {
  description = "Appian Application URL"
  value       = "https://${module.ec2.public_ip}"
}

output "ami_used" {
  description = "RHEL8 AMI ID used"
  value       = module.ec2.ami_used
}

# --- RDS ---
output "rds_endpoint" {
  description = "RDS MySQL Endpoint"
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_db_name" {
  description = "RDS Database Name"
  value       = module.rds.db_name
}

# --- S3 ---
output "s3_packages_bucket" {
  description = "Appian Packages S3 Bucket Name"
  value       = module.s3.bucket_name
}

output "s3_packages_bucket_arn" {
  description = "Appian Packages S3 Bucket ARN"
  value       = module.s3.bucket_arn
}

output "s3_terraform_state_bucket" {
  description = "Terraform State S3 Bucket Name"
  value       = module.s3.terraform_state_bucket
}

# --- IAM Pipeline User (Azure DevOps CI/CD) ---
output "pipeline_user_access_key" {
  description = "Pipeline IAM User Access Key ID"
  value       = module.iam.pipeline_user_access_key
}

output "pipeline_user_secret_key" {
  description = "Pipeline IAM User Secret Access Key"
  value       = module.iam.pipeline_user_secret_key
  sensitive   = true
}

# --- Monitoring ---
output "cloudwatch_dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = module.monitoring.dashboard_url
}

output "sns_alerts_topic_arn" {
  description = "SNS Alert Topic ARN"
  value       = module.monitoring.sns_topic_arn
}
