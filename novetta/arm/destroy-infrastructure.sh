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
# Delete Resource Group
#--------------------------------------------------------------------------------
function delete_resource_group() {
  print_header "Deleting Resource Group..."

  az group delete \
  --resource-group ${RESOURCE_GROUP_NAME} \
  --yes \
  $DEBUG
}

#--------------------------------------------------------------------------------
# Main
#--------------------------------------------------------------------------------
function main() {
  delete_resource_group
}

START_TIME=`date`

# Call main
main

END_TIME=`date`

echo
echo "START_TIME=${START_TIME}"
echo "END_TIME  =${END_TIME}"
