#!/bin/bash
# ============================================================
# ITCMS - EC2 Bootstrap Script
# Runs on first boot - installs pre-requisites for Appian
# ============================================================

set -e
exec > /var/log/itcms-bootstrap.log 2>&1

echo "=== ITCMS Bootstrap Started: $(date) ==="
echo "=== Environment: ${environment} ==="

# System update
yum update -y

# Install Java 11 (Appian requirement)
yum install -y java-11-openjdk java-11-openjdk-devel

# Install essential tools
yum install -y wget curl unzip git vim htop net-tools

# Install Python 3
yum install -y python3 python3-pip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
unzip /tmp/awscliv2.zip -d /tmp/
/tmp/aws/install

# Create Appian user
useradd -m -s /bin/bash appian
usermod -aG wheel appian

# Create Appian directories
mkdir -p /opt/appian
mkdir -p /opt/appian/logs
mkdir -p /opt/appian/packages
chown -R appian:appian /opt/appian

# Format and mount data volume
mkfs.xfs /dev/sdb
mkdir -p /data/appian
echo "/dev/sdb /data/appian xfs defaults 0 2" >> /etc/fstab
mount -a

# Set Java home
echo "export JAVA_HOME=/usr/lib/jvm/java-11-openjdk" >> /etc/environment
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /etc/environment

# Configure firewall
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --permanent --add-port=8080/tcp
firewall-cmd --reload

echo "=== ITCMS Bootstrap Completed: $(date) ==="
