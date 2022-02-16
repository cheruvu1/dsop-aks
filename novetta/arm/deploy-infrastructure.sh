#!/bin/bash

#--------------------------------------------------------------------------------
# Source the Common Script Settings File
#--------------------------------------------------------------------------------
. ./script-settings.sh

#--------------------------------------------------------------------------------
# Source the env variables
#--------------------------------------------------------------------------------
. ./azure-env

#--------------------------------------------------------------------------------
# Create Resource Group
#--------------------------------------------------------------------------------
function create_resource_group() {
  print_header "Creating Resource Group..."

  az group create \
  --name ${RESOURCE_GROUP_NAME} \
  --location ${LOCATION} \
  $DEBUG
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
}

#--------------------------------------------------------------------------------
# Create Key Vault Key
#--------------------------------------------------------------------------------
function create_key_vault_key() {
  print_header "Creating Key Vault Key..."

  az keyvault key create \
  --name ${KEY_NAME} \
  --vault-name ${VAULT_NAME} \
  --protection software \
  $DEBUG
}

#--------------------------------------------------------------------------------
# Get Key Version
#--------------------------------------------------------------------------------
function get_key_version() {
  print_header "Getting Key Version..."

  key_version=$(az keyvault key show \
  --name ${KEY_NAME} \
  --vault-name ${VAULT_NAME} \
  --query "key.kid" | cut -d "/" -f 6 | sed 's/\"//g')
  echo key_version=${key_version} \
  $DEBUG
}

#--------------------------------------------------------------------------------
# Get Key ID
#--------------------------------------------------------------------------------
function get_key_id() {
  print_header "Getting Key ID..."

  key_id=$(az keyvault key show \
  --name ${KEY_NAME} \
  --vault-name ${VAULT_NAME} \
  --query "key.kid" | sed 's/\"//g')
  echo key_id=${key_id} \
  $DEBUG
}

#--------------------------------------------------------------------------------
# Create Virtual Machine to use for deployment
#
# TODO - move to ARM template
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
}

#--------------------------------------------------------------------------------
# Deploy Infrastructure
#--------------------------------------------------------------------------------
function deploy_infrastructure() {
  print_header "Deploying Infrastucture..."

  az deployment group create \
  --name ${DEPLOYMENT_NAME} \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --template-file ${TEMPLATE_FILE} \
  --parameters @${PARAMETERS_FILE} \
  platformName=${PLATFORM_NAME} \
  componentName=${COMPONENT_NAME} \
  environmentName=${ENVIRONMENT_NAME} \
  vaultName=${VAULT_NAME} \
  keyName=${KEY_NAME} \
  keyId=${key_id} \
  keyVersion=${key_version} \
  $DEBUG
}

#--------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------
function main() {
  create_resource_group
  create_key_vault
  create_key_vault_key
  get_key_version
  get_key_id
  create_virtual_machine
  deploy_infrastructure
}

START_TIME=`date`

# Call main
main

END_TIME=`date`

echo
echo "START_TIME=${START_TIME}"
echo "END_TIME  =${END_TIME}"
