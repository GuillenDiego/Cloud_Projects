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