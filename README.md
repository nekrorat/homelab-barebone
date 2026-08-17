# Homelab Barebone

This is a bare-bones lab, so it is intended to serve as a foundation that you can customize and expand as your homelab grows.

Homelab Barebone is an Infrastructure as Code (IaC) project for building
repeatable homelab nodes from bare metal. The workflow begins with an automated
Ubuntu Server installation and will later continue with node configuration and
infrastructure provisioning.

The repository currently documents the completed Ubuntu installation stage.

## Ubuntu Server installation

The [`ubuntu-autoinstall`](./ubuntu-autoinstall/README.md) component provides a reusable
way to install Ubuntu Server without entering the same settings manually on
every node.

This stage includes:

- Generate Autoinstall configuration in `user-data` and `meta-data` templates for unattended installation
- Post-installation checks and SSH connection guidance

For prerequisites, configuration options, commands, and complete installation
instructions, see the
[`ubuntu-autoinstall` guide](./ubuntu-autoinstall/README.md).

> Generated Autoinstall files contain a password hash and are excluded from Git.
> Treat them as sensitive data.
