# Assumptions
- [ ] You have an Azure DevOps Account
- [ ] You have access to the Azure DevOps dsop-aks repository
- [ ] You have a Microsoft Azure account
- [ ] You have Azure CLI installed on the machine you're using to deploy  
- [ ] You have an SSH key already created in ~.ssh/

# Notes

# Steps On local dev machine

1. Clone the amtrak_monorepo repository
   * git clone https://azure-ecosystem.visualstudio.com/Azure%20Gov%20Engineering/_git/dsop-aks 

2. Change directory to dsop-aks/novetta/cli

3. Update the azure-env fle with the appropriate value for: ENVIRONMENT_NAME
  For example:
   * ENVIRONMENT_NAME=devcli01

4. Run the deploy.sh script
   * ./deploy-infrastructure.sh 

5. Once the deploy-infrastructure.sh script has completed following the instructions provided in the output.
- [ ] SSH into the remote server

6. To delete the deployment and all associated resources run the following script on your local machine:
   * ./destroy-infrastructure.sh


