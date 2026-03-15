# ============================================================
# ITCMS - RDS Module
# MySQL 8.0 - Appian Database
# Multi-AZ for production, Single-AZ for dev/test
# ============================================================

resource "aws_db_subnet_group" "itcms_db_subnet_group" {
  name       = "${var.project_name}-${var.environment}-db-subnet-grp"
  subnet_ids = [var.private_subnet_1_id, var.private_subnet_2_id]
  tags       = { Name = "${var.project_name}-${var.environment}-db-subnet-grp" }
}

resource "aws_db_parameter_group" "itcms_mysql_params" {
  family = "mysql8.0"
  name   = "${var.project_name}-${var.environment}-mysql-params"

  # Appian recommended MySQL settings
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
  }
  parameter {
    name  = "max_connections"
    value = "500"
  }
  parameter {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }

  tags = { Name = "${var.project_name}-${var.environment}-mysql-params" }
}

resource "aws_db_instance" "itcms_rds" {
  identifier        = "${var.project_name}-${var.environment}-mysql"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = "itcms_db"
  username = var.db_username
  password = var.db_password   # Passed from Secrets Manager in Phase 7

  db_subnet_group_name   = aws_db_subnet_group.itcms_db_subnet_group.name
  vpc_security_group_ids = [var.rds_sg_id]
  parameter_group_name   = aws_db_parameter_group.itcms_mysql_params.name

  multi_az               = var.environment == "prod" ? true : false
  publicly_accessible    = false
  skip_final_snapshot    = var.environment == "prod" ? false : true
  deletion_protection    = var.environment == "prod" ? true : false

  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "02:00-03:00"   # 2 AM - 3 AM IST offset
  maintenance_window      = "sun:04:00-sun:05:00"

  performance_insights_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-mysql"
    Environment = var.environment
  }
}
