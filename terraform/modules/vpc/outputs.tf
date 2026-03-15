output "vpc_id"             { value = aws_vpc.itcms_vpc.id }
output "public_subnet_1_id" { value = aws_subnet.public_subnet_1.id }
output "public_subnet_2_id" { value = aws_subnet.public_subnet_2.id }
output "private_subnet_1_id"{ value = aws_subnet.private_subnet_1.id }
output "private_subnet_2_id"{ value = aws_subnet.private_subnet_2.id }
output "appian_sg_id"       { value = aws_security_group.appian_sg.id }
output "rds_sg_id"          { value = aws_security_group.rds_sg.id }
