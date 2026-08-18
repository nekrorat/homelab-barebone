FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        wget \
        xorriso \
        file \
        cpio \
        gzip \
        xz-utils \
        zstd && \
    wget -q \
        https://enterprise.proxmox.com/debian/proxmox-release-trixie.gpg \
        -O /etc/apt/trusted.gpg.d/proxmox-release-trixie.gpg && \
    echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" \
        > /etc/apt/sources.list.d/pve.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        proxmox-auto-install-assistant && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["/bin/bash"]