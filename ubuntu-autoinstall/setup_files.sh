#!/bin/bash

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="$SCRIPT_DIR/output"

mkdir -p "$OUTPUT_DIR"

USER_DATA_TEMPLATE="$SCRIPT_DIR/templates/user-data-template.yaml"
META_DATA_TEMPLATE="$SCRIPT_DIR/templates/meta-data-template.yaml"
USER_DATA_OUTPUT_FILE="$OUTPUT_DIR/user-data"
META_DATA_OUTPUT_FILE="$OUTPUT_DIR/meta-data"

PASSWORD_COUNT=0

YELLOW='\033[0;33m'
RESET='\033[0m'

if [ ! -f "$USER_DATA_TEMPLATE" ]; then
    echo -e "${YELLOW}Error: $USER_DATA_TEMPLATE not found!${RESET}"
    exit 1
elif [ ! -f "$META_DATA_TEMPLATE" ]; then
    echo -e "${YELLOW}Error: $META_DATA_TEMPLATE not found!${RESET}"
    exit 1
fi

if ! command -v envsubst &> /dev/null; then
    echo -e "${YELLOW}envsubst${RESET} is not installed!"
    echo -e "Run ${YELLOW}sudo apt install gettext-base${RESET} to install ${YELLOW}envsubst${RESET} before running this script."
    exit 1
elif ! command -v openssl &> /dev/null; then
    echo -e "${YELLOW}openssl${RESET} is not installed!"
    echo -e "Run ${YELLOW}sudo apt install openssl${RESET} to install ${YELLOW}openssl${RESET} before running this script."
    exit 1
fi




echo -e "${YELLOW}Enter the system and user details for the Ubuntu autoinstall configuration:${RESET}"
read -rp "Enter hostname: " HOSTNAME
read -rp "Enter realname: " REALNAME
read -rp "Enter username: " USERNAME
read -rsp "Enter password: " PASSWORD
echo
read -rsp "Confirm password: " PASSWORD_CONFIRM
echo

while [ "${PASSWORD}" != "${PASSWORD_CONFIRM}" ]; do
  ((PASSWORD_COUNT++))

  if [ ${PASSWORD_COUNT} -eq 3 ]; then
    exit 1
  fi

  echo -e "${YELLOW}Error: Passwords do not match. Try again.${RESET}"
  echo

  read -rsp "Enter password: " PASSWORD
  echo

  read -rsp "Confirm password: " PASSWORD_CONFIRM
  echo
done

PASSWORD_HASH=$(openssl passwd -6 "$PASSWORD")

echo
echo -e "${YELLOW}=== YOUR INPUT DATA ===${RESET}"
echo "Hostname: $HOSTNAME"
echo "Real name: $REALNAME"
echo "Username: $USERNAME"
echo "Hash: $PASSWORD_HASH"
echo

export HOSTNAME
export REALNAME
export USERNAME
export PASSWORD_HASH

envsubst < "$USER_DATA_TEMPLATE" > "$USER_DATA_OUTPUT_FILE"
envsubst < "$META_DATA_TEMPLATE" > "$META_DATA_OUTPUT_FILE"

echo -e "Generated ${YELLOW}$USER_DATA_OUTPUT_FILE${RESET} and ${YELLOW}$META_DATA_OUTPUT_FILE${RESET} autoinstall files are ready!"


