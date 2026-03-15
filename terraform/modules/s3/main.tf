# ============================================================
# ITCMS - S3 Module
# Stores Appian deployment packages + Terraform state
# ============================================================

# Appian Deployment Packages Bucket
resource "aws_s3_bucket" "appian_packages" {
  bucket = "${var.project_name}-${var.environment}-appian-packages-${var.aws_account_id}"
  tags   = { Name = "${var.project_name}-${var.environment}-appian-packages" }
}

resource "aws_s3_bucket_versioning" "appian_packages_versioning" {
  bucket = aws_s3_bucket.appian_packages.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "appian_packages_sse" {
  bucket = aws_s3_bucket.appian_packages.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "appian_packages_block" {
  bucket                  = aws_s3_bucket.appian_packages.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy - auto-archive old packages
resource "aws_s3_bucket_lifecycle_configuration" "appian_packages_lifecycle" {
  bucket = aws_s3_bucket.appian_packages.id
  rule {
    id     = "archive-old-packages"
    status = "Enabled"
    filter { prefix = "packages/" }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 90
      storage_class = "GLACIER"
    }
    expiration { days = 365 }
  }
}

# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-terraform-state-${var.aws_account_id}"
  tags   = { Name = "${var.project_name}-terraform-state" }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_sse" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB for Terraform state locking
resource "aws_dynamodb_table" "terraform_lock" {
  name         = "${var.project_name}-terraform-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = { Name = "${var.project_name}-terraform-lock" }
}
