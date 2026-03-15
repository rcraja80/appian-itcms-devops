output "instance_id"   { value = aws_instance.appian_server.id }
output "public_ip"     { value = aws_eip.appian_eip.public_ip }
output "private_ip"    { value = aws_instance.appian_server.private_ip }
output "ami_used"      { value = data.aws_ami.rhel8.id }
