# Introduction 

This repository contains the terraform modules for deploying AKS for use with BigBang installation. 
 
# Getting Started
1. Tools required:
    - terraform
    - kubectl
    - Azure CLI 

2. Run deployment from example directory: `cd example`

3. Copy `terraform.tfvars.sample` to `terraform.tfvars`

4. Update variables: 
     - `CLUSTER_NAME`: name of your AKS cluster
     - `RESOURCE_GROUP_NAME`: name of your AKS cluster
     - `AZUREAD_GROUP_IDS`: This AKS cluster uses managed identity. In order to connect to the cluster, a user must be a part of an AAD Group. This variable can be a comma separated list of Group Ids. If you don't have an AD Group, you can create one or connect with admin credentials (not recommended).

5. The networking defaults can be updated if required.

# Build and Test
1. In the example directory, Initialize terraform: `terraform init`
2. Apply the terraform modules: `terraform apply`
3. Assuming the terraform apply completes successfully, you can know get the credentials to access the cluster: 

```az aks get-credentials --resource-group {RESOURCE_GROUP_NAME} --name {CLUSTER_NAME}```

# Contribute
TODO: Explain how other users and developers can contribute to make your code better. 

