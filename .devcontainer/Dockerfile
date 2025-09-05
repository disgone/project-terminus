# Ansible dev tools image (Fedora base)
# Ref: ghcr.io/ansible/community-ansible-dev-tools
FROM ghcr.io/ansible/community-ansible-dev-tools:latest

USER root
RUN dnf -y install git jq unzip openssh-clients sshpass curl ca-certificates && dnf clean all

# Fedora: install OpenTofu from official repos
# (binary will be `tofu`)
RUN dnf -y install opentofu && dnf clean all

# Install HashiCorp Packer from precompiled binary
RUN PACKER_VERSION=$(curl -s https://api.github.com/repos/hashicorp/packer/releases/latest | jq -r '.tag_name' | sed 's/^v//') && \
    curl -Lo packer.zip "https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip" && \
    unzip packer.zip && \
    mv packer /usr/local/bin/ && \
    chmod +x /usr/local/bin/packer && \
    rm packer.zip

# Optional: helpers for Proxmox + HTTP
RUN python3 -m pip install --no-cache-dir proxmoxer requests
