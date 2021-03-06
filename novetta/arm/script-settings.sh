#!/bin/bash

#--------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------
#set -x
GREEN='\033[0;32m'
NC='\033[0m'
LINE=${GREEN}-----------------------------------------------------------------------${NC}
# Comment in the following line for debug output
#DEBUG="--debug"

#--------------------------------------------------------------------------------
# Define cd function
#--------------------------------------------------------------------------------
function cdx() {
  cd $1
}

#--------------------------------------------------------------------------------
# Print Header
#--------------------------------------------------------------------------------
function print_header() {
  echo -e ${LINE}
  echo -e ${GREEN}${1}${NC}
  echo -e ${LINE}
}

#--------------------------------------------------------------------------------
# Function for pausing the script 
#--------------------------------------------------------------------------------
function pause() {
  if [ "${PAUSE}" == "true" ]
  then 
    echo
    echo -e ${GREEN}Hit Enter to Continue...${NC}
    read
  fi
}

