# "Amati Marketing" Web Server

### Client Background

Amati Marketing, a rapidly growing digital marketing agency, is looking to overhaul its existing website to support its expanding portfolio and customer base. They require a highly resilient and scalable website that can handle significant traffic fluctuations and provide robust data management capabilities.

### Project Overview

We have been contracted to develop a new website for Amati Marketing. The architecture designed showcases a robust adherence to four key pillars of the AWS Well-Architected Framework: Operational Excellence, Reliability, Performance Efficiency, and Cost Optimization. **Operational Excellence** is exemplified through the implementation of Auto Scaling Groups (ASG) for EC2 instances and an Application Load Balancer (ALB) which automates traffic routing and supports a monitoring-driven environment to maintain consistent performance and quick recovery from any operational failures. **Reliability** is ensured by deploying across multiple subnets, which enhances fault tolerance and ensures high availability; this setup helps mitigate the risks associated with single points of failure, as other subnets can continue operating if one fails. **Performance Efficiency** is achieved by using an ALB to distribute incoming traffic across multiple EC2 instances, which efficiently handles the load and allows for scalability based on demand. Finally, **Cost Optimization** is addressed by the Auto Scaling mechanism that adjusts the number of instances in response to real-time demand, ensuring cost efficiency by paying only for the resources that are needed. This thoughtful configuration highlights a well-planned infrastructure that optimizes both resource use and operational costs. This architecture also complies with decoupling and independent scalability:

1. **Decoupling**:
   
   The architecture demonstrates decoupling by separating the presentation layer (EC2 instances in public subnets), the application layer (EFS in app subnets), and the data layer (RDS in a private subnet). This separation ensures that components can fail or scale independently without impacting others.

2. **Independent Scalability**:
   
   Each component (EC2, EFS, RDS) can scale independently. EC2 instances scale horizontally through the ASG, EFS scales automatically with the storage needs, and RDS can scale vertically or horizontally (read replicas) depending on the database workload.

### Technical Specifications

- **Web Hosting Service**: Amazon Web Services (AWS)
  
  - **Infrastructure as Code**: AWS CloudFormation
    Use AWS CloudFormation to define and provision the AWS infrastructure resources in an automated and secure manner. CloudFormation templates will specify VPC settings,  and System Manager parameters, ensuring that all resources are consistently deployed and managed.
  
  - **Compute**: Amazon EC2 (Elastic Compute Cloud)
    Multiple EC2 instances will be used to run the website's applications and services, ensuring robust computing capability. EC2 Auto Scaling will be employed to dynamically adjust the number of instances according to the application load, promoting cost efficiency and uninterrupted service.
  
  - **Database**: Amazon RDS (Relational Database Service)
    Utilizes RDS for database management to handle all backend data storage and retrieval with high availability and automatic failover mechanisms.
  
  - **Storage**: Amazon EFS (Elastic File System)
    EFS will be implemented to provide a scalable file storage system for the web application, allowing files to be shared across multiple instances.
  
  - **Load Balancing**: AWS Elastic Load Balancing (ELB)
    Implement ELB to distribute incoming application traffic across multiple EC2 instances, enhancing fault tolerance and performance.
  
  - **DNS Management**: AWS Route 53
    Route 53 will be used for DNS management, directing users to the most appropriate instance and ensuring efficient traffic management.
  
  - **Configuration Management**: AWS Systems Manager Parameter Store
    Systems Manager Parameter Store will be used to manage, retrieve, and store configuration data securely. This includes secrets management, which simplifies the handling of database credentials, enhancing security and operational governance.
  
  - **Decoupling & Independent Scalability**:
    Services and resources will be decoupled using AWS service integrations, ensuring components such as computing, database services, and content delivery can be scaled independently based on demand.
  
  - **Network Configuration**: Amazon VPC
    The entire infrastructure is hosted within a custom-configured Amazon VPC, ensuring enhanced security and isolation. Subnetting within the VPC is strategically designed to separate resources into public and private subnets as needed for security and efficiency. This includes public subnets for ALB and private subnets for RDS, and EFS.

This specification provides a comprehensive view of how various AWS services are orchestrated to create a scalable, secure, and efficient cloud infrastructure for your web application.

### Expected Outcomes

- Enhanced user experience due to reduced load times and improved website responsiveness.
- Increased uptime and availability, ensuring that the website is always accessible to users.
- Scalability to handle peak loads during high traffic periods without compromising on performance.

By leveraging AWS's robust cloud infrastructure and services, we will deliver a resilient, scalable, and high-performance website that aligns with the dynamic needs of Amati Marketing.

## Implementation

##### Architecture
The architecture below is a well-structured, cost-effective AWS cloud deployment specifically tailored for a WordPress application in the US-East-1 region. It encompasses a Virtual Private Cloud (VPC) with an Internet Gateway, ensuring connectivity to and from the internet. Within this VPC, there are three public subnets, which host the EC2 instances running the WordPress application. These instances are managed by an Auto Scaling Group (ASG) to ensure scalability and reliability, adjusting the number of instances based on load to maintain performance while optimizing costs. An Application Load Balancer (ALB) distributes incoming traffic across these instances to enhance availability and fault tolerance.

Additionally, the architecture includes three private application subnets where the Amazon Elastic File System (EFS) mount targets are located. This setup allows for shared file storage across the EC2 instances, facilitating a consistent and stateful deployment of WordPress resources like media files and themes across multiple servers. For database needs, a single Amazon RDS MySQL instance resides in one of the private subnets (DB A), which is isolated from direct internet access, enhancing security. This arrangement supports a robust, secure, and cost-efficient infrastructure for a WordPress-based portfolio project, ensuring that it can handle varying loads with minimal manual intervention.

![Web Server.png](https://github.com/GuillenDiego/Cloud_Projects/blob/main/Web%20Server/Web%20Server.png?raw=true)

##### VPC

##### RDS MySQL Database

##### EFS File System

##### Systems Manager Parameter Store

##### EC2 Amazon Load Balancer

##### EC2 AutoScaling
Upload


### User Data

```shell
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
```
