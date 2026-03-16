output "sns_topic_arn" {
  description = "SNS Alert Topic ARN"
  value       = aws_sns_topic.itcms_alerts.arn
}

output "dashboard_url" {
  description = "CloudWatch Dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${aws_cloudwatch_dashboard.itcms_dashboard.dashboard_name}"
}

output "appian_log_group" {
  description = "Appian Application Log Group Name"
  value       = aws_cloudwatch_log_group.appian_app_logs.name
}

output "deploy_log_group" {
  description = "Deployment Log Group Name"
  value       = aws_cloudwatch_log_group.appian_deploy_logs.name
}
