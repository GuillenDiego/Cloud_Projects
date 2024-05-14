# "Amati Marketing" Web Server


### Client Background

Amati Marketing, a rapidly growing digital marketing agency, is looking to overhaul their existing website to support their expanding portfolio and customer base. They require a highly resilient and scalable website that can handle significant traffic fluctuations and provide robust data management capabilities.

### Project Overview

We have been contracted to develop a new state-of-the-art website for Amati Marketing. The website must be capable of independent scalability, ensuring that varying components can be scaled without affecting the overall system performance.

### Technical Specifications

- Web Hosting Service: Amazon Web Services (AWS)
- Compute: Amazon EC2 (Elastic Compute Cloud)
    - Multiple EC2 instances will be used to run the website's applications and services, ensuring robust compute capability.
- Database: Amazon RDS (Relational Database Service)
    - Utilize RDS for database management to handle all backend data storage and retrieval with high availability and automatic failover mechanisms.
- Storage: Amazon EFS (Elastic File System)
    - EFS will be implemented to provide a scalable file storage system for the web application, allowing files to be shared across multiple instances.
- Load Balancing: AWS Elastic Load Balancing (ELB)
    - Implement ELB to distribute incoming application traffic across multiple EC2 instances, enhancing fault tolerance and performance.
- DNS Management: AWS Route 53
    - Route 53 will be used for DNS management, directing users to the most appropriate instance and ensuring efficient traffic management.
- Decoupling & Independent Scalability:
    - Services and resources will be decoupled using AWS service integrations, ensuring components such as computing and database services can be scaled independently based on demand.

### Expected Outcomes

- Enhanced user experience due to reduced load times and improved website responsiveness.
- Increased uptime and availability, ensuring that the website is always accessible to users.
- Scalability to handle peak loads during high traffic periods without compromising on performance.

By leveraging AWS's robust cloud infrastructure and services, we will deliver a resilient, scalable, and high-performance website that aligns with the dynamic needs of Amati Marketing.


### User Data
```
#!/bin/bash -xe

# Retrieve DB parameters from AWS SSM Parameter Store
DBPassword=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBPassword --with-decryption --query Parameters[0].Value --output text)
DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBRootPassword --with-decryption --query Parameters[0].Value --output text)
DBUser=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBUser --query Parameters[0].Value --output text)
DBName=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBName --query Parameters[0].Value --output text)
DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBEndpoint --query Parameters[0].Value --output text)

# Update and install necessary packages
sudo yum -y update
sudo yum -y upgrade

# Enable and install the latest PHP
sudo amazon-linux-extras enable php8.1
sudo yum clean metadata
sudo yum install -y php php-cli php-pdo php-fpm php-json php-mysqlnd

# Install and enable the latest MariaDB
sudo amazon-linux-extras enable mariadb10.5
sudo yum clean metadata
sudo yum install -y mariadb-server

# Start and enable services
sudo systemctl start mariadb
sudo systemctl enable mariadb
sudo systemctl start httpd
sudo systemctl enable httpd

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

```

