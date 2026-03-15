# ============================================================
# ITCMS - IAM Module
# EC2 instance role + Pipeline deployment user
# ============================================================

# EC2 Instance Role (allows EC2 to access S3, Secrets Manager)
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-${var.environment}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
  tags = { Name = "${var.project_name}-${var.environment}-ec2-role" }
}

# Policy: EC2 can read from S3 packages bucket
resource "aws_iam_role_policy" "ec2_s3_policy" {
  name = "${var.project_name}-ec2-s3-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*-appian-packages-*",
          "arn:aws:s3:::${var.project_name}-*-appian-packages-*/*"
        ]
      }
    ]
  })
}

# Policy: EC2 can read secrets from Secrets Manager
resource "aws_iam_role_policy" "ec2_secrets_policy" {
  name = "${var.project_name}-ec2-secrets-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = "arn:aws:secretsmanager:ap-south-1:*:secret:itcms/*"
      }
    ]
  })
}

# Policy: CloudWatch logs from EC2
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-${var.environment}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# CI/CD Pipeline IAM User (for Azure DevOps)
resource "aws_iam_user" "pipeline_user" {
  name = "${var.project_name}-${var.environment}-pipeline-user"
  tags = { Name = "${var.project_name}-pipeline-user", Purpose = "Azure DevOps CI/CD" }
}

resource "aws_iam_access_key" "pipeline_user_key" {
  user = aws_iam_user.pipeline_user.name
}

resource "aws_iam_user_policy" "pipeline_user_policy" {
  name = "${var.project_name}-pipeline-policy"
  user = aws_iam_user.pipeline_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject", "s3:GetObject",
          "s3:ListBucket", "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-*-appian-packages-*",
          "arn:aws:s3:::${var.project_name}-*-appian-packages-*/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}
