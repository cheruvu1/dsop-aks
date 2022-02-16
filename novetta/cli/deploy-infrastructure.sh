#!/bin/bash

#--------------------------------------------------------------------------------
# Source the Common Script Settings File
#--------------------------------------------------------------------------------
. ./script-settings.sh

#--------------------------------------------------------------------------------
# Source the Azure env variables
#--------------------------------------------------------------------------------
. ./azure-env

#--------------------------------------------------------------------------------
# Get Postgres admin user and password if not found in azure-env
#--------------------------------------------------------------------------------
function get_postgres_credentials() {
  if [ "x${POSTGRES_ADMIN_USER}" == "x" ]; then
    read -p "Please enter Postres admin user: " 
    POSTGRES_ADMIN_USER=${REPLY}
  fi
  
  if [ "x${POSTGRES_ADMIN_PASSWORD}" == "x" ]; then
    read -s -p "Please enter Postgres password: "
    POSTGRES_ADMIN_PASSWORD=${REPLY}
  fi
 
  pause
}

#--------------------------------------------------------------------------------
# Identify Current User ID and Name
#--------------------------------------------------------------------------------
function identify_current_user() {
  print_header "Getting User ID and User Name..."

  user_id=$(az ad signed-in-user show \
  --query objectId --output tsv) 
  echo -e user_id=${user_id}

  user_name=$(az ad signed-in-user show \
  --query userPrincipalName --output tsv) 

  echo -e user_name=${user_name}

  pause
}

