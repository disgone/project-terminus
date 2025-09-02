# Ubuntu LTS Template Stack

This stack creates a cloud-init enabled Ubuntu LTS template in your Proxmox homelab that can be cloned to rapidly deploy VMs.

## Purpose

Creates a reusable Ubuntu LTS VM template with:
- Latest Ubuntu LTS (24.04 Noble by default)
- Cloud-init pre-configured 
- QEMU guest agent installed
- Essential packages pre-installed
- SSH access configured
- Ready for Ansible management

## Prerequisites

1. **Proxmox VE** with API access
2. **OpenTofu** installed
3. **SSH public key** available for VM access
4. **Storage pool** with sufficient space (20GB+ recommended)

## Quick Start

1. **Configure Proxmox credentials**:
   ```bash
   export PM_API_URL="https://your-proxmox:8006/api2/json"
   export PM_USER="root@pam"
   export PM_PASS="your-password"
   export PM_TLS_INSECURE="true"  # For self-signed certificates
   ```

2. **Copy and customize configuration**:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your settings
   ```

3. **Deploy the template**:
   ```bash
   tofu init
   tofu plan
   tofu apply
   ```

## Configuration

### Core Settings

| Variable | Default | Description |
|----------|---------|-------------|
| `target_node` | `"proxmox"` | Proxmox node name |
| `storage_pool` | `"local-zfs"` | Storage pool for template |
| `template_vm_id` | `9000` | VM ID (9000-9999 range) |
| `template_name` | `"ubuntu-lts-template"` | Template name |

### Ubuntu Version

| Variable | Default | Options |
|----------|---------|---------|
| `ubuntu_version` | `"24.04"` | `"20.04"`, `"22.04"`, `"24.04"` |

### Hardware Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `memory` | `2048` | Memory in MB (512-32768) |
| `cpu_cores` | `2` | CPU cores (1-16) |
| `cpu_sockets` | `1` | CPU sockets (1-4) |
| `cpu_type` | `"host"` | CPU type (`host`, `kvm64`, `qemu64`) |
| `disk_size` | `"20G"` | Disk size |

### Network Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `network_bridge` | `"vmbr0"` | Network bridge |

## What Gets Created

1. **VM Template** with ID 9000 (configurable)
2. **Cloud-init configuration** with vendor data
3. **Pre-installed packages**: qemu-guest-agent, curl, wget, git, htop, vim, unzip
4. **Security configuration**: SSH keys, disabled root login
5. **Tags** for organization

## Using the Template

After creation, clone the template to create VMs:

```bash
# Example: Clone template to create a new VM
qm clone 9000 100 --name "my-vm" --full
qm set 100 --ipconfig0 ip=192.168.1.100/24,gw=192.168.1.1
qm start 100
```

Or use it with other OpenTofu stacks for automated VM deployment.

## Customization

### Additional Packages

Add packages to `cloud_init_packages`:
```hcl
cloud_init_packages = [
  "qemu-guest-agent",
  "docker.io",
  "python3-pip",
  # Add your packages here
]
```

### Custom Commands

Add startup commands to `cloud_init_runcmd`:
```hcl
cloud_init_runcmd = [
  "apt-get update",
  "systemctl enable docker",
  # Add your commands here
]
```

### Additional Cloud-init Config

Customize `cloud_init_additional_config` for advanced configuration:
```hcl
cloud_init_additional_config = <<-EOT
write_files:
  - path: /etc/my-config.conf
    content: |
      # Custom configuration
    permissions: '0644'
EOT
```

## Outputs

After deployment, the stack provides:
- `template_id`: Created template VM ID
- `template_name`: Template name
- `target_node`: Proxmox node
- `configuration_summary`: Summary of settings

## Integration with Homelab

This template is designed to work with:
- **Ansible**: Pre-configured for SSH access and Python
- **Cluster deployments**: Ready for k3s, Docker Swarm, etc.
- **Other stacks**: Can be referenced by VM deployment stacks

## Troubleshooting

### Common Issues

1. **Permission denied**: Check Proxmox API credentials
2. **Storage full**: Ensure storage pool has 20GB+ free space  
3. **Network issues**: Verify network bridge exists
4. **SSH access**: Ensure SSH public key is properly configured

### Logs

Check cloud-init logs on first boot:
```bash
sudo tail -f /var/log/cloud-init-output.log
sudo cloud-init status
```

## Cleanup

To remove the template:
```bash
tofu destroy
```

## Related Documentation

- [Cloud-init Template Module](../../modules/cloud_init_template/README.md)
- [Project Style Guide](../../../agents.md)
- [Proxmox Cloud-init Guide](https://pve.proxmox.com/wiki/Cloud-Init_Support)
