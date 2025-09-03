# Ansible dev tools image (Fedora base)
# Ref: ghcr.io/ansible/community-ansible-dev-tools
FROM ghcr.io/ansible/community-ansible-dev-tools:latest

USER root
RUN dnf -y install git jq unzip openssh-clients sshpass curl ca-certificates && dnf clean all

# Fedora: install OpenTofu from official repos
# (binary will be `tofu`)
RUN dnf -y install opentofu && dnf clean all

# Optional: helpers for Proxmox + HTTP
RUN python3 -m pip install --no-cache-dir proxmoxer requests