#--------------------------------------------------------------------------------
# Create Resource Group
#--------------------------------------------------------------------------------
function create_resource_group() {
  print_header "Creating Resource Group..."

  az group create \
  --name ${RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Assign Contributor Role to User
#--------------------------------------------------------------------------------
function assign_contributor_role_to_user() {
  print_header "Assigning 'Contributor' Role to User..."

  az role assignment create \
  --assignee ${user_id} \
  --role "Contributor" \
  --resource-group ${RESOURCE_GROUP_NAME} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Virtual Machine
# ssh keys stored in ~/.ssh/ - if already there then those will be used
#--------------------------------------------------------------------------------
function create_virtual_machine() {
  print_header "Creating Vitual Machine..."

  az vm create \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --name ${BOOT_SERVER_NAME} \
  --image ${LINUX_IMAGE} \
  --admin-user ${VIRTUAL_MACHINE_ADMIN} \
  --generate-ssh-keys \
  --os-disk-size-gb ${VIRTUAL_MACHINE_DISK_SIZE} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Storage Account
#--------------------------------------------------------------------------------
function create_storage_account() {
  print_header "Creating Storage Account..."

  az storage account create \
  --name ${STORAGE_ACCOUNT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  --sku Standard_RAGRS \
  $DEBUG

  pause
}
#--------------------------------------------------------------------------------
# Create Key Vault
#--------------------------------------------------------------------------------
function create_key_vault() {
  print_header "Creating Key Vault..."

  az keyvault create \
  --name ${VAULT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --enable-purge-protection true \
  --enabled-for-deployment true \
  --enabled-for-disk-encryption true \
  --enabled-for-template-deployment true \
  --retention-days 7 \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Key Vault Key
#--------------------------------------------------------------------------------
function create_key_vault_key() {
  print_header "Creating Key Vault Key..."

  az keyvault key create \
  --name ${KEY_NAME} \
  --protection software \
  --vault-name ${VAULT_NAME} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Get the version of the key - remove trailing " via sed command
#--------------------------------------------------------------------------------
function get_key_version() {
  print_header "Getting Key Version..."

  key_version=$(az keyvault key show \
  --vault-name ${VAULT_NAME} \
  --name ${KEY_NAME} \
  --query "key.kid" | cut -d "/" -f 6 | sed 's/\"//g')

  echo -e key_version=${key_version}

  pause
}

#--------------------------------------------------------------------------------
# Get the key URL - remove trailing " via sed command
#--------------------------------------------------------------------------------
function get_key_id() {
  print_header "Getting Key ID..."

  key_id=$(az keyvault key show \
  --vault-name ${VAULT_NAME} \
  --name ${KEY_NAME} \
  --query "key.kid" | sed 's/\"//g')

  echo -e key_id=${key_id}

  pause
}

#--------------------------------------------------------------------------------
# Allow current user to see the keys so that we can get the version and ID
#
# The following isn't working so hard code the values here
# --key-permissions ${USER_KEY_PERMISSIONS}
#--------------------------------------------------------------------------------
function set_key_vault_policy() {
  print_header "Setting Key Vault Policy for ${user_name} '('${user_id}')'..."

  az keyvault set-policy \
  --name ${VAULT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --object-id ${user_id} \
  --key-permissions decrypt encrypt unwrapKey wrapKey verify sign get list update create import delete backup restore recover purge \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Virtual Network
#--------------------------------------------------------------------------------
function create_virtual_network() {
  print_header "Creating Virtual Network..."

  az network vnet create \
  --name ${VIRTUAL_NETWORK_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  --address-prefixes ${ADDRESS_PREFIXES} \
  --subnet-name ${SUBNET_NAME} \
  $DEBUG 

  pause
}

#--------------------------------------------------------------------------------
# Create Subnet
#--------------------------------------------------------------------------------
function create_subnet() {
  print_header "Creating Subnet..."

  az network vnet subnet create \
  --name ${SUBNET_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --vnet-name ${VIRTUAL_NETWORK_NAME} \
  --address-prefixes ${ADDRESS_PREFIXES} \
  --service-endpoints ${SERVICE_ENDPOINTS} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Postgres Server
#--------------------------------------------------------------------------------
function create_postgres_server() {
  print_header "Creating Postgres Server..."

  az postgres server create \
  --name ${POSTGRES_SERVER_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  --sku-name ${POSTGRES_SERVER_SKU_NAME} \
  --storage-size ${POSTGRES_SERVER_STORAGE_SIZE} \
  --version ${POSTGRES_VERSION} \
  --assign-identity \
  --admin-user ${POSTGRES_ADMIN_USER} \
  --admin-password ${POSTGRES_ADMIN_PASSWORD} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Get Postgres ID 
#--------------------------------------------------------------------------------
function get_postgres_id() {
  print_header "Getting Postgres ID..."

  postgres_id=$(az postgres server list \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --query "[0].identity.principalId" | sed 's/"//g')

  echo -e postgres_id=${postgres_id}
}

#--------------------------------------------------------------------------------
# Create Vault Policy for Postgres
#
# The --key-permissions argument should be ${POSTGRES_KEY_PERMISSIONS} as defined
# in azure-env to "get unwrapKey wrapKey" but that approach is failing with the
# following error:
#
# (AzureKeyVaultMissingPermissions) The server 'pg-gates-p1-djtcli13-eastus' requires following Azure Key Vault permissions: 'Get, WrapKey, UnwrapKey'
#
# So, in mean time "hard code" the values to 'get unwrapKey wrapKey'
#--------------------------------------------------------------------------------
function create_vault_policy_for_postgres() {
  print_header "Creating Vault Policy for Postgres..."

  az keyvault set-policy \
  --name ${VAULT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --key-permissions get unwrapKey wrapKey \
  --object-id $postgres_id \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Create Postgres Server Key
#--------------------------------------------------------------------------------
function create_postgres_server_key() {
  print_header "Creating Postgres Server Key..."

  az postgres server key create \
  --name ${POSTGRES_SERVER_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --kid $key_id \
  $DEBUG

  pause
}
#--------------------------------------------------------------------------------
# Create Disk Encryption Set
#--------------------------------------------------------------------------------
function create_disk_encryption_set() {
  print_header "Creating Disk Encryption Set..."

  az disk-encryption-set create \
  --name ${DISK_ENCRYPTION_SET_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --key-url $key_id \
  --source-vault ${VAULT_NAME} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Get Disk Encryption Set ID
#--------------------------------------------------------------------------------
function get_disk_encryption_set_id() {
  print_header "Getting Disk Encryption Set ID..."

  des_id=$(az disk-encryption-set list \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --query "[0].identity.principalId" $DEBUG | sed 's/"//g') 

  echo -e des_id=${des_id}

  pause
}

#--------------------------------------------------------------------------------
# Create Vault Policy for Disk Encryption Set
#
# The --key-permissions argument should be ${DISK_ENCRYPTION_SET_KEY_PERMISSIONS} as defined
# in azure-env to "get unwrapKey wrapKey" but that approach is failing with the 
# following error:
#
# (AzureKeyVaultMissingPermissions) The server 'pg-gates-p1-djtcli13-eastus' requires following Azure Key Vault permissions: 'Get, WrapKey, UnwrapKey'
#
# So, in mean time "hard code" the values
#--------------------------------------------------------------------------------
function create_vault_policy_for_disk_encryption_set() {
  print_header "Creating Vault Policy for Disk Encryption Set..."

  az keyvault set-policy \
  --name ${VAULT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --key-permissions get unwrapKey wrapKey \
  --object-id $des_id \
  $DEBUG 

  pause
}
#--------------------------------------------------------------------------------
# Create Registry
#--------------------------------------------------------------------------------
function create_registry() {
  print_header "Creating Registry..."

  az acr create \
  --name ${REGISTRY_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --sku ${REGISTRY_SKU} \
  --admin-enabled true \
  $DEBUG

  pause
}
#--------------------------------------------------------------------------------
# Get Subnet ID
#--------------------------------------------------------------------------------
function get_subnet_id() {
  print_header "Getting Subnet ID..."

  subnet_id=$(az network vnet subnet show \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --vnet-name ${VIRTUAL_NETWORK_NAME} \
  --name ${SUBNET_NAME} \
  --query "id" | sed 's/"//g') 

  echo subnet_id=${subnet_id}

  pause
}

#--------------------------------------------------------------------------------
# Create Kubernetes Cluster
# ssh keys stored in ~/.ssh/ - if already there then those will be used
#--------------------------------------------------------------------------------
function create_kubernetes_cluster() {
  print_header "Creating Kubernetes Cluster..."

  az aks create \
  --name ${AKS_CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --enable-managed-identity \
  --node-count ${NODE_COUNT} \
  --enable-addons ${AKS_CLUSTER_ADDONS} \
  --generate-ssh-keys \
  --vnet-subnet-id ${subnet_id} \
  --yes \
  $DEBUG

  pause
}
#--------------------------------------------------------------------------------
# Attach cluster to registry
#--------------------------------------------------------------------------------
function attach_cluster_to_registry() {
  print_header "Attaching cluster to registry..."

  az aks update \
  --name ${AKS_CLUSTER_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --attach-acr ${REGISTRY_NAME} \
  $DEBUG

  pause
}

#--------------------------------------------------------------------------------
# Get Public IP Address of Virtual Machine 
#--------------------------------------------------------------------------------
function get_public_ip_address_of_virtual_machine() {
  print_header "Getting Public IP Address of Virtual Machine..."

  boot_server_public_ip_address=$(az vm show \
  --show-details \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --name ${BOOT_SERVER_NAME} \
  --query publicIps --output tsv)

  echo -e boot_server_public_ip_address=${boot_server_public_ip_address}

  pause
}

#--------------------------------------------------------------------------------
# Display Next Steps
#--------------------------------------------------------------------------------
function show_next_steps() {
  print_header "Next Steps..."
 
  echo -e "1. On your local dev machine run 'ssh -i ~/.ssh/id_rsa azureuser@${boot_server_public_ip_address}' to login to the Boot Server VM"
}

#--------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------
function main() {
  get_postgres_credentials
  identify_current_user
  create_resource_group
  assign_contributor_role_to_user
  create_virtual_machine
  create_storage_account
  create_key_vault
  create_key_vault_key
  get_key_version
  get_key_id
  set_key_vault_policy
  create_virtual_network
  create_subnet
  create_postgres_server
  get_postgres_id
  create_vault_policy_for_postgres
  create_postgres_server_key
  create_disk_encryption_set
  get_disk_encryption_set_id
  create_vault_policy_for_disk_encryption_set
  create_registry
  get_subnet_id 
  create_kubernetes_cluster
  attach_cluster_to_registry
  get_public_ip_address_of_virtual_machine
  show_next_steps
}

START_TIME=`date`

# Call main
main

END_TIME=`date`

echo
echo "START_TIME=${START_TIME}"
echo "END_TIME  =${END_TIME}"


