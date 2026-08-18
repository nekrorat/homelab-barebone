# Homelab Barebone

Homelab Barebone automates the first stage of building a homelab: turning bare-metal hardware into a consistently installed Proxmox VE node. It combines Proxmox's unattended installer, iPXE, and a small HTTP service so a machine can boot from the network and install without repeatedly entering the same settings by hand.

The purpose of this repository is to provide a reproducible starting point for a homelab. It handles the operating-system installation layer; cluster configuration, virtual machines, containers, and workloads can be added as later automation stages.

> [!CAUTION]
> The automated installer erases the disks selected in the answer file. Verify the disk and network filters on the target hardware before booting the installer.

## What is included

| Path | Purpose |
| --- | --- |
| `docker-compose.yaml` | Runs the HTTP server and build tooling |
| `docker/proxmox-tooling/Dockerfile` | Packages the Proxmox auto-install assistant |
| `docker/pxe-http/server.py` | Serves PXE assets and answer files |
| `proxmox/answers/pve01.example.toml` | Documents an example node installation |
| `proxmox/pxe/boot.ipxe` | Provides the homelab boot menu |
| `proxmox/pxe/test-boot.ipxe` | Tests iPXE script delivery |

The repository does not provide DHCP or TFTP. An existing network-boot service must load iPXE and chain to the HTTP-served boot script.

## How it works

1. A node-specific TOML answer file defines the hostname, administrator credentials, network interface, address, filesystem, and installation disk.
2. `proxmox-auto-install-assistant` validates that file and prepares the Proxmox installer for HTTP answer retrieval.
3. The target machine enters iPXE through the local DHCP/TFTP environment.
4. [`boot.ipxe`](./proxmox/pxe/boot.ipxe) downloads the installer kernel, initramfs, and prepared ISO from this project's HTTP server.
5. The Proxmox installer sends a POST request containing detected system information. The server returns the selected answer file.
6. Proxmox VE installs unattended and boots from the target disk.

PXE booting loads the installer ISO into memory, so the target should have at least 6 GiB of RAM. See the [Proxmox VE unattended-installation documentation](https://pve.proxmox.com/pve-docs/pve-admin-guide.html#chapter_pve_installation) for the upstream concepts and supported answer-file options.

## Prerequisites

- Docker Engine with Docker Compose
- A downloaded Proxmox VE installer ISO
- A DHCP/TFTP or equivalent network-boot environment
- An iPXE-capable target machine
- Network access from the target to TCP port `8002` on the Docker host

## Configure a node

Copy the example without changing the tracked template:

```sh
cp proxmox/answers/pve01.example.toml proxmox/answers/pve01.toml
```

Edit `pve01.toml` for the target node. Pay particular attention to:

- `fqdn`, `mailto`, and `root-password`
- `cidr`, `dns`, and `gateway`
- `ID_NET_NAME_MAC`, which selects the network interface
- `disk-list`, which selects disks that will be erased

Real answer files are ignored by Git because they contain credentials and environment-specific details. Files ending in `.example.toml` remain trackable.

## Prepare the installer

Place the official ISO in `proxmox/`, then build the tooling container:

```sh
docker compose --profile manual_only build proxmox-tooling
```

Validate the node answer file:

```sh
docker compose --profile manual_only run --rm proxmox-tooling \
  proxmox-auto-install-assistant validate-answer answers/pve01.toml
```

Prepare the ISO with the answer-file URL reachable by the target machine:

```sh
docker compose --profile manual_only run --rm proxmox-tooling \
  proxmox-auto-install-assistant prepare-iso \
  --fetch-from http \
  --url "http://<SERVER_IP>:8002/answers/pve01.toml" \
  --pxe \
  proxmox-ve_9.2-1.iso
```

Move the generated boot images into the directory used by the included iPXE script:

```sh
mkdir -p proxmox/pxe/proxmox-installer
mv proxmox/vmlinuz proxmox/initrd.img proxmox/pxe/proxmox-installer/
```

The prepared ISO remains in `proxmox/`. Update the server address and filenames in [`boot.ipxe`](./proxmox/pxe/boot.ipxe) whenever the HTTP host or Proxmox version changes. Generated installer artifacts and ISO images are intentionally excluded from Git.

## Start the HTTP server

```sh
docker compose up -d pxe-http
```

Confirm that an iPXE script is reachable:

```sh
curl http://localhost:8002/pxe/test-boot.ipxe
```

Configure the network-boot environment to chain to:

```text
http://<SERVER_IP>:8002/pxe/boot.ipxe
```

Follow server activity with:

```sh
docker compose logs -f pxe-http
```

## Security notes

- Run this service only on a trusted provisioning network. It currently has no authentication or TLS.
- The HTTP server logs the hardware information posted by the installer.
- Keep real answer files private; they can contain a plaintext root password.
- Test the boot flow on non-production hardware before unattended installation.
