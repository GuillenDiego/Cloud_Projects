#!/bin/bash -xe

# Redirect stdout and stderr to a log file
exec > >(tee -i /var/log/wordpress_install.log) 2>&1

# Update and install necessary packages
sudo yum -y update
sudo yum -y upgrade

# Install Amazon EFS utils for mounting EFS
sudo yum install -y amazon-efs-utils

# Install PHP and required PHP extensions
sudo yum install -y php php-mysqlnd php-fpm php-json php-cli php-pdo

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Retrieve the EFS File System ID from SSM Parameter Store
EFSFSID=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/EFSFSID --query 'Parameters[0].Value' --output text)

# Check if the EFS File System ID was retrieved successfully
if [ -z "$EFSFSID" ]; then
    echo "Failed to retrieve EFS File System ID from SSM Parameter Store"
    exit 1
fi

# Create the directory if it doesn't exist
sudo mkdir -p /var/www/html

# Mount the EFS file system using EFS mount helper
sudo mount -t efs $EFSFSID:/ /var/www/html

# Update /etc/fstab to mount the EFS file system at boot
echo "$EFSFSID:/ /var/www/html efs defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Verify the mount
mount | grep /var/www/html || { echo "EFS mount failed"; exit 1; }

echo "EFS file system mounted on /var/www/html"

# Check if WordPress is already installed
if [ -f /var/www/html/wp-config.php ]; then
    echo "WordPress is already installed. Skipping installation."

    # Correct permissions for Apache and WordPress
    sudo usermod -a -G apache ec2-user
    sudo chown -R ec2-user:apache /var/www/html
    sudo chmod 2775 /var/www/html
    sudo find /var/www/html -type d -exec chmod 2775 {} \;
    sudo find /var/www/html -type f -exec chmod 0664 {} \;

    echo "Permissions for Apache and WordPress have been set."
    exit 0
fi

# Retrieve DB credentials from AWS SSM Parameter Store
DBUser=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBUser --query 'Parameters[0].Value' --output text)
DBPassword=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBPassword --with-decryption --query 'Parameters[0].Value' --output text)
DBName=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBName --query 'Parameters[0].Value' --output text)
DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBEndpoint --query 'Parameters[0].Value' --output text)

# Check if the database credentials were retrieved successfully
if [ -z "$DBUser" ] || [ -z "$DBPassword" ] || [ -z "$DBName" ] || [ -z "$DBEndpoint" ]; then
    echo "Failed to retrieve database credentials from SSM Parameter Store"
    exit 1
fi

# Download and install WordPress
wget http://wordpress.org/latest.tar.gz -P /tmp
tar -zxvf /tmp/latest.tar.gz -C /tmp
sudo cp -rv /tmp/wordpress/* /var/www/html
rm -rf /tmp/wordpress
rm /tmp/latest.tar.gz

# Configure WordPress
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo sed -i "s/database_name_here/$DBName/" /var/www/html/wp-config.php
sudo sed -i "s/username_here/$DBUser/" /var/www/html/wp-config.php
sudo sed -i "s/password_here/$DBPassword/" /var/www/html/wp-config.php
sudo sed -i "s/localhost/$DBEndpoint/" /var/www/html/wp-config.php

# Correct permissions for Apache and WordPress
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www/html
sudo chmod 2775 /var/www/html
sudo find /var/www/html -type d -exec chmod 2775 {} \;
sudo find /var/www/html -type f -exec chmod 0664 {} \;

echo "WordPress installation completed successfully."
