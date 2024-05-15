#!/bin/bash

# Retrieve the EFS Endpoint from SSM Parameter Store
EFSFSID=$(aws ssm get-parameters --region us-east-1 --names /AMATI/Wordpress/EFSFSID --query Parameters[0].Value --output text)

# Create the directory if it doesn't exist
sudo mkdir -p /var/www/html

# Mount the EFS file system
sudo mount -t nfs4 -o nfsvers=4.1 ${EFSFSID}:/ /var/www/html

# Update /etc/fstab to mount the EFS file system at boot
echo "${EFSFSID}:/ /var/www/html nfs4 defaults,_netdev 0 0" | sudo tee -a /etc/fstab

# Verify the mount
mount | grep /var/www/html

echo "EFS file system mounted on /var/www/html"
