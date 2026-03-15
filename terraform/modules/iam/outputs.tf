output "ec2_instance_profile"      { value = aws_iam_instance_profile.ec2_profile.name }
output "pipeline_user_access_key"  { value = aws_iam_access_key.pipeline_user_key.id }
output "pipeline_user_secret_key"  {
  value     = aws_iam_access_key.pipeline_user_key.secret
  sensitive = true
}
