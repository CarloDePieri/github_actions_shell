#!/bin/bash
#
# Copies to the clipboard the script, compiled with the secrets
# -o used as arg will output the script to stdout as well.

source .env

export SSH_KEY
export SSH_RELAY_HOST
export SSH_RELAY_USER
export SSH_RELAY_KEY

check=$(command -v xsel)

if [[ "$check" != "" ]]; then

  if [ "${1}" == "-o" ]; then
    envsubst '${SSH_KEY},${SSH_RELAY_KEY},${SSH_RELAY_USER},${SSH_RELAY_HOST}' < script.sh
    echo ""
  fi

  echo -n "$(envsubst '${SSH_KEY},${SSH_RELAY_KEY},${SSH_RELAY_USER},${SSH_RELAY_HOST}' < script.sh)" | xsel -i --clipboard
  echo -e "# Script copied to the clipboard!"

else

  envsubst '${SSH_KEY},${SSH_RELAY_KEY},${SSH_RELAY_USER},${SSH_RELAY_HOST}' < script.sh

fi

