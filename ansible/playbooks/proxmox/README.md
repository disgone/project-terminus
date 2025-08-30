# Proxmox Playbooks

This directory contains Ansible playbooks specifically for managing Proxmox VE infrastructure.

## Available Playbooks

### download-templates.yml
Downloads LXC container templates to Proxmox VE nodes using the `proxmox` role.

**Usage:**
```bash
# From the ansible/ directory
ansible-playbook playbooks/proxmox/download-templates.yml

# With check mode (dry run)
ansible-playbook playbooks/proxmox/download-templates.yml --check
```

**Features:**
- Interactive prompts for storage pool and template selection
- Input validation for template formats and storage existence
- Idempotent operation (skips existing templates)
- Comprehensive error handling
- Clear progress feedback

**Prerequisites:**
- SSH access to Proxmox hosts as root user
- Proxmox VE cluster properly configured
- Target storage pool exists and supports templates

Run `pveam available` on a Proxmox node to see available template names.