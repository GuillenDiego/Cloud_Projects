Configure AWS
```
aws configure
```
Deploy the EKS Cluster
Initialize the working directory:
```
terraform init
```
Review the actions that will be performed and check for any potential errors:
```
terraform plan
```
Apply the configuration and deploy your cluster:
```
terraform apply
```
Type "yes" and hit Enter to confirm. Allow the configuration to complete successfully and create your resources, including the EKS cluster.

Configure `kubectl` to interact with the cluster:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
Confirm that `kubectl` was configured properly and that the cluster was successfully deployed:
```
kubectl get cs
```
The all the components should be up and running with a status of `Healthy`.

Confirm that the NGINX pods were successfully deployed:
```
kubectl get deployments
```


script for amazonlinux 2023

```sh
#!/bin/bash

# Install necessary packages
dnf -y install git wget jq unzip gcc dnf-plugins-core

# Add HashiCorp repo and install Terraform
dnf config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
dnf -y install terraform

# Set password for cloud_user
echo 'Dji9(id&' | sudo passwd --stdin cloud_user

# Restart SSH service
sudo systemctl restart sshd

# Configure AWS CLI for cloud_user
sudo -iu cloud_user aws configure set default.region <AWS::Region>

# Install kubectl
curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.21.2/2021-07-05/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/bin/kubectl

# Set permissions for cloud_user
chown -R cloud_user:cloud_user /home/cloud_user/amati_code

# Switch to cloud_user and download lab files
su - cloud_user -c 'cd /home/cloud_user/'
su - cloud_user -c 'wget https://raw.githubusercontent.com/ACloudGuru-Resources/content-terraform-2021/main/lab-terraform-eks-2.zip'
su - cloud_user -c 'unzip lab-terraform-eks-2.zip'

# Save AMI and Subnet IDs to resource_ids.txt
echo 'ami: <LatestAmiId>' >> /home/cloud_user/resource_ids.txt
echo 'subnet_id: <SubnetA>' >> /home/cloud_user/resource_ids.txt

# Signal completion of setup
/opt/aws/bin/cfn-signal --exit-code 0 --resource TerraformController --region <AWS::Region> --stack <AWS::StackName>
```