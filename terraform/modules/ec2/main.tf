# ============================================================
# ITCMS - EC2 Module
# Appian Application Server
# Instance: t3.large | OS: RHEL 8 | Region: ap-south-1
# ============================================================

data "aws_ami" "rhel8" {
  most_recent = true
  owners      = ["309956199498"]

  filter {
    name   = "name"
    values = ["RHEL-8*_HVM-*-x86_64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Key Pair - using pathexpand() to handle ~ correctly
resource "aws_key_pair" "itcms_key" {
  key_name   = "${var.project_name}-${var.environment}-key"
  public_key = file(pathexpand(var.public_key_path))
  tags       = { Name = "${var.project_name}-${var.environment}-keypair" }
}

resource "aws_instance" "appian_server" {
  ami                    = data.aws_ami.rhel8.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.itcms_key.key_name
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.appian_sg_id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 100
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdb"
    volume_type           = "gp3"
    volume_size           = 50
    encrypted             = true
    delete_on_termination = false
    tags                  = { Name = "${var.project_name}-data-volume" }
  }

  iam_instance_profile = var.ec2_instance_profile

  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    environment  = var.environment
    project_name = var.project_name
  }))

  tags = {
    Name        = "${var.project_name}-${var.environment}-appian-server"
    Role        = "appian-application-server"
    Environment = var.environment
  }
}

resource "aws_eip" "appian_eip" {
  instance = aws_instance.appian_server.id
  domain   = "vpc"
  tags     = { Name = "${var.project_name}-${var.environment}-eip" }
}
