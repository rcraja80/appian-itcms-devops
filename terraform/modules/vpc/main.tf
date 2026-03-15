# ============================================================
# ITCMS - VPC Module
# Creates full network layer for Appian on AWS
# Region: ap-south-1 (Mumbai)
# ============================================================

resource "aws_vpc" "itcms_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = { Name = "${var.project_name}-${var.environment}-vpc" }
}

# ── Internet Gateway ──
resource "aws_internet_gateway" "itcms_igw" {
  vpc_id = aws_vpc.itcms_vpc.id
  tags   = { Name = "${var.project_name}-${var.environment}-igw" }
}

# ── Public Subnets (2 AZs for HA) ──
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.itcms_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-${var.environment}-public-1" }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.itcms_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-${var.environment}-public-2" }
}

# ── Private Subnets (for RDS) ──
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.itcms_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = "${var.aws_region}a"
  tags = { Name = "${var.project_name}-${var.environment}-private-1" }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.itcms_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = "${var.aws_region}b"
  tags = { Name = "${var.project_name}-${var.environment}-private-2" }
}

# ── Route Table for Public Subnets ──
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.itcms_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.itcms_igw.id
  }
  tags = { Name = "${var.project_name}-${var.environment}-public-rt" }
}

resource "aws_route_table_association" "public_rta_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rta_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# ── Security Group: Appian EC2 ──
resource "aws_security_group" "appian_sg" {
  name        = "${var.project_name}-${var.environment}-appian-sg"
  description = "Security group for Appian application server"
  vpc_id      = aws_vpc.itcms_vpc.id

  # HTTPS - Appian web access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Appian access"
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP redirect"
  }

  # Appian default port
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Appian application port"
  }

  # SSH - restrict to your IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
    description = "SSH access - restricted"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = { Name = "${var.project_name}-${var.environment}-appian-sg" }
}

# ── Security Group: RDS ──
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS - allow only from Appian EC2"
  vpc_id      = aws_vpc.itcms_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.appian_sg.id]
    description     = "MySQL from Appian server only"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-${var.environment}-rds-sg" }
}
