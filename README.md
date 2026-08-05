# Homelab Barebone

Homelab Barebone is an Infrastructure as Code (IaC) project for building
repeatable homelab nodes from bare metal. The workflow begins with an automated
Ubuntu Server installation and will later continue with node configuration and
infrastructure provisioning.

The repository currently documents the completed Ubuntu installation stage.

## Ubuntu Server installation

The [`ubuntu-autoinstall`](./ubuntu-autoinstall/) component provides a reusable
way to install Ubuntu Server without entering the same settings manually on
every node. It uses Ubuntu Autoinstall and cloud-init's NoCloud data source to
supply each machine with its hostname, initial user, password hash, and SSH
configuration.

This stage includes:

- `user-data` and `meta-data` templates for unattended installation
- An interactive script that generates node-specific configuration files
- Support for serving the configuration over the local network
- A repeatable layout for provisioning multiple nodes
- Post-installation checks and SSH connection guidance

At a high level, the installation workflow is:

1. Generate the Autoinstall configuration for a node.
2. Serve the generated files from a computer on the homelab network.
3. Boot the node from an Ubuntu Server installation USB and point the installer
   to the hosted configuration.
4. Verify the installed system and connect to it over SSH.

For prerequisites, configuration options, commands, and complete installation
instructions, see the
[`ubuntu-autoinstall` guide](./ubuntu-autoinstall/README.md).

> Generated Autoinstall files contain a password hash and are excluded from Git.
> Treat them as sensitive data.
