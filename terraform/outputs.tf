output "appian_server_public_ip" { value = module.ec2.public_ip }
output "appian_server_private_ip"{ value = module.ec2.private_ip }
output "rds_endpoint"            { value = module.rds.endpoint }
output "s3_packages_bucket"      { value = module.s3.bucket_name }
output "access_appian_url"       { value = "http://${module.ec2.public_ip}:8080/suite" }
