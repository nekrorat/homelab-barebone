#!/usr/bin/bash

# Default PROXMOX VE version
PROXMOX_DEFAULT_VERSION=9.2-1
PROXMOX_DEFAULT_SHA=4e88fe416df9b527624a175f24c9aa07c714d3332afb1ee3dbf3879573ef2c6c

PROXMOX_INSTALL_VERSION=""
PROXMOX_INSTALL_SHA=""

YELLOW='\033[0;33m'
RESET='\033[0m'

echo -e "${YELLOW}This script downloads Proxmox VE ISO file${RESET}"
echo -e "${YELLOW}Check Proxmox ISOs inventory: https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso${RESET}"
read -rp "Enter Proxmox version (d.d-d) to download or press ENTER to use ${PROXMOX_DEFAULT_VERSION} (default): " PROXMOX_SELECTED_VERSION

# check input or download the default version
if [[ -z "$PROXMOX_SELECTED_VERSION" ]]; then
  echo -e "${YELLOW}The default version ${PROXMOX_DEFAULT_VERSION} is selected${RESET}"
  PROXMOX_INSTALL_VERSION="$PROXMOX_DEFAULT_VERSION"
elif [[ "$PROXMOX_SELECTED_VERSION" =~ ^[0-9]+\.[0-9]+-[0-9]+$ ]]; then
  echo "Version $PROXMOX_SELECTED_VERSION is selected"
  PROXMOX_INSTALL_VERSION="$PROXMOX_SELECTED_VERSION"
else
  echo "Something went wrong. Check the format. Expected format: d.d-d"
  exit 1
fi

# check if file already downloaded
if [[ -f "proxmox-ve_${PROXMOX_INSTALL_VERSION}.iso" ]]; then
  echo "File proxmox-ve_${PROXMOX_INSTALL_VERSION}.iso already exists. Download is not required."
  #exit 1
else
  wget https://enterprise.proxmox.com/iso/proxmox-ve_"${PROXMOX_INSTALL_VERSION}".iso || exit 1
  sleep 1
fi

# verify checksum
if [[ "$PROXMOX_INSTALL_VERSION" == "$PROXMOX_DEFAULT_VERSION" ]]; then
    PROXMOX_INSTALL_SHA="${PROXMOX_DEFAULT_SHA}"
    echo "${PROXMOX_DEFAULT_SHA}"
else
  read -rp "Verify SHA256 for version ${PROXMOX_INSTALL_VERSION}. Enter SHA256 or press Enter to skip: " PROXMOX_INSTALL_SHA
fi

echo -e "${YELLOW}Verifying Proxmox VE ISO checksum...${RESET}"
echo "${PROXMOX_INSTALL_SHA} proxmox-ve_${PROXMOX_INSTALL_VERSION}.iso" | sha256sum -c
