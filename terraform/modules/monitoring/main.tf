# ============================================================
# ITCMS - CloudWatch Monitoring Module
# Author  : Raja (Rajasegaran C) - Cloud & DevOps Engineer
# Purpose : Dashboards, Alarms, SNS Alerts, Log Groups
# ============================================================

# ============================================================
# SNS Topic — Alert Delivery
# ============================================================
resource "aws_sns_topic" "itcms_alerts" {
  name = "${var.project}-${var.environment}-alerts"

  tags = {
    Name        = "${var.project}-${var.environment}-alerts"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = "Raja"
    Project     = var.project
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.itcms_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ============================================================
# CloudWatch Log Groups
# ============================================================
resource "aws_cloudwatch_log_group" "appian_app_logs" {
  name              = "/itcms/${var.environment}/appian/application"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "itcms-${var.environment}-appian-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "appian_deploy_logs" {
  name              = "/itcms/${var.environment}/appian/deployments"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "itcms-${var.environment}-deploy-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "pipeline_logs" {
  name              = "/itcms/${var.environment}/azure-devops/pipeline"
  retention_in_days = var.log_retention_days

  tags = {
    Name        = "itcms-${var.environment}-pipeline-logs"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# EC2 CloudWatch Alarms
# ============================================================
resource "aws_cloudwatch_metric_alarm" "ec2_cpu_high" {
  alarm_name          = "${var.project}-${var.environment}-ec2-cpu-high"
  alarm_description   = "Appian EC2 CPU utilization exceeds ${var.ec2_cpu_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300   # 5 minutes
  statistic           = "Average"
  threshold           = var.ec2_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.itcms_alerts.arn]
  ok_actions    = [aws_sns_topic.itcms_alerts.arn]

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-cpu-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_status_check" {
  alarm_name          = "${var.project}-${var.environment}-ec2-status-check"
  alarm_description   = "Appian EC2 instance status check failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Maximum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = var.ec2_instance_id
  }

  alarm_actions = [aws_sns_topic.itcms_alerts.arn]

  tags = {
    Name        = "${var.project}-${var.environment}-ec2-status-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# RDS CloudWatch Alarms
# ============================================================
resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${var.project}-${var.environment}-rds-cpu-high"
  alarm_description   = "RDS CPU utilization exceeds ${var.rds_cpu_threshold}%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_cpu_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.itcms_alerts.arn]
  ok_actions    = [aws_sns_topic.itcms_alerts.arn]

  tags = {
    Name        = "${var.project}-${var.environment}-rds-cpu-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${var.project}-${var.environment}-rds-storage-low"
  alarm_description   = "RDS free storage space is below 10GB — disk space critical!"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = var.rds_storage_threshold
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.itcms_alerts.arn]

  tags = {
    Name        = "${var.project}-${var.environment}-rds-storage-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_metric_alarm" "rds_connections_high" {
  alarm_name          = "${var.project}-${var.environment}-rds-connections-high"
  alarm_description   = "RDS database connections exceeding threshold"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = var.rds_instance_id
  }

  alarm_actions = [aws_sns_topic.itcms_alerts.arn]

  tags = {
    Name        = "${var.project}-${var.environment}-rds-conn-alarm"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ============================================================
# CloudWatch Dashboard — Single Pane of Glass
# ============================================================
resource "aws_cloudwatch_dashboard" "itcms_dashboard" {
  dashboard_name = "${var.project}-${var.environment}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      # ---- EC2 CPU ----
      {
        type       = "metric"
        x          = 0
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "Appian EC2 - CPU Utilization"
          view    = "timeSeries"
          stacked = false
          metrics = [
            ["AWS/EC2", "CPUUtilization",
             "InstanceId", var.ec2_instance_id,
             { color = "#2196F3", label = "CPU %" }]
          ]
          period = 300
          region = var.aws_region
          annotations = {
            horizontal = [
              { value = var.ec2_cpu_threshold, label = "Alarm threshold",
                color = "#FF5252" }
            ]
          }
        }
      },
      # ---- EC2 Network ----
      {
        type       = "metric"
        x          = 12
        y          = 0
        width      = 12
        height     = 6
        properties = {
          title   = "Appian EC2 - Network I/O"
          view    = "timeSeries"
          metrics = [
            ["AWS/EC2", "NetworkIn",
             "InstanceId", var.ec2_instance_id,
             { color = "#4CAF50", label = "Network In" }],
            ["AWS/EC2", "NetworkOut",
             "InstanceId", var.ec2_instance_id,
             { color = "#FF9800", label = "Network Out" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      # ---- RDS CPU ----
      {
        type       = "metric"
        x          = 0
        y          = 6
        width      = 12
        height     = 6
        properties = {
          title   = "RDS MySQL - CPU Utilization"
          view    = "timeSeries"
          metrics = [
            ["AWS/RDS", "CPUUtilization",
             "DBInstanceIdentifier", var.rds_instance_id,
             { color = "#9C27B0", label = "RDS CPU %" }]
          ]
          period = 300
          region = var.aws_region
          annotations = {
            horizontal = [
              { value = var.rds_cpu_threshold, label = "Alarm threshold",
                color = "#FF5252" }
            ]
          }
        }
      },
      # ---- RDS Storage ----
      {
        type       = "metric"
        x          = 12
        y          = 6
        width      = 12
        height     = 6
        properties = {
          title   = "RDS MySQL - Free Storage Space"
          view    = "timeSeries"
          metrics = [
            ["AWS/RDS", "FreeStorageSpace",
             "DBInstanceIdentifier", var.rds_instance_id,
             { color = "#F44336", label = "Free Storage (bytes)" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      # ---- RDS Connections ----
      {
        type       = "metric"
        x          = 0
        y          = 12
        width      = 12
        height     = 6
        properties = {
          title   = "RDS MySQL - Database Connections"
          view    = "timeSeries"
          metrics = [
            ["AWS/RDS", "DatabaseConnections",
             "DBInstanceIdentifier", var.rds_instance_id,
             { color = "#00BCD4", label = "Connections" }]
          ]
          period = 300
          region = var.aws_region
        }
      },
      # ---- Alarm Status Widget ----
      {
        type   = "alarm"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "🚨 ITCMS Alarm Status Overview"
          alarms = [
            "arn:aws:cloudwatch:${var.aws_region}:*:alarm:${var.project}-${var.environment}-ec2-cpu-high",
            "arn:aws:cloudwatch:${var.aws_region}:*:alarm:${var.project}-${var.environment}-ec2-status-check",
            "arn:aws:cloudwatch:${var.aws_region}:*:alarm:${var.project}-${var.environment}-rds-cpu-high",
            "arn:aws:cloudwatch:${var.aws_region}:*:alarm:${var.project}-${var.environment}-rds-storage-low",
            "arn:aws:cloudwatch:${var.aws_region}:*:alarm:${var.project}-${var.environment}-rds-connections-high"
          ]
        }
      }
    ]
  })
}
