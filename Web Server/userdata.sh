#!/bin/bash -xe

# Update and install necessary packages
sudo yum -y update
sudo yum -y upgrade

# Install jq for JSON parsing
yum install -y jq

# Install PHP and required PHP extensions
sudo yum install -y php php-mysqlnd php-fpm php-json php-cli php-pdo

sudo systemctl start httpd
sudo systemctl enable httpd

# Retrieve DB passwords from AWS Secrets Manager
# DBPassword=$(aws secretsmanager get-secret-value --region us-east-1 --secret-id /AMATI/Wordpress/DBPassword --query SecretString --output text | jq -r .DBPassword)
DBUser=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBUser --query Parameters[0].Value --output text)
DBPassword=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBPassword --query Parameters[0].Value --output text)
DBName=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBName --query Parameters[0].Value --output text)
DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/DBEndpoint --query Parameters[0].Value --output text)



# Download and install WordPress
wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
tar -zxvf latest.tar.gz
cp -rvf wordpress/* .
rm -R wordpress
rm latest.tar.gz

# Configure WordPress
sudo cp ./wp-config-sample.php ./wp-config.php
sed -i "s/database_name_here/$DBName/" wp-config.php
sed -i "s/username_here/$DBUser/" wp-config.php
sed -i "s/password_here/$DBPassword/" wp-config.php
sed -i "s/localhost/$DBEndpoint/" wp-config.php

# Correct permissions for Apache and WordPress
sudo usermod -a -G apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;
