#!/usr/bin/bash

PROXMOX_VE_DEFAULT_VERSION=9.2-1

YELLOW='\033[0;33m'
RESET='\033[0m'

echo -e "${YELLOW}This script downloads Proxmox VE ISO file${RESET}"
echo -e "${YELLOW}Check Proxmox ISOs inventory: https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso${RESET}"
read -rp "Enter Proxmox VE version to download or press ENTER to use ${PROXMOX_VE_DEFAULT_VERSION} (default): " PROXMOX_VE_VERSION

if [[ -z "$PROXMOX_VE_VERSION" ]]; then
  echo -e "${YELLOW}The default version ${PROXMOX_VE_DEFAULT_VERSION} is selected${RESET}"
  PROXMOX_VE_VERSION="$PROXMOX_VE_DEFAULT_VERSION"
  wget https://enterprise.proxmox.com/iso/proxmox-ve_"${PROXMOX_VE_DEFAULT_VERSION}".iso
elif [[ "$PROXMOX_VE_VERSION" =~ ^[0-9]+\.[0-9]+-[0-9]+$ ]]; then
  echo "Version $PROXMOX_VE_VERSION is selected"
  wget https://enterprise.proxmox.com/iso/proxmox-ve_"${PROXMOX_VE_VERSION}".iso
else
  echo "Something went wrong. Check the format. Expected format: d.d-d"
fi

